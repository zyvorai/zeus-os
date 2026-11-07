import Testing
import Foundation
@testable import ZeusKit

// Scripted fake server: byte streams built by hand. Nothing here talks to a real VM.

private func be16(_ v: Int) -> [UInt8] { [UInt8(v >> 8 & 0xFF), UInt8(v & 0xFF)] }
private func be32(_ v: Int) -> [UInt8] { be16(v >> 16 & 0xFFFF) + be16(v & 0xFFFF) }
private let versionMsg = Array("RFB 003.008\n".utf8)

private func serverInit(w: Int, h: Int, name: String = "vm") -> [UInt8] {
    be16(w) + be16(h) + [32, 24, 0, 1, 0, 255, 0, 255, 0, 255, 16, 8, 0, 0, 0, 0] + be32(name.utf8.count) + Array(name.utf8)
}
private func rectHeader(_ x: Int, _ y: Int, _ w: Int, _ h: Int, enc: Int) -> [UInt8] { be16(x) + be16(y) + be16(w) + be16(h) + be32(enc) }
private func update(_ rects: [[UInt8]]) -> [UInt8] { [0, 0] + be16(rects.count) + rects.flatMap { $0 } }

/// Runs the handshake and returns a machine in the idle state on a w x h screen.
private func handshaken(w: Int = 4, h: Int = 3) throws -> RFBMachine {
    var m = RFBMachine()
    _ = try m.receive(Data(versionMsg + [1, 1] + be32(0) + serverInit(w: w, h: h)))
    _ = m.drainOutput()
    return m
}

@Test func handshakeIsByteExact() throws {
    var m = RFBMachine()
    var ev = try m.receive(Data(versionMsg))
    #expect(ev.isEmpty)
    #expect(m.drainOutput() == [Data("RFB 003.008\n".utf8)])
    ev = try m.receive(Data([1, 1]))
    #expect(m.drainOutput() == [Data([1])])
    ev = try m.receive(Data(be32(0)))
    #expect(m.drainOutput() == [Data([1])])   // ClientInit, shared
    ev = try m.receive(Data(serverInit(w: 640, h: 480, name: "kvm")))
    #expect(ev == [.ready(name: "kvm", width: 640, height: 480)])
    let out = m.drainOutput()
    #expect(out.count == 3)
    #expect(out[0] == Data([0, 0, 0, 0, 32, 24, 0, 1, 0, 255, 0, 255, 0, 255, 16, 8, 0, 0, 0, 0]))
    #expect(out[1] == Data([2, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0]))
    #expect(out[2] == Data([3, 0, 0, 0, 0, 0, 2, 128, 1, 224]))
    #expect(m.framebuffer?.pixels.count == 640 * 480 * 4)
    #expect(m.desktopName == "kvm")
}

@Test func version37SkipsSecurityResult() throws {
    var m = RFBMachine()
    _ = try m.receive(Data(Array("RFB 003.007\n".utf8) + [1, 1] + serverInit(w: 2, h: 2)))
    let out = m.drainOutput()
    #expect(out[0] == Data("RFB 003.007\n".utf8))
    #expect(out[1] == Data([1])); #expect(out[2] == Data([1]))
    #expect(m.framebuffer != nil)
}

@Test func newerServerVersionIsAnswered38() throws {
    var m = RFBMachine()
    _ = try m.receive(Data(Array("RFB 003.889\n".utf8)))
    #expect(m.drainOutput() == [Data("RFB 003.008\n".utf8)])
}

@Test func rejectsBadAndOldVersions() {
    var a = RFBMachine()
    #expect(throws: RFBError.badVersion) { try a.receive(Data("HTTP/1.1 400 ".utf8)) }
    var b = RFBMachine()
    #expect(throws: RFBError.unsupportedVersion("RFB 003.003")) { try b.receive(Data("RFB 003.003\n".utf8)) }
    // After an error the machine refuses more input.
    #expect(throws: (any Error).self) { try b.receive(Data([1])) }
}

@Test func securityListFailureReasonAndVncAuth() {
    var a = RFBMachine()
    #expect(throws: RFBError.serverRefused("too many")) {
        try a.receive(Data(versionMsg + [0] + be32(8) + Array("too many".utf8)))
    }
    var b = RFBMachine()
    #expect(throws: RFBError.authenticationRequired) { try b.receive(Data(versionMsg + [1, 2])) }
    var c = RFBMachine()
    #expect(throws: RFBError.unsupportedSecurity([19])) { try c.receive(Data(versionMsg + [1, 19])) }
    var d = RFBMachine()
    #expect(throws: RFBError.securityFailed("nope")) {
        try d.receive(Data(versionMsg + [1, 1] + be32(1) + be32(4) + Array("nope".utf8)))
    }
}

