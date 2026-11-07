import Testing
import Foundation
@testable import ZeusKit

private func client(_ base: String = "http://127.0.0.1:15050", token: String? = "tok") -> ZeusClient {
    ZeusClient(baseURL: URL(string: base)!, token: token)
}

@Test func webSocketRequestSwapsSchemeAndAuthenticates() throws {
    let r = try client().webSocketRequest(path: ["serial", "default", "vm 1"],
                                          query: [URLQueryItem(name: "console_session", value: "a b")])
    #expect(r.url?.absoluteString == "ws://127.0.0.1:15050/ws/serial/default/vm%201?console_session=a%20b")
    #expect(r.value(forHTTPHeaderField: "Authorization") == "Bearer tok")
    #expect(r.value(forHTTPHeaderField: "Sec-WebSocket-Protocol") == "zeus-os-auth, tok")
}

@Test func webSocketRequestHttpsBecomesWssAndKeepsBasePath() throws {
    let r = try client("https://zeus.example:30050/prefix/").webSocketRequest(path: ["terminal"])
    #expect(r.url?.absoluteString == "wss://zeus.example:30050/prefix/ws/terminal")
}

@Test func webSocketRequestWithoutTokenHasNoAuth() throws {
    let r = try client(token: nil).webSocketRequest(path: ["terminal"])
    #expect(r.value(forHTTPHeaderField: "Authorization") == nil)
}

@Test func webSocketRequestRejectsOtherSchemes() {
    #expect(throws: ZeusError.self) { try client("ftp://x").webSocketRequest(path: ["a"]) }
}

@Test func terminalQueryOmitsEmptyContainer() {
    #expect(ZeusClient.terminalQuery(namespace: "n", pod: "p", container: "").count == 2)
    #expect(ZeusClient.terminalQuery(namespace: "n", pod: "p", container: "c").last?.value == "c")
}

