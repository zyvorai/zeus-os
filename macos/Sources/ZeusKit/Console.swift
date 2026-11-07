import Foundation

// MARK: REST models (read-only lists)

/// `GET /console/access-requests`.
public struct ConsoleAccessRequest: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let user: String
    public let namespace: String
    public let vmName: String
    public let mode: String
    public let reason: String
    public let status: String
    public let breakGlass: Bool?
    public let approvedBy: String?
    public let approvedAt: String?
    public let createdAt: String
}

/// `GET /console/jit-grants`.
public struct ConsoleJitGrant: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let user: String
    public let namespace: String
    public let vmName: String
    public let mode: String
    public let expiresAt: String
    public let createdBy: String
    public let createdAt: String
}

/// Pod from `GET /pods`, just enough to pick a terminal target.
public struct PodSummary: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String
    public let status: String?
    public let containers: [String]?
    public let shellAvailable: Bool?
    public var id: String { "\(namespace)/\(name)" }

    enum CodingKeys: String, CodingKey {
        case name, namespace, status, containers
        case shellAvailable = "shell_available"
    }
}

extension ZeusClient {
    public func consoleAccessRequests() async throws -> [ConsoleAccessRequest] { try await list("console", "access-requests") }
    public func consoleJitGrants() async throws -> [ConsoleJitGrant] { try await list("console", "jit-grants") }
    public func pods() async throws -> [PodSummary] { try await list("pods") }
}

// MARK: Session creation (POST /console/sessions/{ns}/{name})

struct ConsoleSessionResponse: Decodable, Sendable {
    struct Session: Decodable, Sendable { let token: String }
    let session: Session
}

private struct ConsoleSessionBody: Encodable {
    let mode: String
    let viewOnly: Bool
    enum CodingKeys: String, CodingKey { case mode, viewOnly = "view_only" }
}

extension ZeusClient {
    /// Asks the server for a console session and returns its token, which the dashboard appends to
    /// the WebSocket URL as `console_session`. Never exercised against a live server.
    func createConsoleSession(namespace: String, name: String, mode: String) async throws -> String {
        let r: ConsoleSessionResponse = try await post("console", "sessions", namespace, name,
                                                       body: ConsoleSessionBody(mode: mode, viewOnly: false))
        return r.session.token
    }

    static func serialRequestQuery(token: String) -> [URLQueryItem] { [URLQueryItem(name: "console_session", value: token)] }

    static func terminalQuery(namespace: String, pod: String, container: String?) -> [URLQueryItem] {
        var q = [URLQueryItem(name: "namespace", value: namespace), URLQueryItem(name: "pod", value: pod)]
        if let container, !container.isEmpty { q.append(URLQueryItem(name: "container", value: container)) }
        return q
    }

    /// Serial console for a VM: creates a session, then connects `/ws/serial/{ns}/{name}?console_session=`.
    public func openSerialConsole(of vm: VM) async throws -> ConsoleSession {
        let token = try await createConsoleSession(namespace: vm.namespace, name: vm.name, mode: "serial")
        let req = try webSocketRequest(path: ["serial", vm.namespace, vm.name], query: Self.serialRequestQuery(token: token))
        return ConsoleSession(connection: URLSessionWebSocketConnection(task: webSocketSession.webSocketTask(with: req)))
    }

    /// Cluster pod terminal: `/ws/terminal?namespace=&pod=&container=`.
    public func openPodTerminal(namespace: String, pod: String, container: String?) throws -> ConsoleSession {
        let req = try webSocketRequest(path: ["terminal"], query: Self.terminalQuery(namespace: namespace, pod: pod, container: container))
        return ConsoleSession(connection: URLSessionWebSocketConnection(task: webSocketSession.webSocketTask(with: req)))
    }

    /// Dashboard page that hosts the graphical (VNC) console; the user signs in there if needed.
    public func graphicalConsoleURL(for vm: VM) -> URL? {
        guard var c = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else { return nil }
        let prefix = c.percentEncodedPath.hasSuffix("/") ? String(c.percentEncodedPath.dropLast()) : c.percentEncodedPath
        c.percentEncodedPath = prefix + "/vms"
        c.queryItems = [URLQueryItem(name: "vm", value: vm.id), URLQueryItem(name: "console", value: "1")]
        return c.url
    }

