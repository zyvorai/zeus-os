import Testing
import Foundation
@testable import ZeusKit

private func decode<T: Decodable>(_ t: T.Type, _ s: String) throws -> T { try JSONDecoder().decode(T.self, from: Data(s.utf8)) }

// Captured from a live server (GET only), trimmed and scrubbed.
private let podLogsJSON = #"""
{"source":{"resource_type":"Pod","namespace":"default","name":"virt-launcher-demo","container":null},"logs":["2026-11-07T14:31:17.838161806+01:00 {\"component\":\"virt-launcher\",\"level\":\"info\",\"msg\":\"Synced vmi\"}","2026-11-07T14:40:14.376166364+01:00 {\"level\":\"error\",\"msg\":\"Guest agent is not responding\"}","plain text line"]}
"""#
private let sourcesJSON = #"[{"resource_type":"Pod","namespace":"default","name":"virt-launcher-demo","container":"compute"}]"#
private let statsJSON = #"{"namespace":"default","total_pods":2,"pods_with_errors":2,"total_log_lines":400,"error_rate_percent":1.0,"warning_rate_percent":0.0,"top_error_sources":[{"pod_name":"virt-launcher-demo","container":"compute","error_count":2,"last_error":"Guest agent is not responding"}]}"#
private let anomaliesJSON = #"[{"anomaly_id":"anom-0","anomaly_type":"Unhealthy","description":"Readiness probe failed","detected_at":"2026-11-07T13:32:11+00:00","confidence_score":0.65,"severity":"medium","baseline_metric":"event_rate","expected_value":1.0,"actual_value":1.42,"deviation_percent":42.0}]"#
private let timelineJSON = #"[{"timestamp":"2026-11-07T13:32:11+00:00","event_type":"Warning","reason":"Unhealthy","resource":"pod/example","namespace":"ns","message":"Readiness probe failed","severity":"medium"}]"#
private let topologyJSON = #"{"nodes":[{"id":"node-a","name":"node-a","status":"Ready","cpu_usage":19.6,"memory_usage":72.8,"vm_count":2,"capacity":{"cpu":"12","memory":"32178144Ki"}}],"vms":[{"id":"default/demo-alpine","name":"demo-alpine","namespace":"default","status":"Running","node":"node-a","cpu_usage":0.26,"memory_usage":15.5}],"timestamp":"2026-11-07T13:40:07+00:00"}"#
private let dvrJSON = #"{"interval_secs":30,"enabled":true,"frames":[{"ts":"2026-11-07T06:06:26.547019779Z","nodes_total":1,"nodes_ready":1,"nodes_cordoned":0,"vms_total":2,"vms_running":2,"vms_failed":0,"warning_events":4}]}"#
private let apmJSON = #"[{"name":"svc","environment":"ns","instance_count":1,"restarts_per_pod":1.0,"requests_per_minute":null,"error_rate":null,"avg_latency_ms":null,"p95_latency_ms":null,"apdex_score":null,"latency_source":"unavailable","latency_reason":"PacketWolf is not configured"}]"#
private let aiStatusJSON = #"{"enabled_count":0,"default_provider_id":null,"default_provider_name":null,"default_source":"none","air_gap_mode":false,"providers":[]}"#
private let chaosStatsJSON = #"{"total_experiments":0,"running_experiments":0,"succeeded_experiments":0,"failed_experiments":0,"experiments_by_type":{},"total_targets_affected":0,"average_impact_score":0.0,"resilience_score":100.0}"#
private let fleetJSON = #"{"collected_at":"2026-11-07T13:40:14+00:00","vms_scanned":2,"vms_with_profile":2,"os_counts":[{"label":"Unknown","count":2}],"issues":[{"id":"guest_agent_disconnected","count":2,"message":"guest agent is not connected"}]}"#

@Test func parsesLogLines() throws {
    let p = try decode(PodLogs.self, podLogsJSON)
    let lines = p.logs.enumerated().map { LogLine(id: $0.offset, raw: $0.element) }
    #expect(lines[0].level == "info" && lines[0].message == "Synced vmi" && lines[0].timestamp != nil)
    #expect(lines[1].level == "error")
    #expect(lines[2].message == "plain text line" && lines[2].timestamp == nil)
}

@Test func decodesLogSourcesAndStats() throws {
    #expect(try decode(Listing<LogSource>.self, sourcesJSON).items[0].container == "compute")
    let s = try decode(LogStats.self, statsJSON)
    #expect(s.totalLogLines == 400 && s.topErrorSources?.first?.errorCount == 2)
}

@Test func decodesEventAnalysis() throws {
    let a = try decode(Listing<EventAnomaly>.self, anomaliesJSON).items
    #expect(a[0].deviationPercent == 42 && a[0].date != nil)
    #expect(try decode(Listing<TimelineEvent>.self, timelineJSON).items[0].reason == "Unhealthy")
    // Incidents are empty live; decoded per schema as free-form records.
    #expect(try decode(Listing<EventRecord>.self, "[]").items.isEmpty)
    #expect(try decode(Listing<EventRecord>.self, #"[{"incident_id":"i1"}]"#).items[0].id == "i1")
}

@Test func decodesTopologyAndDVR() throws {
    let t = try decode(Topology.self, topologyJSON)
    #expect(t.nodes[0].vmCount == 2 && t.vms[0].node == "node-a")
    #expect(try decode(Topology.self, "{}").nodes.isEmpty)
    let d = try decode(DVRCluster.self, dvrJSON)
    #expect(d.frames[0].vmsRunning == 2 && d.frames[0].date != nil)
}

@Test func decodesAPMAIAndChaos() throws {
    let s = try decode(Listing<APMService>.self, apmJSON).items[0]
    #expect(s.requestsPerMinute == nil && s.latencySource == "unavailable")
    let ai = try decode(AIStatus.self, aiStatusJSON)
    #expect(ai.enabledCount == 0 && ai.providers.isEmpty && ai.defaultProviderName == nil)
    #expect(try decode(GuestFleet.self, fleetJSON).issues[0].count == 2)
    #expect(try decode(ChaosStats.self, chaosStatsJSON).resilienceScore == 100)
    #expect(try decode(Listing<ChaosExperiment>.self, "[]").items.isEmpty)
}
