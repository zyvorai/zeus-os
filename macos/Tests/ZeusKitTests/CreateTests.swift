import Testing
import Foundation
@testable import ZeusKit

// Fixtures trimmed from live GET responses.
@Test func decodesBuiltInTemplateWithEmptyNamespace() throws {
    let json = #"[{"id":"built-in/ubuntu-24.04-server","name":"ubuntu-24.04-server","namespace":"","display_name":"Ubuntu 24.04 Server","category":"linux","os_type":"linux","template_status":"approved","spec":{"cpu_cores":2,"memory_gi":4.0,"disk_size_gi":20.0,"golden_datavolume":null}}]"#
    let t = try JSONDecoder().decode(Listing<VMTemplateInfo>.self, from: Data(json.utf8)).items[0]
    #expect(t.isBuiltIn && t.title == "Ubuntu 24.04 Server" && t.cpuCores == 2 && t.memoryGi == 4.0)
}

@Test func decodesInstanceTypes() throws {
    let json = #"[{"name":"cx1.2xlarge","cpu_cores":8,"memory":"16Gi","gpu":null,"features":[],"created_at":"2026-11-03T00:55:55+00:00"}]"#
    let t = try JSONDecoder().decode(Listing<InstanceTypeInfo>.self, from: Data(json.utf8)).items[0]
    #expect(t.cpuCores == 8 && t.memory == "16Gi" && t.gpu == nil)
}

@Test func decodesPreflightWithBlockers() throws {
    let json = #"{"vm_name":"demo-alpine","namespace":"default","ready":false,"checks":[{"check":"vm_power","status":"ok","message":"VM is running"},{"check":"eviction_strategy","status":"warn","message":"No evictionStrategy"}],"blockers":["Cluster has only 1 node"],"pvc_issues":[],"remediation":"Add a second node","ai_risk_summary":null}"#
    let p = try JSONDecoder().decode(MigrationPreflight.self, from: Data(json.utf8))
    #expect(!p.ready && p.blockers.count == 1 && p.checks[1].status == "warn")
}

@Test func decodesEmptyMigrationsAndGroups() throws {
    #expect(try JSONDecoder().decode(Listing<MigrationInfo>.self, from: Data("[]".utf8)).items.isEmpty)
    #expect(try JSONDecoder().decode(Listing<VMGroup>.self, from: Data("[]".utf8)).items.isEmpty)
}

@Test func migrationBodyUsesServerKeys() throws {
    let data = try JSONEncoder().encode(MigrationBody(vmiName: "a", namespace: "default", targetNodeName: nil))
    let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    #expect(obj?["vmi_name"] as? String == "a" && obj?["namespace"] as? String == "default")
}
