import Testing
import Foundation
@testable import ZeusKit

// Write-request shapes only. Nothing here talks to a real server.

private final class OpsRecorder: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var last: URLRequest?
    nonisolated(unsafe) static var body: Data?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        OpsRecorder.last = request
        if let s = request.httpBodyStream {
            s.open(); defer { s.close() }
            var data = Data(); var buf = [UInt8](repeating: 0, count: 4096)
            while s.hasBytesAvailable { let n = s.read(&buf, maxLength: buf.count); if n <= 0 { break }; data.append(buf, count: n) }
            OpsRecorder.body = data
        } else { OpsRecorder.body = request.httpBody }
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: r, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data("{}".utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

private func dec<T: Decodable>(_ t: T.Type, _ s: String) throws -> T { try JSONDecoder().decode(t, from: Data(s.utf8)) }

@Suite(.serialized) struct OpsWrites {
    let client: ZeusClient
    init() {
        let cfg = URLSessionConfiguration.ephemeral
        cfg.protocolClasses = [OpsRecorder.self]
        client = ZeusClient(baseURL: URL(string: "https://zeus.test")!, token: "t", session: URLSession(configuration: cfg))
        OpsRecorder.last = nil; OpsRecorder.body = nil
    }
    private var json: [String: Any]? { OpsRecorder.body.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] } }
    private var url: String { OpsRecorder.last?.url?.absoluteString ?? "" }
    private var method: String { OpsRecorder.last?.httpMethod ?? "" }

    @Test func triggerWorkflowSendsEmptyInput() async throws {
        let w = try dec(Workflow.self, #"{"id":"wf-1"}"#)
        try await client.triggerWorkflow(w)
        #expect(method == "POST" && url == "https://zeus.test/api/v1/workflows/wf-1/trigger")
        #expect((json?["input"] as? [String: String])?.isEmpty == true)
    }

    @Test func cancelTask() async throws {
        try await client.cancelTask(try dec(OpsTask.self, #"{"id":"t 1"}"#))
        #expect(method == "POST" && url == "https://zeus.test/api/v1/tasks/t%201/cancel" && OpsRecorder.body == nil)
    }

    @Test func deleteScheduledOperation() async throws {
        try await client.deleteScheduledOperation(try dec(ScheduledOperation.self, #"{"id":"s1"}"#))
        #expect(method == "DELETE" && url == "https://zeus.test/api/v1/labs/scheduled-ops/s1")
    }

    @Test func resolveApprovalPatchesStatusAndComment() async throws {
        let a = try dec(ChangeApproval.self, #"{"id":"a1"}"#)
        try await client.resolveChangeApproval(a, .approved, comment: "  ok  ")
        #expect(method == "PATCH" && url == "https://zeus.test/api/v1/labs/change-approvals/a1")
        #expect(json?["status"] as? String == "approved" && json?["comment"] as? String == "ok")
        try await client.resolveChangeApproval(a, .rejected, comment: "  ")
        #expect(json?["status"] as? String == "rejected" && json?["comment"] == nil)
    }

    @Test func createClaimBody() async throws {
        try await client.createClaim(name: "data", namespace: "ns", sizeGi: 5, storageClass: "")
        #expect(method == "POST" && url == "https://zeus.test/api/v1/storage/claims")
        #expect(json?["name"] as? String == "data" && json?["namespace"] as? String == "ns"
                && json?["storage_gi"] as? Double == 5 && (json?["access_modes"] as? [String]) == ["ReadWriteOnce"]
                && json?["storage_class"] == nil)
    }

    @Test func resizeClaimBody() async throws {
        let c = try dec(StorageClaim.self, #"{"name":"data","namespace":"ns","requested_storage_gi":5}"#)
        try await client.resizeClaim(c, toGi: 8)
        #expect(method == "POST" && url == "https://zeus.test/api/v1/namespaces/ns/pvcs/data/resize")
        #expect(json?["new_size"] as? String == "8Gi" && json?.count == 1)
    }

    @Test func resizeIsGrowOnly() throws {
        let c = try dec(StorageClaim.self, #"{"name":"data","namespace":"ns","requested_storage_gi":5}"#)
        #expect(ZeusClient.isGrowth(of: c, toGi: 6))
        #expect(!ZeusClient.isGrowth(of: c, toGi: 5) && !ZeusClient.isGrowth(of: c, toGi: 4) && !ZeusClient.isGrowth(of: c, toGi: 0))
    }

    @Test func deleteVolumeSnapshot() async throws {
        let s = try dec(VolumeSnapshot.self, #"{"name":"snap","namespace":"ns","source_pvc":"data","ready_to_use":true,"created_at":"x"}"#)
        #expect(s.id == "ns/snap" && s.sourcePVC == "data")
        try await client.deleteVolumeSnapshot(s)
        #expect(method == "DELETE" && url == "https://zeus.test/api/v1/volumesnapshots/ns/snap")
    }

    @Test func createVeleroScheduleBody() async throws {
        try await client.createVeleroSchedule(VeleroScheduleBody(name: "nightly", schedule: "0 2 * * *",
                                                                 includedNamespaces: ["a", "b"], ttlHours: 720))
        #expect(method == "POST" && url == "https://zeus.test/api/v1/velero/schedules")
        #expect(json?["name"] as? String == "nightly" && json?["schedule"] as? String == "0 2 * * *"
                && (json?["included_namespaces"] as? [String]) == ["a", "b"]
                && (json?["excluded_namespaces"] as? [String]) == [] && json?["ttl_hours"] as? Int == 720
                && json?["snapshot_volumes"] == nil)
    }
}