    // MARK: WebSocket request

    /// Subprotocol the web dashboard offers (followed by the JWT) because browsers can't set headers.
    public static let webSocketAuthProtocol = "zeus-os-auth"

    /// Builds a request for a `/ws/...` route (these live at the server root, not under `/api/v1`).
    /// `ws`/`wss` replaces `http`/`https`. Authentication goes both as a Bearer header and as the
    /// dashboard's `zeus-os-auth, <token>` subprotocol offer; which one the server honours was not
    /// verified (consoles are never opened against the shared server).
    public func webSocketRequest(path: [String], query: [URLQueryItem] = []) throws -> URLRequest {
        guard var comps = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw ZeusError.transport(URLError(.badURL))
        }
        switch comps.scheme?.lowercased() {
        case "https", "wss": comps.scheme = "wss"
        case "http", "ws": comps.scheme = "ws"
        default: throw ZeusError.transport(URLError(.unsupportedURL))
        }
        let prefix = comps.percentEncodedPath.hasSuffix("/")
            ? String(comps.percentEncodedPath.dropLast()) : comps.percentEncodedPath
        comps.percentEncodedPath = "\(prefix)/ws/\(Self.path(path))"
        if !query.isEmpty { comps.queryItems = query }
        guard let url = comps.url else { throw ZeusError.transport(URLError(.badURL)) }
        var req = URLRequest(url: url)
        if let token = bearerToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            req.setValue("\(Self.webSocketAuthProtocol), \(token)", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        }
        return req
    }
}

// MARK: WebSocket seam

public enum WebSocketFrame: Sendable, Equatable { case text(String), binary(Data) }

/// The slice of `URLSessionWebSocketTask` a console needs; tests substitute a fake.
public protocol WebSocketConnection: Sendable {
    func resume()
    func send(_ text: String) async throws
    func receive() async throws -> WebSocketFrame
    func close()
}

final class URLSessionWebSocketConnection: WebSocketConnection, @unchecked Sendable {
    private let task: URLSessionWebSocketTask
    init(task: URLSessionWebSocketTask) { self.task = task }
    func resume() { task.resume() }
    func send(_ text: String) async throws { try await task.send(.string(text)) }
    func receive() async throws -> WebSocketFrame {
        switch try await task.receive() {
        case .string(let s): .text(s)
        case .data(let d): .binary(d)
        @unknown default: .binary(Data())
        }
    }
    func close() { task.cancel(with: .normalClosure, reason: nil) }
}

/// Pumps one connection: output becomes `events`, input goes through `send`.
public final class ConsoleSession: Sendable {
    public enum Event: Sendable, Equatable { case output(Data), closed(String?) }

    private let connection: any WebSocketConnection
    public let events: AsyncStream<Event>

    public init(connection: any WebSocketConnection) {
        self.connection = connection
        events = AsyncStream { continuation in
            let pump = Task {
                connection.resume()
                do {
                    while !Task.isCancelled {
                        switch try await connection.receive() {
                        case .text(let s): continuation.yield(.output(Data(s.utf8)))
                        case .binary(let d): continuation.yield(.output(d))
                        }
                    }
                    continuation.yield(.closed(nil))
                } catch {
                    continuation.yield(.closed(Task.isCancelled ? nil : error.localizedDescription))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in pump.cancel(); connection.close() }
        }
    }

    public func send(_ text: String) async throws { try await connection.send(text) }
    public func close() { connection.close() }
}

// MARK: Terminal screen model

/// Interprets console output into text lines. Handles CR/LF/backspace/tab, erase-to-end-of-line,
/// cursor left/right and clear-screen; every other escape sequence is dropped. Full-screen programs
/// (vim, top) are not supported: this is a line-oriented view, not a terminal emulator.
public struct TerminalBuffer: Sendable, Equatable {
    public private(set) var lines: [[Character]] = [[]]
    public private(set) var column = 0
    public let maxLines: Int

    private enum Esc: Equatable { case none, escape, csi(String), osc }
    private var esc = Esc.none
    private var pending = Data()

    public init(maxLines: Int = 5000) { self.maxLines = maxLines }

    public var text: String { lines.map { String($0) }.joined(separator: "\n") }

