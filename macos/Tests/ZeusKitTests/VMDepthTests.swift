import Testing
import Foundation
@testable import ZeusKit

// Fixtures are real responses from a live server (GET only); the cloud-init user-data is shortened
// because the live one contained a credential.

private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
    try JSONDecoder().decode(T.self, from: Data(json.utf8))
}

@Test func decodesDisks() throws {
    let json = #"[{"name":"rootdisk","namespace":"default","size":"N/A","storage_class":null,"access_mode":"ReadOnly","disk_type":"containerdisk","status":"Ready","used_by":["demo-alpine"],"bus":"virtio","is_cdrom":false},{"name":"cloudinitdisk","namespace":"default","size":"N/A","storage_class":null,"access_mode":"ReadOnly","disk_type":"cloudinit","status":"Ready","used_by":["demo-alpine"],"bus":"virtio","is_cdrom":false}]"#
    let d = try decode(Listing<VMDisk>.self, json).items
    #expect(d.count == 2 && d[0].diskType == "containerdisk" && d[0].storageClass == nil && d[0].usedBy == ["demo-alpine"])
}

@Test func decodesGuestInfoWithoutAgent() throws {
    let json = #"{"hostname":null,"os_name":null,"os_version":null,"kernel_version":null,"architecture":null,"timezone":null,"filesystems":[],"interfaces":[{"name":"default","mac":"5a:85:ad:cc:fe:41","ip_addresses":["10.42.0.11"]}],"agent_connected":false}"#
    let g = try decode(GuestInfo.self, json)
    #expect(!g.agentConnected && g.osName == nil && g.interfaces[0].ipAddresses == ["10.42.0.11"])
}

@Test func guestInfoToleratesEmptyObject() throws {
    let g = try decode(GuestInfo.self, "{}")
    #expect(g.interfaces.isEmpty && !g.agentConnected)
}

@Test func decodesChanges() throws {
    let json = #"{"current_generation":1,"resource_version":"1651194","last_modified":"2026-11-03T09:44:56Z","changes":[{"timestamp":"2026-11-03T09:44:56Z","change_type":"status_change","description":"Ready → True ()","source":"condition"}]}"#
    let c = try decode(VMChanges.self, json)
    #expect(c.currentGeneration == 1 && c.changes[0].changeType == "status_change" && c.changes[0].source == "condition")
}

@Test func decodesCloudInit() throws {
    let json = ##"{"user_data":"#cloud-config\npackages:\n  - curl\n","network_data":null,"meta_data":null,"source_type":"cloudInitNoCloud"}"##
    let c = try decode(CloudInitConfig.self, json)
    #expect(c.userData?.hasPrefix("#cloud-config") == true && c.networkData == nil && c.sourceType == "cloudInitNoCloud")
}

@Test func guestAgentNetworkInterfacesDecodeAsJSONValue() throws {
    let json = #"{"count":1,"interfaces":[{"ip_addresses":["10.42.0.11"],"mac":"5a:85:ad:cc:fe:41","name":"default"}],"vmi_running":true}"#
    let v = try decode(JSONValue.self, json)
    #expect(v["interfaces"]?[0]?["name"]?.string == "default")
}

// MARK: Write-request shapes (never sent to a real server)

private final class Recorder: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var last: URLRequest?
    nonisolated(unsafe) static var body: Data?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        Recorder.last = request
        if let s = request.httpBodyStream {
            s.open(); defer { s.close() }
            var data = Data(); var buf = [UInt8](repeating: 0, count: 4096)
            while s.hasBytesAvailable { let n = s.read(&buf, maxLength: buf.count); if n <= 0 { break }; data.append(buf, count: n) }
            Recorder.body = data
        } else { Recorder.body = request.httpBody }
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: r, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data("{}".utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

@Suite(.serialized) struct VMDepthWrites {
    let client: ZeusClient
    let vm = try! JSONDecoder().decode(VM.self, from: Data(#"{"name":"a b","namespace":"ns","status":"Running"}"#.utf8))

    init() {
        let cfg = URLSessionConfiguration.ephemeral
        cfg.protocolClasses = [Recorder.self]
        client = ZeusClient(baseURL: URL(string: "https://zeus.test")!, token: "t", session: URLSession(configuration: cfg))
        Recorder.last = nil; Recorder.body = nil
    }

    private var json: [String: Any]? { Recorder.body.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] } }

    @Test func pauseUnpauseAndDelete() async throws {
        try await client.pause(vm)
        #expect(Recorder.last?.httpMethod == "POST" && Recorder.last?.url?.absoluteString == "https://zeus.test/api/v1/vms/ns/a%20b/pause")
        try await client.unpause(vm)
        #expect(Recorder.last?.url?.path.hasSuffix("/unpause") == true)
        try await client.deleteVM(vm)
        #expect(Recorder.last?.httpMethod == "DELETE" && Recorder.last?.url?.absoluteString == "https://zeus.test/api/v1/vms/ns/a%20b")
    }

    @Test func cloneBody() async throws {
        try await client.clone(vm, as: "copy", cloneDisks: true, start: false)
        #expect(Recorder.last?.httpMethod == "POST" && Recorder.last?.url?.path.hasSuffix("/clone") == true)
        #expect(json?["new_name"] as? String == "copy" && json?["clone_disks"] as? Bool == true
                && json?["start_after_clone"] as? Bool == false && json?["new_namespace"] == nil)
    }

    @Test func cloneFromSnapshotBody() async throws {
        try await client.cloneFromSnapshot(vm, snapshot: "snap1", as: "copy", start: true)
        #expect(Recorder.last?.url?.path.hasSuffix("/clone-from-snapshot") == true)
        #expect(json?["snapshot_name"] as? String == "snap1" && json?["new_name"] as? String == "copy"
                && json?["start_after_clone"] as? Bool == true)
    }

    @Test func cloudInitPutSendsOnlyUserData() async throws {
        try await client.saveCloudInit(userData: "#cloud-config\n", for: vm)
        #expect(Recorder.last?.httpMethod == "PUT" && Recorder.last?.url?.path.hasSuffix("/cloud-init") == true)
        #expect(json?["user_data"] as? String == "#cloud-config\n" && json?.count == 1)
    }
}
