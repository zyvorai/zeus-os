import Testing
import Foundation
@testable import ZeusKit

// Request shapes only; contracts come from the server's dashboard bundle. No real server is contacted.

private final class GapRecorder: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var last: URLRequest?
    nonisolated(unsafe) static var body: Data?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        GapRecorder.last = request
        if let s = request.httpBodyStream {
            s.open(); defer { s.close() }
            var data = Data(); var buf = [UInt8](repeating: 0, count: 4096)
            while s.hasBytesAvailable { let n = s.read(&buf, maxLength: buf.count); if n <= 0 { break }; data.append(buf, count: n) }
            GapRecorder.body = data
        } else { GapRecorder.body = request.httpBody }
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: r, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data("{}".utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

@Suite(.serialized) struct SpecGaps {
    let client: ZeusClient
    init() {
        let cfg = URLSessionConfiguration.ephemeral
        cfg.protocolClasses = [GapRecorder.self]
        client = ZeusClient(baseURL: URL(string: "https://zeus.test")!, token: "t", session: URLSession(configuration: cfg))
        GapRecorder.last = nil; GapRecorder.body = nil
    }
    private var json: [String: Any]? { GapRecorder.body.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] } }
    private var url: String { GapRecorder.last?.url?.absoluteString ?? "" }
    private var method: String { GapRecorder.last?.httpMethod ?? "" }

    @Test func createNamespaceBudget() async throws {
        try await client.createBudget(.init(name: "web budget", scope: .namespace("web"), monthlyLimit: 500, channelIds: ["c1"]))
        #expect(method == "POST" && url == "https://zeus.test/api/v1/finops/budgets")
        let scope = json?["scope"] as? [String: String]
        #expect(scope == ["kind": "namespace", "name": "web"])
        #expect(json?["monthly_limit"] as? Double == 500)
        #expect(json?["thresholds"] as? [Int] == [50, 80, 100])
        #expect(json?["channel_ids"] as? [String] == ["c1"])
        #expect(json?["enabled"] as? Bool == true)
    }

    @Test func clusterScopeHasNoName() async throws {
        try await client.createBudget(.init(name: "all", scope: .cluster, monthlyLimit: 1))
        #expect((json?["scope"] as? [String: String]) == ["kind": "cluster"])
    }

    @Test func updateBudgetPutsSameBody() async throws {
        try await client.updateBudget(id: "b 1", .init(name: "t", scope: .tenant("acme"), monthlyLimit: 9, thresholds: [90], enabled: false))
        #expect(method == "PUT" && url == "https://zeus.test/api/v1/finops/budgets/b%201")
        #expect((json?["scope"] as? [String: String]) == ["kind": "tenant", "name": "acme"])
        #expect(json?["enabled"] as? Bool == false)
    }

    @Test func thresholdParsingMatchesDashboard() {
        #expect(try! BudgetInput.parseThresholds("80%, 50 100 50").get() == [50, 80, 100])
        #expect((try? BudgetInput.parseThresholds("").get()) == nil)
        #expect((try? BudgetInput.parseThresholds("0").get()) == nil)
        #expect((try? BudgetInput.parseThresholds("1001").get()) == nil)
        #expect((try? BudgetInput.parseThresholds("1 2 3 4 5 6").get()) == nil)
    }

    @Test func validation() {
        #expect(BudgetInput(name: " ", scope: .cluster, monthlyLimit: 1).validationMessage != nil)
        #expect(BudgetInput(name: "a", scope: .namespace(""), monthlyLimit: 1).validationMessage != nil)
        #expect(BudgetInput(name: "a", scope: .cluster, monthlyLimit: 0).validationMessage != nil)
        #expect(BudgetInput(name: "a", scope: .cluster, monthlyLimit: 2e9).validationMessage != nil)
        #expect(BudgetInput(name: "a", scope: .cluster, monthlyLimit: 10).validationMessage == nil)
    }

    @Test func scopeFromRow() {
        #expect(BudgetScope(json: .object(["kind": .string("tenant"), "name": .string("x")])) == .tenant("x"))
        #expect(BudgetScope(json: .object(["kind": .string("cluster")])) == .cluster)
        #expect(BudgetScope(json: nil) == nil)
    }

    @Test func helmRollbackSendsRevision() async throws {
        let r = try JSONDecoder().decode(HelmRelease.self, from: Data(#"{"name":"nginx","namespace":"web"}"#.utf8))
        try await client.helmRollback(r, toRevision: 3)
        #expect(method == "POST" && url == "https://zeus.test/api/v1/helm/releases/web/nginx/rollback")
        #expect(json?["revision"] as? Int == 3)
    }

    @Test func helmUninstallDeletesRelease() async throws {
        let r = try JSONDecoder().decode(HelmRelease.self, from: Data(#"{"name":"nginx","namespace":"web"}"#.utf8))
        try await client.helmUninstall(r)
        #expect(method == "DELETE" && url == "https://zeus.test/api/v1/helm/releases/web/nginx")
    }

    @Test func channelTestPostsToChannel() async throws {
        try await client.testNotificationChannel(id: "c/1")
        #expect(method == "POST" && url == "https://zeus.test/api/v1/notifications/channels/c%2F1/test")
    }
}
