import Foundation

// A small RFB 3.7/3.8 client for the graphical console. The dashboard drives `/ws/vnc/{ns}/{name}` with
// noVNC, so the stream is plain RFB in WebSocket binary frames. This code has only ever been tested
// against scripted byte streams, never a real VM.
//
// `RFBMachine` is a pure byte-in/byte-out state machine. Every server-declared length is validated
// against fixed caps before anything is buffered or allocated.

public enum RFBError: Error, Equatable, Sendable {
    case badVersion
    case unsupportedVersion(String)
    case serverRefused(String)
    case authenticationRequired
    case unsupportedSecurity([UInt8])
    case securityFailed(String)
    case badFramebufferSize(Int, Int)
    case reasonTooLong(Int)
    case rectOutOfBounds
    case unknownMessage(UInt8)
    case unknownEncoding(Int32)
    case cutTextTooLarge(Int)
    case notBinary
}

public struct RFBRect: Sendable, Equatable {
    public var x, y, width, height: Int
    public init(x: Int, y: Int, width: Int, height: Int) { self.x = x; self.y = y; self.width = width; self.height = height }
    func union(_ o: RFBRect) -> RFBRect {
        let x0 = min(x, o.x), y0 = min(y, o.y)
        return RFBRect(x: x0, y: y0, width: max(x + width, o.x + o.width) - x0, height: max(y + height, o.y + o.height) - y0)
    }
}

/// 32-bit pixels in memory order B, G, R, X (the format we ask the server for; X is ignored).
public struct RFBFramebuffer: Sendable, Equatable {
    public let width: Int
    public let height: Int
    public internal(set) var pixels: [UInt8]
    init(width: Int, height: Int) {
        self.width = width; self.height = height
        pixels = [UInt8](repeating: 0, count: width * height * 4)
    }
}

public enum RFBEvent: Sendable, Equatable {
    case ready(name: String, width: Int, height: Int)
    /// One complete FramebufferUpdate has been applied; `dirty` is the union of its rectangles.
    case updated(dirty: RFBRect)
    case bell
}

public struct RFBMachine: Sendable {
    // Caps. A framebuffer is at most 8192 wide/high and 16M pixels (64 MiB).
    public static let maxDimension = 8192
    public static let maxPixels = 16 * 1024 * 1024
    public static let maxReasonBytes = 4096
    public static let maxNameBytes = 4096
    public static let maxCutTextBytes = 1 << 20
    public static let maxColourMapEntries = 65535

    private enum State: Equatable {
        case version, securityList, securityResult, serverInit, idle, update(remaining: Int)
    }

    private var state = State.version
    private var buf: [UInt8] = []
    private var head = 0
    private var out: [Data] = []
    private var failed = false
    private var minor = 8
    private var dirty: RFBRect?
    public private(set) var framebuffer: RFBFramebuffer?
    public private(set) var desktopName = ""

    public init() {}

    /// Bytes the client must send since the last call (each element is one WebSocket frame).
    public mutating func drainOutput() -> [Data] { defer { out = [] }; return out }

    /// Feeds bytes from the server. After any thrown error the machine refuses further input.
    public mutating func receive(_ data: Data) throws -> [RFBEvent] {
        if failed { throw RFBError.badVersion }
        buf.append(contentsOf: data)
        var events: [RFBEvent] = []
        do { while try step(&events) {} } catch { failed = true; buf = []; head = 0; throw error }
        if head > 0 && head >= buf.count / 2 { buf.removeFirst(head); head = 0 }
        return events
    }

    // MARK: Reading helpers (all relative to `head`)

    private var available: Int { buf.count - head }
    private func u8(_ o: Int) -> Int { Int(buf[head + o]) }
    private func u16(_ o: Int) -> Int { u8(o) << 8 | u8(o + 1) }
    private func u32(_ o: Int) -> Int { u16(o) << 16 | u16(o + 2) }
    private func i32(_ o: Int) -> Int32 { Int32(truncatingIfNeeded: u32(o)) }
    private func text(_ o: Int, _ n: Int) -> String { String(decoding: buf[(head + o)..<(head + o + n)], as: UTF8.self) }

    // MARK: State machine

