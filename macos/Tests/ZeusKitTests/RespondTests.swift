import Testing
import Foundation
@testable import ZeusKit

private func dec<T: Decodable & Sendable>(_ t: T.Type, _ s: String) throws -> T {
    try JSONDecoder().decode(t, from: Data(s.utf8))
}

// Live shape (captured from a real server).
@Test func decodesLiveSLOs() throws {
    let json = #"[{"name":"default-vm-availability","namespace":"default","service":"VirtualMachines","slo_type":"Availability","target":99.9,"current":100.0,"status":"Meeting","time_window":"current","budget_remaining":100.0,"created_at":"2026-11-07T13:23:29.509010173+00:00"}]"#
    let s = try dec(Listing<SLO>.self, json).items
    #expect(s[0].id == "default/default-vm-availability" && s[0].budgetRemaining == 100 && s[0].target == 99.9)
}

@Test func decodesLiveSLOStats() throws {
    let json = #"{"total_slos":2,"meeting_target":2,"at_risk":0,"violated":0,"total_services_monitored":2,"average_availability":100.0,"average_error_budget_remaining":100.0,"slos_by_type":{"Availability":1},"slos_by_status":{"Meeting":2},"critical_alerts":0}"#
    let s = try dec(SLOStats.self, json)
    #expect(s.totalSlos == 2 && s.violated == 0)
}

@Test func decodesLiveClusterIncidents() throws {
    let json = #"{"incidents":[],"cluster_health":{"status":"healthy","total_nodes":1,"ready_nodes":1,"total_vms":2,"running_vms":2,"warning_events_last_hour":0},"affected_vm_count":0,"total_vm_count":2}"#
    let c = try dec(ClusterIncidents.self, json)
    #expect(c.incidents.isEmpty && c.clusterHealth?.status == "healthy" && c.clusterHealth?.runningVms == 2)
}

@Test func decodesLiveTenant() throws {
    let json = #"[{"tenant_id":"cdi","name":"cdi","display_name":"cdi","tier":"standard","status":"active","created_at":"2026-11-03T00:56:06+00:00","contact_email":"","namespace_count":1,"total_cpu_cores":0.4,"total_memory_gb":0.5859375}]"#
    let t = try dec(Listing<Tenant>.self, json).items
    #expect(t[0].id == "cdi" && t[0].totalCpuCores == 0.4)
}

@Test func emptyLiveCollectionsDecode() throws {
    #expect(try dec(Listing<AlertingRule>.self, "[]").items.isEmpty)
    #expect(try dec(Listing<NotificationRecord>.self, "[]").items.isEmpty)
}

// Schema-derived (live collections were empty).
@Test func decodesRuleFromSchema() throws {
    let json = #"[{"rule_id":"r1","name":"cpu","severity":"warning","enabled":true,"condition":{"metric":"cpu","operator":">","threshold":90,"duration_minutes":5,"filters":{}},"notification_channels":["c1"],"last_triggered":null}]"#
    let r = try dec(Listing<AlertingRule>.self, json).items
    #expect(r[0].condition?.summary == "cpu > 90 for 5m" && r[0].lastTriggered == nil)
}

@Test func decodesChannelsWithoutExposingConfig() throws {
    let a = try dec(Listing<AlertingChannel>.self, #"[{"channel_id":"c1","name":"ops","channel_type":"slack","enabled":true,"configuration":{"webhook":"https://secret"}}]"#).items
    let n = try dec(Listing<NotificationChannel>.self, #"[{"id":"n1","name":"mail","channel_type":"email","enabled":false,"config":{"password":"x"}}]"#).items
    #expect(a[0].channelType == "slack" && n[0].enabled == false)
    #expect(!String(describing: a[0]).contains("secret") && !String(describing: n[0]).contains("password"))
}

@Test func decodesNotificationAndIncidentFromSchema() throws {
    let h = try dec(Listing<NotificationRecord>.self, #"[{"id":"h1","status":"failed","error":"timeout","sent_at":"2026-11-07T10:00:00Z"}]"#).items
    #expect(h[0].error == "timeout" && zeusDate(h[0].sentAt) != nil)
    let i = try dec(Listing<AlertIncident>.self, #"[{"incident_id":"i1","title":"db down","status":"open","alert_ids":["a"]}]"#).items
    #expect(i[0].id == "i1" && i[0].alertIds == ["a"])
}