@Test func rawRectangleIsApplied() throws {
    var m = try handshaken()
    let px: [UInt8] = [1, 2, 3, 0, 4, 5, 6, 0]   // two pixels
    let ev = try m.receive(Data(update([rectHeader(1, 1, 2, 1, enc: 0) + px])))
    #expect(ev == [.updated(dirty: RFBRect(x: 1, y: 1, width: 2, height: 1))])
    let p = m.framebuffer!.pixels
    let o = (1 * 4 + 1) * 4
    #expect(Array(p[o..<(o + 8)]) == px)
    #expect(p[0] == 0)
    #expect(m.drainOutput() == [Data([3, 1, 0, 0, 0, 0, 0, 4, 0, 3])])   // incremental request for the whole screen
}

@Test func copyRectHandlesOverlap() throws {
    var m = try handshaken(w: 4, h: 1)
    let px: [UInt8] = [1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0]
    _ = try m.receive(Data(update([rectHeader(0, 0, 4, 1, enc: 0) + px])))
    _ = try m.receive(Data(update([rectHeader(1, 0, 3, 1, enc: 1) + be16(0) + be16(0)])))
    let p = m.framebuffer!.pixels
    #expect(stride(from: 0, to: 16, by: 4).map { p[$0] } == [1, 1, 2, 3])
}

@Test func updateSplitAtEveryByteBoundary() throws {
    let px: [UInt8] = [9, 8, 7, 0]
    let msg = update([rectHeader(3, 2, 1, 1, enc: 0) + px, rectHeader(0, 0, 1, 1, enc: 1) + be16(3) + be16(2)]) + [2]
    var m = try handshaken()
    var events: [RFBEvent] = []
    for b in msg { events += try m.receive(Data([b])) }
    #expect(events == [.updated(dirty: RFBRect(x: 0, y: 0, width: 4, height: 3)), .bell])
    let p = m.framebuffer!.pixels
    #expect(Array(p[0..<4]) == px)
    #expect(Array(p[((2 * 4 + 3) * 4)..<((2 * 4 + 3) * 4 + 4)]) == px)
}

@Test func wholeStreamInOneChunkAndTwoUpdates() throws {
    var m = RFBMachine()
    let ev = try m.receive(Data(versionMsg + [1, 1] + be32(0) + serverInit(w: 2, h: 1)
        + update([rectHeader(0, 0, 1, 1, enc: 0) + [1, 1, 1, 0]]) + update([])))
    #expect(ev.count == 3)
    if case .ready = ev[0] {} else { Issue.record("ready first") }
}

@Test func cutTextAndColourMapAreSkipped() throws {
    var m = try handshaken()
    let ev = try m.receive(Data([3, 0, 0, 0] + be32(3) + [65, 66, 67] + [1, 0] + be16(0) + be16(1) + [0, 0, 0, 0, 0, 0] + [2]))
    #expect(ev == [.bell])
}

@Test func malformedInputIsRejected() throws {
    // Absurd framebuffer sizes: no allocation, clean error.
    var a = RFBMachine()
    #expect(throws: RFBError.badFramebufferSize(65535, 65535)) {
        try a.receive(Data(versionMsg + [1, 1] + be32(0) + serverInit(w: 65535, h: 65535)))
    }
    var z = RFBMachine()
    #expect(throws: RFBError.badFramebufferSize(0, 5)) {
        try z.receive(Data(versionMsg + [1, 1] + be32(0) + serverInit(w: 0, h: 5)))
    }
    // Name length bigger than the cap: rejected before waiting for it.
    var n = RFBMachine()
    #expect(throws: RFBError.reasonTooLong(0xFFFF_FFF0)) {
        try n.receive(Data(versionMsg + [1, 1] + be32(0) + be16(2) + be16(2) + [UInt8](repeating: 0, count: 16) + be32(0xFFFF_FFF0)))
    }
    // Rectangle outside the framebuffer, copy source outside, unknown encoding/message, huge cut text.
    var b = try handshaken()
    #expect(throws: RFBError.rectOutOfBounds) { try b.receive(Data(update([rectHeader(3, 0, 2, 1, enc: 0)]))) }
    var c = try handshaken()
    #expect(throws: RFBError.rectOutOfBounds) { try c.receive(Data(update([rectHeader(0, 0, 2, 2, enc: 1) + be16(3) + be16(2)]))) }
    var d = try handshaken()
    #expect(throws: RFBError.unknownEncoding(16)) { try d.receive(Data(update([rectHeader(0, 0, 1, 1, enc: 16)]))) }
    var e = try handshaken()
    #expect(throws: RFBError.unknownMessage(0x99)) { try e.receive(Data([0x99])) }
    var f = try handshaken()
    #expect(throws: RFBError.cutTextTooLarge(0xFFFF_FFFF)) { try f.receive(Data([3, 0, 0, 0] + be32(0xFFFF_FFFF))) }
    // Negative encoding (sign handling) is unknown, not a crash.
    var g = try handshaken()
    #expect(throws: RFBError.unknownEncoding(-223)) { try g.receive(Data(update([rectHeader(0, 0, 1, 1, enc: 0xFFFF_FF21)]))) }
}

@Test func truncatedRawStaysBuffered() throws {
    var m = try handshaken()
    let ev = try m.receive(Data(update([rectHeader(0, 0, 4, 3, enc: 0)]) + [1, 2, 3]))
    #expect(ev.isEmpty)
}