    private mutating func step(_ events: inout [RFBEvent]) throws -> Bool {
        switch state {
        case .version:
            guard available >= 12 else { return false }
            let s = text(0, 12)
            guard s.hasPrefix("RFB "), s.hasSuffix("\n"), s.dropFirst(4).prefix(3).allSatisfy(\.isASCII),
                  s[s.index(s.startIndex, offsetBy: 7)] == ".",
                  let major = Int(s.dropFirst(4).prefix(3)), let mnr = Int(s.dropFirst(8).prefix(3)) else { throw RFBError.badVersion }
            guard major == 3, mnr >= 7 else { throw RFBError.unsupportedVersion(String(s.dropLast())) }
            minor = mnr >= 8 ? 8 : 7
            head += 12
            out.append(Data("RFB 003.00\(minor)\n".utf8))
            state = .securityList
            return true

        case .securityList:
            guard available >= 1 else { return false }
            let n = u8(0)
            if n == 0 {
                guard available >= 5 else { return false }
                let len = u32(1)
                guard len <= Self.maxReasonBytes else { throw RFBError.reasonTooLong(len) }
                guard available >= 5 + len else { return false }
                throw RFBError.serverRefused(text(5, len))
            }
            guard available >= 1 + n else { return false }
            let types = (0..<n).map { UInt8(u8(1 + $0)) }
            head += 1 + n
            guard types.contains(1) else {
                throw types.contains(2) ? RFBError.authenticationRequired : RFBError.unsupportedSecurity(types)
            }
            out.append(Data([1]))
            if minor >= 8 { state = .securityResult } else { sendClientInit() }
            return true

        case .securityResult:
            guard available >= 4 else { return false }
            if u32(0) == 0 { head += 4; sendClientInit(); return true }
            guard available >= 8 else { return false }
            let len = u32(4)
            guard len <= Self.maxReasonBytes else { throw RFBError.reasonTooLong(len) }
            guard available >= 8 + len else { return false }
            throw RFBError.securityFailed(text(8, len))

        case .serverInit:
            guard available >= 24 else { return false }
            let w = u16(0), h = u16(2), nameLen = u32(20)
            guard w >= 1, h >= 1, w <= Self.maxDimension, h <= Self.maxDimension, w * h <= Self.maxPixels else {
                throw RFBError.badFramebufferSize(w, h)
            }
            guard nameLen <= Self.maxNameBytes else { throw RFBError.reasonTooLong(nameLen) }
            guard available >= 24 + nameLen else { return false }
            desktopName = text(24, nameLen)
            head += 24 + nameLen
            framebuffer = RFBFramebuffer(width: w, height: h)
            out.append(RFBEncoder.setPixelFormatBGRA())
            out.append(RFBEncoder.setEncodings([.copyRect, .raw]))
            out.append(RFBEncoder.updateRequest(incremental: false, RFBRect(x: 0, y: 0, width: w, height: h)))
            state = .idle
            events.append(.ready(name: desktopName, width: w, height: h))
            return true

        case .idle:
            guard available >= 1 else { return false }
            switch u8(0) {
            case 0:
                guard available >= 4 else { return false }
                let n = u16(2)
                head += 4
                dirty = nil
                state = .update(remaining: n)
                if n == 0 { finishUpdate(&events) }
                return true
            case 1:   // SetColourMapEntries: not expected with true colour; skipped within caps.
                guard available >= 6 else { return false }
                let n = u16(4)
                guard available >= 6 + n * 6 else { return false }
                head += 6 + n * 6
                return true
            case 2:
                head += 1
                events.append(.bell)
                return true
            case 3:
                guard available >= 8 else { return false }
                let len = u32(4)
                guard len <= Self.maxCutTextBytes else { throw RFBError.cutTextTooLarge(len) }
                guard available >= 8 + len else { return false }
                head += 8 + len
                return true
            case let t:
                throw RFBError.unknownMessage(UInt8(t))
            }

        case .update(let remaining):
            guard available >= 12 else { return false }
            let r = RFBRect(x: u16(0), y: u16(2), width: u16(4), height: u16(6))
            let enc = i32(8)
            guard let fb = framebuffer else { throw RFBError.rectOutOfBounds }
            guard r.x + r.width <= fb.width, r.y + r.height <= fb.height else { throw RFBError.rectOutOfBounds }
            switch enc {
            case 0:   // Raw: at most the framebuffer size, so waiting for it is bounded.
                let bytes = r.width * r.height * 4
                guard available >= 12 + bytes else { return false }
                let base = head + 12
                for row in 0..<r.height {
                    let dst = ((r.y + row) * fb.width + r.x) * 4
                    let src = base + row * r.width * 4
                    framebuffer!.pixels.replaceSubrange(dst..<(dst + r.width * 4), with: buf[src..<(src + r.width * 4)])
                }
                head += 12 + bytes
            case 1:   // CopyRect
                guard available >= 16 else { return false }
                let sx = u16(12), sy = u16(14)
                guard sx + r.width <= fb.width, sy + r.height <= fb.height else { throw RFBError.rectOutOfBounds }
                var tmp = [UInt8](); tmp.reserveCapacity(r.width * r.height * 4)
                for row in 0..<r.height {
                    let s = ((sy + row) * fb.width + sx) * 4
                    tmp.append(contentsOf: framebuffer!.pixels[s..<(s + r.width * 4)])
                }
                for row in 0..<r.height {
                    let d = ((r.y + row) * fb.width + r.x) * 4
                    framebuffer!.pixels.replaceSubrange(d..<(d + r.width * 4), with: tmp[(row * r.width * 4)..<((row + 1) * r.width * 4)])
                }
                head += 16
            default:
                throw RFBError.unknownEncoding(enc)
            }
            if r.width > 0 && r.height > 0 { dirty = dirty.map { $0.union(r) } ?? r }
            state = .update(remaining: remaining - 1)
            if remaining - 1 == 0 { finishUpdate(&events) }
            return true

        }
    }

