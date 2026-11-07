import Testing
import Foundation
@testable import ZeusKit

// GET fixtures are trimmed from live responses. Every write below is checked against a stubbed
// URLSession; no write was ever sent to a real server.

private final class WriteRecorder: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var last: URLRequest?
    nonisolated(unsafe) static var body: Data?
    nonisolated(unsafe) static var reply = "{}"
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        WriteRecorder.last = request
        if let s = request.httpBodyStream {
            s.open(); defer { s.close() }
            var data = Data(); var buf = [UInt8](repeating: 0, count: 4096)
            while s.hasBytesAvailable { let n = s.read(&buf, maxLength: buf.count); if n <= 0 { break }; data.append(buf, count: n) }
            WriteRecorder.body = data
        } else { WriteRecorder.body = request.httpBody }
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: r, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(WriteRecorder.reply.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

private func vm(_ name: String, _ ns: String = "default") -> VM {
    try! JSONDecoder().decode(VM.self, from: Data(#"{"name":"\#(name)","namespace":"\#(ns)","status":"Running","tags":["os=alpine","os.version=3.19"]}"#.utf8))
}

@Suite(.serialized) struct VMWriteRequests {
    let client: ZeusClient
    init() {
        let cfg = URLSessionConfiguration.ephemeral
        cfg.protocolClasses = [WriteRecorder.self]
        client = ZeusClient(baseURL: URL(string: "https://zeus.test")!, token: "t", session: URLSession(configuration: cfg))
        WriteRecorder.last = nil; WriteRecorder.body = nil; WriteRecorder.reply = "{}"
    }
    private var json: [String: Any]? { WriteRecorder.body.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] } }

    @Test func bulkBodyAndPartialFailure() async throws {
        WriteRecorder.reply = #"{"operation_id":"x","total":2,"succeeded":1,"failed":1,"results":[{"name":"a","namespace":"default","success":true,"message":"ok"},{"name":"b","namespace":"default","success":false,"message":"forbidden"}]}"#
        let r = try await client.bulk(.stop, on: [vm("a"), vm("b")])
        #expect(WriteRecorder.last?.httpMethod == "POST" && WriteRecorder.last?.url?.absoluteString == "https://zeus.test/api/v1/vms/bulk")
        #expect(json?["action"] as? String == "stop")
        let targets = json?["vms"] as? [[String: String]]
        #expect(targets == [["name": "a", "namespace": "default"], ["name": "b", "namespace": "default"]])
        #expect(r.total == 2 && r.failed == 1 && r.failures.map(\.name) == ["b"] && r.failures[0].message == "forbidden")
    }

    @Test func applyLabelsBody() async throws {
        try await client.applyLabels(set: ["env": "prod"], remove: ["os"], on: [vm("a")])
        #expect(WriteRecorder.last?.url?.absoluteString == "https://zeus.test/api/v1/vms/labels/apply")
        #expect((json?["labels"] as? [String: String]) == ["env": "prod"] && (json?["remove_labels"] as? [String]) == ["os"])
        try await client.applyLabels(set: [:], remove: [], on: [vm("a")])
        #expect((json?["labels"] as? [String: String]) == [:] && json?["remove_labels"] == nil)
    }

    @Test func createFromYamlBody() async throws {
        try await client.createVM(yaml: "kind: VirtualMachine\n")
        #expect(WriteRecorder.last?.httpMethod == "POST" && WriteRecorder.last?.url?.absoluteString == "https://zeus.test/api/v1/vms")
        #expect(json?["yaml"] as? String == "kind: VirtualMachine\n" && json?.count == 1)
    }

    @Test func instantiateNamespacedTemplate() async throws {
        let t = try JSONDecoder().decode(VMTemplateInfo.self, from: Data(#"{"id":"team/web server","name":"web server","namespace":"team"}"#.utf8))
        try await client.instantiate(t, name: "w1", namespace: "default", diskSizeGi: 30)
        #expect(WriteRecorder.last?.url?.absoluteString == "https://zeus.test/api/v1/templates/team/web%20server/instantiate")
        #expect(json?["template_id"] as? String == "team/web server" && json?["vm_name"] as? String == "w1" && json?["namespace"] as? String == "default")
        #expect((json?["customize"] as? [String: Any])?["disk_size_gi"] as? Double == 30)
    }

    @Test func builtInTemplateIsRefusedWithoutARequest() async throws {
        let t = try JSONDecoder().decode(VMTemplateInfo.self, from: Data(#"{"id":"built-in/x","name":"x","namespace":""}"#.utf8))
        await #expect(throws: ZeusError.self) { try await client.instantiate(t, name: "w", namespace: "default", diskSizeGi: nil) }
        #expect(WriteRecorder.last == nil)
    }
}

@Test func decodesNamespacesAndPreferences() throws {
    let ns = try JSONDecoder().decode(Listing<NamespaceInfo>.self, from: Data(#"[{"name":"default","status":"Active","labels":{"a":"b"}}]"#.utf8)).items
    #expect(ns[0].name == "default" && ns[0].status == "Active")
    let p = try JSONDecoder().decode(Listing<InstancePreferenceInfo>.self, from: Data(#"[{"name":"alpine","preferred_cpu_topology":"","features":[]}]"#.utf8)).items
    #expect(p[0].name == "alpine")
}

@Test func parsesTags() {
    let l = VMLabels.parse(["os.version=3.19", "plain", "k=a=b"])
    #expect(l[0].key == "os.version" && l[0].value == "3.19" && l[1].value == "" && l[2].value == "a=b")
    #expect(VMLabels.validKey("app.kubernetes.io/name") && !VMLabels.validKey("bad key") && !VMLabels.validKey(""))
    #expect(VMLabels.validValue("") && VMLabels.validValue("3.19") && !VMLabels.validValue("a b"))
}

@Test func manifestIsGeneratedAndGuarded() throws {
    let y = try #require(NewMachineManifest.yaml(name: "web-1", namespace: "default", instanceType: "cx1.medium",
                                                 preference: "alpine", diskSizeGi: 20, image: nil))
    #expect(y.contains("name: web-1\n") && y.contains("name: cx1.medium\n") && y.contains("name: alpine\n"))
    #expect(y.contains("storage: 20Gi") && y.contains("blank: {}") && y.contains("name: web-1-rootdisk"))
    let withImage = try #require(NewMachineManifest.yaml(name: "w", namespace: "d", instanceType: "u1.small", preference: nil,
                                                         diskSizeGi: 10, image: "quay.io/containerdisks/fedora:latest"))
    #expect(withImage.contains("url: \"docker://quay.io/containerdisks/fedora:latest\"") && !withImage.contains("preference:"))
    // Injection attempts and bad values produce nothing.
    #expect(NewMachineManifest.yaml(name: "Bad Name", namespace: "d", instanceType: "x", preference: nil, diskSizeGi: 5, image: nil) == nil)
    #expect(NewMachineManifest.yaml(name: "a", namespace: "d", instanceType: "x\nkind: Evil", preference: nil, diskSizeGi: 5, image: nil) == nil)
    #expect(NewMachineManifest.yaml(name: "a", namespace: "d", instanceType: "x", preference: nil, diskSizeGi: 5, image: "a\"\nb") == nil)
    #expect(NewMachineManifest.yaml(name: "a", namespace: "d", instanceType: "x", preference: nil, diskSizeGi: 0, image: nil) == nil)
}