@Test func encoders() {
    #expect(RFBEncoder.keyEvent(down: true, keysym: 0xFF0D) == Data([4, 1, 0, 0, 0, 0, 0xFF, 0x0D]))
    #expect(RFBEncoder.keyEvent(down: false, keysym: 0x0100_20AC) == Data([4, 0, 0, 0, 1, 0, 0x20, 0xAC]))
    #expect(RFBEncoder.pointerEvent(buttons: 5, x: 300, y: 7) == Data([5, 5, 1, 44, 0, 7]))
    #expect(RFBEncoder.pointerEvent(buttons: 0, x: -4, y: 99999) == Data([5, 0, 0, 0, 255, 255]))
    #expect(RFBEncoder.updateRequest(incremental: true, RFBRect(x: 1, y: 2, width: 3, height: 4)) == Data([3, 1, 0, 1, 0, 2, 0, 3, 0, 4]))
}

@Test func keysyms() {
    #expect(RFBKeysym.special(keyCode: 36) == 0xFF0D)
    #expect(RFBKeysym.special(keyCode: 0) == nil)
    #expect(RFBKeysym.modifier(keyCode: 55) == RFBKeysym.superL)
    #expect(RFBKeysym.keysym(forCharacters: "a") == 0x61)
    #expect(RFBKeysym.keysym(forCharacters: "é") == 0xE9)
    #expect(RFBKeysym.keysym(forCharacters: "€") == 0x0100_20AC)
    #expect(RFBKeysym.keysym(forCharacters: "\r") == nil)
    #expect(RFBKeysym.keysym(forCharacters: "\u{F700}") == nil)
}

// MARK: Session over a fake binary WebSocket

private final class FakeBinary: BinaryWebSocketConnection, @unchecked Sendable {
    private let lock = NSLock()
    private var frames: [Result<WebSocketFrame, Error>]
    private var _sent: [Data] = []
    private var _closed = false
    var sent: [Data] { lock.withLock { _sent } }
    var closed: Bool { lock.withLock { _closed } }
    init(_ f: [Result<WebSocketFrame, Error>]) { frames = f }
    func resume() {}
    func send(_ text: String) async throws {}
    func send(binary: Data) async throws { lock.withLock { _sent.append(binary) } }
    func receive() async throws -> WebSocketFrame {
        let next: Result<WebSocketFrame, Error>? = lock.withLock { frames.isEmpty ? nil : frames.removeFirst() }
        guard let next else { try await Task.sleep(for: .seconds(60)); throw CancellationError() }
        return try next.get()
    }
    func close() { lock.withLock { _closed = true } }
}

@Test func sessionRunsHandshakeAcrossSplitFramesAndSendsInput() async {
    let stream = versionMsg + [1, 1] + be32(0) + serverInit(w: 2, h: 1) + update([rectHeader(0, 0, 1, 1, enc: 0) + [5, 6, 7, 0]])
    let cut = stream.count / 2
    let fake = FakeBinary([.success(.binary(Data(stream[..<cut]))), .success(.binary(Data(stream[cut...]))),
                           .failure(URLError(.networkConnectionLost))])
    let s = RFBSession(connection: fake)
    var got: [RFBSession.Event] = []
    for await e in s.events { got.append(e) }
    #expect(got.count == 3)
    if case .ready(let n, 2, 1) = got[0] { #expect(n == "vm") } else { Issue.record("ready") }
    if case .frame(let fb, let dirty) = got[1] {
        #expect(Array(fb.pixels[0..<4]) == [5, 6, 7, 0]); #expect(dirty.width == 1)
    } else { Issue.record("frame") }
    if case .closed(let m) = got[2] { #expect(m != nil) } else { Issue.record("closed") }
    #expect(fake.sent.first == Data("RFB 003.008\n".utf8))
    #expect(fake.sent.contains(Data([3, 1, 0, 0, 0, 0, 0, 2, 0, 1])))
    #expect(fake.closed)
}

@Test func sessionClosesOnProtocolErrorAndSendsInput() async {
    let fake = FakeBinary([.success(.binary(Data("HTTP/1.1 400".utf8)))])
    let s = RFBSession(connection: fake)
    var got: [RFBSession.Event] = []
    for await e in s.events { got.append(e) }
    #expect(got.count == 1)
    if case .closed(let m) = got[0] { #expect(m != nil) } else { Issue.record("closed") }

    let fake2 = FakeBinary([])
    let s2 = RFBSession(connection: fake2)
    await s2.sendKey(keysym: 0x61, down: true)
    await s2.sendPointer(buttons: 1, x: 10, y: 20)
    await s2.close()
    #expect(fake2.sent == [Data([4, 1, 0, 0, 0, 0, 0, 0x61]), Data([5, 1, 0, 10, 0, 20])])
    #expect(fake2.closed)
}

@Test func sessionRejectsTextFrames() async {
    let s = RFBSession(connection: FakeBinary([.success(.text("hello"))]))
    var got: [RFBSession.Event] = []
    for await e in s.events { got.append(e) }
    if case .closed(let m)? = got.last { #expect(m != nil) } else { Issue.record("closed") }
}
