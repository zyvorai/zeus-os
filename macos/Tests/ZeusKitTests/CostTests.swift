import Testing
import Foundation
@testable import ZeusKit

@Test func decodesVMCostFromLiveShape() throws {
    let json = #"[{"vm_name":"demo","namespace":"default","daily_cost":1.15,"monthly_estimate":35.16,"breakdown":{"cpu_cost":0.99,"cpu_percentage":86.3,"memory_cost":0.12,"memory_percentage":10.7,"storage_cost":0.03,"storage_percentage":2.8,"network_cost":0.0,"network_percentage":0.0},"optimization_available":false,"optimization":null}]"#
    let v = try JSONDecoder().decode(Listing<VMCost>.self, from: Data(json.utf8)).items
    #expect(v[0].id == "default/demo" && v[0].breakdown?.cpuCost == 0.99 && v[0].optimizationAvailable == false)
}

@Test func decodesCostOverviewAndEmptyWaste() throws {
    let o = #"{"summary":{"total_monthly_cost":70.3,"total_daily_cost":2.31,"optimization_available":0.0,"waste_detected":0.0,"vm_count":2,"last_updated":"x"},"top_expensive_vms":[]}"#
    #expect(try JSONDecoder().decode(CostOverview.self, from: Data(o.utf8)).summary.vmCount == 2)
    let w = #"{"total_potential_savings":0.0,"waste_items":[],"idle_vm_count":0,"overprovisioned_vm_count":0,"stopped_vm_count":0}"#
    #expect(try JSONDecoder().decode(WasteReport.self, from: Data(w.utf8)).wasteItems.isEmpty)
}

@Test func decodesBudgetReportWithNoBudgets() throws {
    let b = #"{"basis":"Estimated","budgets":[],"currency":"USD","period":"2026-11","sampler":{"enabled":true}}"#
    let r = try JSONDecoder().decode(BudgetReport.self, from: Data(b.utf8))
    #expect(r.currency == "USD" && r.budgets.isEmpty)
}