@Test func graphicalConsoleURL() throws {
    let vm = try JSONDecoder().decode(VM.self, from: Data(#"{"name":"web","namespace":"prod","status":"Running"}"#.utf8))
    #expect(client().graphicalConsoleURL(for: vm)?.absoluteString == "http://127.0.0.1:15050/vms?vm=prod/web&console=1")
}

@Test func decodesAccessRequestAndGrantFromSchema() throws {
    let r = try JSONDecoder().decode([ConsoleAccessRequest].self, from: Data(#"[{"id":"1","user":"bob","namespace":"d","vmName":"v","mode":"serial","reason":"fix","status":"pending","createdAt":"2026-11-07T00:00:00Z","approvedBy":null}]"#.utf8))
    #expect(r[0].vmName == "v" && r[0].approvedBy == nil && r[0].breakGlass == nil)
    let g = try JSONDecoder().decode(Listing<ConsoleJitGrant>.self, from: Data(#"[{"id":"2","user":"a","namespace":"d","vmName":"v","mode":"vnc","expiresAt":"x","createdBy":"admin","createdAt":"y"}]"#.utf8))
    #expect(g.items[0].createdBy == "admin")
    #expect(try JSONDecoder().decode(Listing<ConsoleJitGrant>.self, from: Data("[]".utf8)).items.isEmpty)
}

@Test func decodesLivePod() throws {
    let p = try JSONDecoder().decode([PodSummary].self, from: Data(#"[{"name":"p","namespace":"n","status":"Running","containers":["c"],"shell_available":true,"pod_ip":"1.2.3.4"}]"#.utf8))
    #expect(p[0].id == "n/p" && p[0].containers == ["c"] && p[0].shellAvailable == true)
}

@Test func decodesSessionResponseToken() throws {
    let r = try JSONDecoder().decode(ConsoleSessionResponse.self, from: Data(#"{"session":{"token":"T","id":"x"},"ws_url":null}"#.utf8))
    #expect(r.session.token == "T")
}

// MARK: Terminal buffer

private func render(_ s: String) -> String {
    var b = TerminalBuffer(); b.feed(Data(s.utf8)); return b.text
}

@Test func bufferHandlesNewlinesAndCarriageReturn() {
    #expect(render("a\r\nb\rX") == "a\nX")
    #expect(render("one\ntwo") == "one\ntwo")
}

@Test func bufferHandlesBackspaceEcho() {
    #expect(render("ab\u{08} \u{08}c") == "ac")
}

@Test func bufferStripsColorAndOSC() {
    #expect(render("\u{1B}[1;32mok\u{1B}[0m \u{1B}]0;title\u{07}done") == "ok done")
}

@Test func bufferEraseToEndOfLine() {
    #expect(render("hello\u{1B}[3D\u{1B}[K!") == "he!")
}

@Test func bufferClearScreen() {
    #expect(render("junk\n\u{1B}[2Jhi") == "hi")
}

@Test func bufferReassemblesSplitUTF8() {
    var b = TerminalBuffer()
    let bytes = Array("é".utf8)
    b.feed(Data([bytes[0]]))
    #expect(b.text == "")
    b.feed(Data([bytes[1]]))
    #expect(b.text == "é")
}

@Test func bufferReassemblesSplitEscapeSequence() {
    var b = TerminalBuffer()
    b.feed(Data("a\u{1B}[3".utf8)); b.feed(Data("1mb".utf8))
    #expect(b.text == "ab")
}

@Test func bufferCapsScrollback() {
    var b = TerminalBuffer(maxLines: 3)
    b.feed(Data("1\n2\n3\n4\n5".utf8))
    #expect(b.lines.count == 3 && b.text == "3\n4\n5")
}

@Test func keyEncoding() {
    #expect(TerminalInput.encode(.enter) == "\r")
    #expect(TerminalInput.encode(.up) == "\u{1B}[A")
    #expect(TerminalInput.encode(.character("c"), control: true) == "\u{03}")
    #expect(TerminalInput.encode(.character("a")) == "a")
    #expect(TerminalInput.encode(.character("")) == nil)
}

// MARK: Session pump with a fake connection

private final class FakeConnection: WebSocketConnection, @unchecked Sendable {
    private let lock = NSLock()
    private var frames: [Result<WebSocketFrame, Error>]
    private(set) var sent: [String] = []
    private(set) var closed = false
    private(set) var resumed = false
    init(_ frames: [Result<WebSocketFrame, Error>]) { self.frames = frames }
    func resume() { lock.withLock { resumed = true } }
    func send(_ text: String) async throws { lock.withLock { sent.append(text) } }
    func receive() async throws -> WebSocketFrame {
        let next: Result<WebSocketFrame, Error>? = lock.withLock { frames.isEmpty ? nil : frames.removeFirst() }
        guard let next else { try await Task.sleep(for: .seconds(60)); throw CancellationError() }
        return try next.get()
    }
    func close() { lock.withLock { closed = true } }
}

@Test func sessionDeliversOutputThenCloseOnError() async {
    let fake = FakeConnection([.success(.text("hi")), .success(.binary(Data([0x21]))),
                               .failure(URLError(.networkConnectionLost))])
    let s = ConsoleSession(connection: fake)
    var got: [ConsoleSession.Event] = []
    for await e in s.events { got.append(e) }
    #expect(got.count == 3)
    #expect(got[0] == .output(Data("hi".utf8)) && got[1] == .output(Data([0x21])))
    if case .closed(let m) = got[2] { #expect(m != nil) } else { Issue.record("expected close") }
    #expect(fake.resumed)
}

@Test func sessionSendsInputAndClosesConnection() async throws {
    let fake = FakeConnection([])
    let s = ConsoleSession(connection: fake)
    try await s.send("ls\r")
    #expect(fake.sent == ["ls\r"])
    s.close()
    #expect(fake.closed)
}