    private mutating func sendClientInit() {
        out.append(Data([1]))   // shared: do not disconnect other viewers
        state = .serverInit
    }

    private mutating func finishUpdate(_ events: inout [RFBEvent]) {
        state = .idle
        if let fb = framebuffer {
            out.append(RFBEncoder.updateRequest(incremental: true, RFBRect(x: 0, y: 0, width: fb.width, height: fb.height)))
        }
        events.append(.updated(dirty: dirty ?? RFBRect(x: 0, y: 0, width: 0, height: 0)))
        dirty = nil
    }
}

// MARK: Client-to-server encoding

public enum RFBEncoder {
    public enum Encoding: Int32 { case raw = 0, copyRect = 1 }

    private static func be16(_ v: Int) -> [UInt8] { [UInt8((v >> 8) & 0xFF), UInt8(v & 0xFF)] }
    private static func clamp16(_ v: Int) -> Int { min(max(v, 0), 0xFFFF) }

    /// 32 bits per pixel, depth 24, little-endian true colour, red<<16 | green<<8 | blue (bytes B, G, R, X).
    public static func setPixelFormatBGRA() -> Data {
        Data([0, 0, 0, 0, 32, 24, 0, 1, 0, 255, 0, 255, 0, 255, 16, 8, 0, 0, 0, 0])
    }

    public static func setEncodings(_ encodings: [Encoding]) -> Data {
        var d: [UInt8] = [2, 0] + be16(encodings.count)
        for e in encodings { let v = UInt32(bitPattern: e.rawValue); d += [UInt8(v >> 24), UInt8((v >> 16) & 0xFF), UInt8((v >> 8) & 0xFF), UInt8(v & 0xFF)] }
        return Data(d)
    }

    public static func updateRequest(incremental: Bool, _ r: RFBRect) -> Data {
        Data([3, incremental ? 1 : 0] + be16(clamp16(r.x)) + be16(clamp16(r.y)) + be16(clamp16(r.width)) + be16(clamp16(r.height)))
    }

    public static func keyEvent(down: Bool, keysym: UInt32) -> Data {
        Data([4, down ? 1 : 0, 0, 0, UInt8(keysym >> 24), UInt8((keysym >> 16) & 0xFF), UInt8((keysym >> 8) & 0xFF), UInt8(keysym & 0xFF)])
    }

    /// `buttons` bit 0 left, 1 middle, 2 right, 3 wheel up, 4 wheel down.
    public static func pointerEvent(buttons: UInt8, x: Int, y: Int) -> Data {
        Data([5, buttons] + be16(clamp16(x)) + be16(clamp16(y)))
    }
}

// MARK: Keysyms

public enum RFBKeysym {
    public static let shiftL: UInt32 = 0xFFE1, controlL: UInt32 = 0xFFE3, altL: UInt32 = 0xFFE9, superL: UInt32 = 0xFFEB
    public static let delete: UInt32 = 0xFFFF

