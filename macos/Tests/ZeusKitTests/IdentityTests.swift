import Testing
import Foundation
@testable import ZeusKit

private func decode<T: Decodable>(_ t: T.Type, _ json: String) throws -> T {
    try JSONDecoder().decode(T.self, from: Data(json.utf8))
}

@Test func decodesLiveUsersAndSessions() throws {
    let u = try decode([AuthUser].self, #"[{"username":"admin","role":"admin"}]"#)
    #expect(u[0].role == "admin")
    let s = try decode([AuthSession].self, #"[{"session_id":"a7febfe2-c698-45b8-8ef5-9f7e84ca51dc","subject":"admin","role":"admin","created_at_secs":1794058800}]"#)
    #expect(s[0].created != nil && s[0].id.hasPrefix("a7febfe2"))
}

// Live token list was empty; this row is a guess at the free-form schema and must ignore any secret value.
@Test func apiTokenIgnoresValueAndToleratesShape() throws {
    let t = try decode([APIToken].self, #"[{"name":"ci","token":"SECRET","scopes":["vm:read"],"last_used_at":null}]"#)
    #expect(t[0].name == "ci" && t[0].scopes == ["vm:read"] && t[0].lastUsedAt == nil)
    let odd = try decode([APIToken].self, #"[{"scopes":"all"}]"#)
    #expect(odd[0].scopes.isEmpty)
}

@Test func decodesLiveFleet() throws {
    let f = try decode(FleetEnvelope.self, #"{"clusters":[{"name":"local","api_endpoint":"https://kubernetes.default.svc","cluster_type":"Local","region":null,"is_local":true,"status":"connected","health":"connected","health_reason":null,"owner_tenant":null,"version":"v1.35.5+k3s1","nodes":1,"ready_nodes":1,"vms":2,"running_vms":2,"cpu_cores":12.0,"memory_gb":30.68,"health_score":100.0,"stats_errors":[],"probe":null,"credential":null,"created_at":null}],"registry_error":null,"disabled":false}"#)
    #expect(f.clusters?[0].isLocal == true && f.clusters?[0].readyNodes == 1)
    let s = try decode(FleetStats.self, #"{"total_clusters":1,"connected_clusters":1,"failing_clusters":0,"total_nodes":1,"total_vms":2,"total_cpu_cores":12.0,"total_memory_gb":30.6,"clusters_by_type":{"Local":1}}"#)
    #expect(s.totalVMs == 2)
}

@Test func decodesLiveNodesAndHost() throws {
    let n = try decode([ClusterNode].self, #"[{"name":"node-1","status":"Ready","roles":["control-plane"],"age":"11d 21h","version":"v1.35.5+k3s1","cpu_capacity":"12","memory_capacity":"32178144Ki","schedulable":true}]"#)
    #expect(n[0].roles == ["control-plane"] && n[0].memoryBytes == 32178144 * 1024)
    let h = try decode(HostInfo.self, #"{"hostname":"zeus-os-pod","kernel_version":"7.0.0-38-generic","os_pretty_name":"Debian GNU/Linux 12 (bookworm)","architecture":"x86_64","cpu_model":"Intel(R) Xeon(R)","cpu_cores":12,"cpu_threads":12,"virtualization":"none","bios_vendor":"Dell Inc.","bios_version":"1.6.3","board_name":"x","system_vendor":"Dell Inc.","product_name":"PowerEdge R250"}"#)
    #expect(h.cpuCores == 12 && h.productName == "PowerEdge R250")
}

@Test func decodesLiveMaintenanceAndEmptyLists() throws {
    let m = try decode(MaintenanceEnvelope.self, #"{"execution":{"available":false,"note":"Advisory."},"generated_at":"2026-11-07T13:40:04+00:00","windows":[]}"#)
    #expect(m.execution?.note == "Advisory." && m.windows?.isEmpty == true)
    #expect(try decode([PluginInfo].self, "[]").isEmpty)
    #expect(try decode([LogDestination].self, "[]").isEmpty)
}

// Live lists for plugins, log shipping and hypervisor connections were empty; these follow the OpenAPI schema.
@Test func decodesSchemaPluginsAndLogShipping() throws {
    let p = try decode([PluginInfo].self, #"[{"id":"p1","display_name":"P","enabled":false,"disabled_reason":"failing","version":"1.0","consecutive_failures":3,"delivery_count":9,"webhook":{"url":"x"}}]"#)
    #expect(p[0].disabledReason == "failing" && p[0].deliveryCount == 9)
    let d = try decode([LogDestination].self, #"[{"id":"d1","name":"loki","kind":"loki","url":"https://l","enabled":true,"headers":{"Authorization":"SECRET"}}]"#)
    #expect(d[0].kind == "loki")
    let r = try decode([LogShipRule].self, #"[{"rule_id":"r1","last_tick_at":"2026-11-07T00:00:00Z","lines_shipped":5,"last_error":""}]"#)
    #expect(r[0].linesShipped == 5)
}
