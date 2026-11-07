import Foundation
import Testing
@testable import ZeusKit

@Suite struct TailObserveTests {
    private func payload(_ json: String) throws -> TailPayload {
        TailPayload(try JSONDecoder().decode(JSONValue.self, from: Data(json.utf8)))
    }

    @Test func heatmapDecodesLiveShape() throws {
        // Live fixture, trimmed.
        let json = #"{"cells":[{"vm_name":"demo-alpine","namespace":"default","node":"node-1","cpu_usage":0.2,"memory_usage":9.67,"disk_usage":0.0,"network_usage":0.0,"status":"Running","health_score":100.0}],"metrics":["cpu","memory","disk","network"],"timestamp":"2026-11-07T14:57:39+00:00"}"#
        let h = try JSONDecoder().decode(Heatmap.self, from: Data(json.utf8))
        #expect(h.cells[0].id == "default/demo-alpine")
        #expect(h.cells[0].value("memory") == 9.67)
        #expect(h.metrics.count == 4)
    }

    @Test func activityFeedIsATableWithEventsKey() throws {  // live
        let p = try payload(#"{"events":[{"timestamp":"2026-11-07T14:54:43+00:00","event_type":"Normal","namespace":"default","reason":"Pulled"}]}"#)
        guard case .rows(let rows, _) = p else { Issue.record("expected rows"); return }
        #expect(rows.count == 1)
    }

    @Test func emptyListsAreEmptyTables() throws {  // live: alert-history, custom-metrics, dbops, perf-testing runs, ...
        guard case .rows(let rows, _) = try payload("[]") else { Issue.record("expected rows"); return }
        #expect(rows.isEmpty)
    }

    @Test func capacityTrendKeepsMessageAsSummary() throws {  // live
        let p = try payload(#"{"period_days":30,"data_points":[{"timestamp":"t","total_nodes":1,"ready_nodes":1,"event_count":0}],"message":"Enable the event store."}"#)
        guard case .rows(let rows, let summary) = p else { Issue.record("expected rows"); return }
        #expect(rows.count == 1)
        #expect(summary["message"]?.string == "Enable the event store.")
    }

    @Test func statusObjectsAreRecords() throws {  // live: perf-testing capabilities, monitoring stats
        let p = try payload(#"{"enabled":true,"caps":{"max_rps":1000},"running_now":0}"#)
        guard case .record = p else { Issue.record("expected record"); return }
    }

    @Test func siemSecretsAreMasked() throws {  // live shape, values spec-style placeholders
        let p = try payload(#"{"config":{"enabled":true,"webhook_url":"","splunk_hec_token":"abc","elastic_api_key":"","sentinel_shared_key":"zzz"},"env_webhook_set":false}"#)
        guard case .record(let v) = p else { Issue.record("expected record"); return }
        #expect(v["config"]?["splunk_hec_token"]?.string == "••••••")
        #expect(v["config"]?["sentinel_shared_key"]?.string == "••••••")
        #expect(v["config"]?["elastic_api_key"]?.string == "")
    }

    @Test func backupSchedulesAndChargebackShapes() throws {  // live
        guard case .rows(let r, _) = try payload(#"[{"id":"s-daily","vm_name":"vm","namespace":"velero","schedule_cron":"0 2 * * *","retention_days":30,"enabled":true,"last_backup":null}]"#) else { Issue.record("rows"); return }
        #expect(r[0]["schedule_cron"]?.string == "0 2 * * *")
        guard case .rows(let lines, let s) = try payload(#"{"currency":"USD","total_cost":70.33,"lines":[{"id":"default","total_cost":70.33}],"by_resource_type":{"cpu":60.74}}"#) else { Issue.record("rows"); return }
        #expect(lines.count == 1); #expect(s["currency"]?.string == "USD")
    }

    @Test func catalogPathsAreUniquePerScreen() {
        for list in [TailCatalog.metrics, TailCatalog.activity, TailCatalog.databases, TailCatalog.testing, TailCatalog.operations] {
            #expect(Set(list.map(\.id)).count == list.count)
        }
    }
}