    /// Keysym for a non-printing key by macOS virtual key code.
    public static func special(keyCode: UInt16) -> UInt32? {
        switch keyCode {
        case 36: 0xFF0D
        case 76: 0xFF8D
        case 48: 0xFF09
        case 51: 0xFF08
        case 53: 0xFF1B
        case 117: 0xFFFF
        case 114: 0xFF63
        case 115: 0xFF50
        case 119: 0xFF57
        case 116: 0xFF55
        case 121: 0xFF56
        case 123: 0xFF51
        case 126: 0xFF52
        case 124: 0xFF53
        case 125: 0xFF54
        case 122: 0xFFBE
        case 120: 0xFFBF
        case 99: 0xFFC0
        case 118: 0xFFC1
        case 96: 0xFFC2
        case 97: 0xFFC3
        case 98: 0xFFC4
        case 100: 0xFFC5
        case 101: 0xFFC6
        case 109: 0xFFC7
        case 103: 0xFFC8
        case 111: 0xFFC9
        default: nil
        }
    }

    /// Modifier keycodes (flagsChanged) to keysyms.
    public static func modifier(keyCode: UInt16) -> UInt32? {
        switch keyCode {
        case 56: 0xFFE1
        case 60: 0xFFE2
        case 59: 0xFFE3
        case 62: 0xFFE4
        case 58: 0xFFE9
        case 61: 0xFFEA
        case 55: 0xFFEB
        case 54: 0xFFEC
        default: nil
        }
    }

    /// X11 keysym for the first character: Latin-1 maps to itself, other Unicode to 0x01000000 + scalar.
    public static func keysym(forCharacters s: String) -> UInt32? {
        guard let u = s.unicodeScalars.first, u.value >= 0x20, u.value != 0x7F, !(0xF700...0xF8FF).contains(u.value) else { return nil }
        return u.value < 0x100 ? u.value : 0x0100_0000 + u.value
    }
}

// MARK: Session (WebSocket transport)

/// Runs an `RFBMachine` over a binary WebSocket and publishes events plus framebuffer snapshots.
public actor RFBSession {
    public enum Event: Sendable, Equatable {
        case ready(name: String, width: Int, height: Int)
        case frame(RFBFramebuffer, dirty: RFBRect)
        case bell
        case closed(String?)
    }

    private let connection: any BinaryWebSocketConnection
    private var machine = RFBMachine()
    public nonisolated let events: AsyncStream<Event>
    private let continuation: AsyncStream<Event>.Continuation
    private var pump: Task<Void, Never>?
    private var ended = false

    public init(connection: any BinaryWebSocketConnection) {
        self.connection = connection
        (events, continuation) = AsyncStream.makeStream(of: Event.self, bufferingPolicy: .bufferingNewest(64))
        continuation.onTermination = { [connection] _ in connection.close() }
        Task { await self.start() }
    }

    private func start() {
        guard pump == nil, !ended else { return }
        pump = Task { await self.run() }
    }

    private func run() async {
        connection.resume()
        do {
            while !Task.isCancelled {
                guard case .binary(let data) = try await connection.receive() else { throw RFBError.notBinary }
                let evs = try machine.receive(data)
                for chunk in machine.drainOutput() { try await connection.send(binary: chunk) }
                for e in evs {
                    switch e {
                    case .ready(let n, let w, let h): continuation.yield(.ready(name: n, width: w, height: h))
                    case .updated(let dirty): if let fb = machine.framebuffer { continuation.yield(.frame(fb, dirty: dirty)) }
                    case .bell: continuation.yield(.bell)
                    }
                }
            }
            finish(nil)
        } catch {
            finish(Task.isCancelled || ended ? nil : Self.describe(error))
        }
    }

    private static func describe(_ error: Error) -> String {
        switch error as? RFBError {
        case .authenticationRequired: "The machine's console requires a VNC password, which this app does not support."
        case .serverRefused(let r), .securityFailed(let r): r.isEmpty ? "The console refused the connection." : r
        case .some: "The console sent data this app could not understand."
        case nil: error.localizedDescription
        }
    }

    private func finish(_ message: String?) {
        guard !ended else { return }
        ended = true
        continuation.yield(.closed(message))
        continuation.finish()
    }

    public func sendKey(keysym: UInt32, down: Bool) async {
        try? await connection.send(binary: RFBEncoder.keyEvent(down: down, keysym: keysym))
    }

    public func sendPointer(buttons: UInt8, x: Int, y: Int) async {
        try? await connection.send(binary: RFBEncoder.pointerEvent(buttons: buttons, x: x, y: y))
    }

    public func close() {
        ended = true
        pump?.cancel()
        connection.close()
        continuation.yield(.closed(nil))
        continuation.finish()
    }
}
