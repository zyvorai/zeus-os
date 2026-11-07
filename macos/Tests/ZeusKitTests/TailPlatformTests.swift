import Testing
import Foundation
@testable import ZeusKit

private func decode<T: Decodable>(_ t: T.Type, _ json: String) throws -> T {
    try JSONDecoder().decode(T.self, from: Data(json.utf8))
}

@Test func scrubDropsSecretsAtAnyDepthAndKeepsPlainSettings() throws {
    let s = try decode(ScrubbedJSON.self, #"""
    {"kubevirtLiveUpdateEnabled":true,"apiKey":"K1","client_secret":"S","password":"P","authToken":"T",
     "slackWebhookUrl":"https://hooks.slack.com/services/X/Y/Z","licenseKey":"AAAA-BBBB",
     "migrationEngines":{"transivaUrl":"https://203.0.113.5:5080","dsn":"postgres://u:pw@db/x","accessKey":"A"},
     "list":["https://hooks.slack.com/services/Q","ok"]}
    """#).value
    #expect(s["kubevirtLiveUpdateEnabled"]?.bool == true)
    for k in ["apiKey", "client_secret", "password", "authToken", "slackWebhookUrl", "licenseKey"] { #expect(s[k] == nil) }
    #expect(s["migrationEngines"]?["transivaUrl"]?.string == "https://203.0.113.5:5080")
    #expect(s["migrationEngines"]?["dsn"] == nil && s["migrationEngines"]?["accessKey"] == nil)
    #expect(s["list"]?.array == [.string("ok")])
    let all = String(decoding: try JSONEncoder().encode(s), as: UTF8.self)
    for bad in ["K1", "AAAA-BBBB", "hooks.slack", "pw@"] { #expect(!all.contains(bad)) }
}

// Live responses, trimmed.
@Test func decodesLiveServerStatsPreflightOnboarding() throws {
    let st = try decode(ServerStats.self, #"{"requests_total":5478,"errors_total":181,"avg_latency_ms":119,"active_ws":0,"uptime_secs":20627,"requests_per_sec":0.26,"active_sessions":41,"top_client_ip":"10.0.0.1","top_ips":[]}"#)
    #expect(st.requestsTotal == 5478 && st.activeSessions == 41)
    let p = try decode(PlatformPreflight.self, #"{"veleroInstalled":true,"volumeSnapshotClassCount":2,"csiSnapshotCrdPresent":true,"hints":["a"],"warnings":[],"defaultStorageClass":null,"defaultVolumeSnapshotClass":"snap","metallbApiPresent":false,"metallbAddressPoolCount":0,"snapshotControllerReady":true,"stuckVolumeSnapshots":0}"#)
    #expect(p.veleroInstalled == true && p.defaultStorageClass == nil && p.defaultVolumeSnapshotClass == "snap" && p.hints == ["a"])
    let o = try decode(OnboardingState.self, #"{"username":"admin","completed_task_ids":["a"],"tour_completed":false,"banner_dismissed":false,"first_seen_at":"2026-01-01T00:00:00Z"}"#)
    #expect(o.completedTaskIds == ["a"] && !o.tourCompleted)
}

// Live inventory had no VMs; the row is spec-shaped (free-form) and its key-like fields must be dropped.
@Test func licensingInventoryScrubsRows() throws {
    let l = try decode(LicensingInventory.self, #"{"total_windows_vms":1,"agent_connected":1,"activated":0,"kms_clients":0,"vms":[{"name":"w1","product_key":"X","status":"unlicensed"}]}"#)
    #expect(l.totalWindowsVMs == 1 && l.vms[0]["name"]?.string == "w1" && l.vms[0]["product_key"] == nil)
}

@Test func decodesLiveClientConfigDashboardAndVersioningAsScrubbedJSON() throws {
    let c = try decode(ScrubbedJSON.self, #"{"prometheusUrl":null,"platform":{"defaultStorageClass":null},"migrationEngines":{"transivaUrl":"https://203.0.113.5:5080","guestkitConfigured":false}}"#).value
    #expect(c["migrationEngines"]?["guestkitConfigured"]?.bool == false)
    let v = try decode(ScrubbedJSON.self, #"[{"version_id":"core/v1","version":"v1","status":"stable","release_date":"","deprecation_date":null,"is_default":true,"endpoint_count":17,"active_clients":0}]"#).value
    #expect(v[0]?["endpoint_count"]?.number == 17)
    // Empty live lists (ACLs, gateway-api, platform profiles, deprecations) decode as empty arrays.
    #expect(try decode(ScrubbedJSON.self, "[]").value == .array([]))
    let h = try decode(ScrubbedJSON.self, #"{"groups":[],"ungrouped":[{"name":"n1","status":"Ready"}]}"#).value
    #expect(h["ungrouped"]?[0]?["name"]?.string == "n1")
    let s = try decode(ScrubbedJSON.self, #"[{"id":"vm/default/a","category":"vm","title":"a","score":21.0}]"#).value
    #expect(s[0]?["category"]?.string == "vm")
}

@Test func graphQLCapabilitiesFromSchemaText() {
    let g = GraphQLCapabilities(schema: """
    type Query {
      \"\"\"List all KubeVirt virtual machines.\"\"\"
      virtualMachines: [VirtualMachine!]!

      version: String!
    }

    type Node {
      name: String!
    }
    """)
    #expect(g.queryFields.map(\.name) == ["virtualMachines", "version"])
    #expect(g.queryFields[0].summary == "List all KubeVirt virtual machines.")
    #expect(g.typeNames == ["Query", "Node"])
}