    public mutating func feed(_ data: Data) {
        pending.append(data)
        // Hold back an incomplete trailing UTF-8 sequence until the rest arrives.
        var cut = pending.count
        var i = pending.count - 1, back = 0
        while i >= 0, back < 4 {
            let b = pending[pending.startIndex + i]
            if b & 0xC0 == 0x80 { i -= 1; back += 1; continue }
            let need = b >= 0xF0 ? 4 : b >= 0xE0 ? 3 : b >= 0xC0 ? 2 : 1
            if need > back + 1 { cut = i }
            break
        }
        let ready = Data(pending.prefix(cut))
        pending = Data(pending.dropFirst(cut))
        for ch in String(decoding: ready, as: UTF8.self) { put(ch) }
    }

    public mutating func clear() { lines = [[]]; column = 0; esc = .none }

    private mutating func put(_ ch: Character) {
        switch esc {
        case .escape:
            switch ch { case "[": esc = .csi(""); case "]": esc = .osc; default: esc = .none }
            return
        case .csi(let params):
            if let a = ch.asciiValue, (0x40...0x7E).contains(a) { esc = .none; csi(params, final: ch) }
            else { esc = .csi(params + String(ch)) }
            return
        case .osc:
            if ch == "\u{07}" { esc = .none }
            else if ch == "\u{1B}" { esc = .escape }   // ST is ESC \, whose "\" then ends the sequence
            return
        case .none: break
        }
        switch ch {
        case "\u{1B}": esc = .escape
        case "\r\n": newline()
        case "\n": newline()
        case "\r": column = 0
        case "\u{08}": column = max(0, column - 1)
        case "\t": for _ in 0..<(8 - column % 8) { write(" ") }
        case "\u{07}": break
        default:
            if ch.unicodeScalars.allSatisfy({ $0.value >= 0x20 && $0.value != 0x7F }) { write(ch) }
        }
    }

    /// A bare LF also returns to column 0: serial consoles send CRLF, but a pty without ONLCR does not.
    private mutating func newline() {
        lines.append([])
        column = 0
        if lines.count > maxLines { lines.removeFirst(lines.count - maxLines) }
    }

    private mutating func write(_ ch: Character) {
        let last = lines.count - 1
        if column < lines[last].count { lines[last][column] = ch }
        else { while lines[last].count < column { lines[last].append(" ") }; lines[last].append(ch) }
        column += 1
    }

    private mutating func csi(_ params: String, final: Character) {
        let n = Int(params.split(separator: ";").first.map(String.init) ?? "") ?? 0
        let last = lines.count - 1
        switch final {
        case "K":
            switch n {
            case 0: if column < lines[last].count { lines[last].removeSubrange(column...) }
            case 2: lines[last] = []
            default: break
            }
        case "C": column += max(1, n)
        case "D": column = max(0, column - max(1, n))
        case "J": if n == 2 || n == 3 { clear() }
        default: break
        }
    }
}

// MARK: Keyboard input

public enum TerminalKey: Sendable, Equatable {
    case character(String), enter, backspace, tab, escape
    case up, down, right, left, home, end, delete
}

public enum TerminalInput {
    /// What to send for a key. `control` turns letters into C0 codes (Ctrl-C = 0x03).
    public static func encode(_ key: TerminalKey, control: Bool = false) -> String? {
        switch key {
        case .enter: return "\r"
        case .backspace: return "\u{7F}"
        case .tab: return "\t"
        case .escape: return "\u{1B}"
        case .up: return "\u{1B}[A"
        case .down: return "\u{1B}[B"
        case .right: return "\u{1B}[C"
        case .left: return "\u{1B}[D"
        case .home: return "\u{1B}[H"
        case .end: return "\u{1B}[F"
        case .delete: return "\u{1B}[3~"
        case .character(let s):
            guard !s.isEmpty else { return nil }
            guard control, s.unicodeScalars.count == 1, let u = s.lowercased().unicodeScalars.first else { return s }
            switch u.value {
            case 0x61...0x7A: return String(UnicodeScalar(u.value - 0x60)!)
            case 0x5B: return "\u{1B}"
            case 0x5C: return "\u{1C}"
            case 0x5D: return "\u{1D}"
            default: return s
            }
        }
    }
}
