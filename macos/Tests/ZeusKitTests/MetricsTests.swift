import Testing
import Foundation
@testable import ZeusKit

private let sample = #"""
{"vm_name":"db-01","namespace":"demo-vms","data_points":[
{"timestamp":"2026-11-07T04:54:53.275+00:00","cpu_usage_percent":0.60,"memory_usage_percent":23.4,"memory_usage_bytes":99188736,"network_rx_bytes":null,"network_rx_bytes_per_sec":0.0,"network_tx_bytes_per_sec":1.5,"disk_read_bytes_per_sec":null,"disk_write_bytes_per_sec":0.0,"rates_state":"ok"},
{"timestamp":"2026-11-07T04:53:52.055+00:00","cpu_usage_percent":0.97,"memory_usage_percent":24.0}]}
"""#

@Test func decodesHistoryWithFractionalTimestampsAndNulls() throws {
    let h = try JSONDecoder().decode(VMMetricsHistory.self, from: Data(sample.utf8))
    #expect(h.dataPoints.count == 2)
    let p = h.dataPoints[0]
    #expect(p.cpuUsagePercent == 0.60)
    #expect(p.diskReadBytesPerSec == nil)
    #expect(p.networkTxBytesPerSec == 1.5)
    #expect(h.dataPoints[1].networkRxBytesPerSec == nil)     // key absent
    #expect(p.timestamp.timeIntervalSince(h.dataPoints[1].timestamp) > 60)
}

@Test func rejectsGarbageTimestamp() {
    let bad = #"{"data_points":[{"timestamp":"yesterday"}]}"#
    #expect(throws: DecodingError.self) { try JSONDecoder().decode(VMMetricsHistory.self, from: Data(bad.utf8)) }
}

@Test func decodesClusterAndNodes() throws {
    let c = try JSONDecoder().decode(ClusterMetrics.self, from: Data(#"{"total_cpu_cores":12.0,"used_cpu_cores":2.75,"cpu_usage_percent":22.9,"total_memory_bytes":32950427648,"used_memory_bytes":10541867008,"memory_usage_percent":31.99,"total_storage_bytes":0,"used_storage_bytes":0,"storage_usage_percent":0.0,"total_vms":4,"running_vms":2,"total_nodes":1,"ready_nodes":1}"#.utf8))
    #expect(c.runningVms == 2 && c.totalVms == 4)
    #expect(c.cpuUsagePercent == 22.9)
    let n = try JSONDecoder().decode([NodeMetrics].self, from: Data(#"[{"node_name":"n1","cpu_usage_percent":22.6,"memory_usage_percent":31.9,"pod_count":97,"vm_count":2,"status":"Ready"}]"#.utf8))
    #expect(n[0].id == "n1")
}

@Test func historyRequestCarriesRangeAsQuery() throws {
    let c = ZeusClient(baseURL: URL(string: "https://z.example")!, token: "t")
    let q = [URLQueryItem(name: "duration_minutes", value: "60"), URLQueryItem(name: "interval_seconds", value: "40")]
    let vm = try JSONDecoder().decode(VM.self, from: Data(#"{"name":"db 01","namespace":"ns","status":"Running"}"#.utf8))
    let r = try c.request(ZeusClient.metricsPath(vm, "history"), query: q)
    #expect(r.url?.absoluteString == "https://z.example/api/v1/metrics/vms/ns/db%2001/history?duration_minutes=60&interval_seconds=40")
}

@Test func rangeIntervalsStayAboveScrapeFloor() {
    #expect(MetricsRange.quarterHour.intervalSeconds == 15)
    #expect(MetricsRange.hour.intervalSeconds == 40)
    #expect(MetricsRange.sixHours.intervalSeconds == 240)
}

@Test func requestKeepsEncodingSingleAndBasePath() throws {
    let c = ZeusClient(baseURL: URL(string: "https://z.example/zeus/")!, token: nil)
    let r = try c.request("vms/a%2Fb/c%20d/start", method: "POST")
    #expect(r.url?.absoluteString == "https://z.example/zeus/api/v1/vms/a%2Fb/c%20d/start")
}
