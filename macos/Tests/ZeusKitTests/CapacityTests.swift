import Testing
import Foundation
@testable import ZeusKit

private func decode<T: Decodable>(_ t: T.Type, _ s: String) throws -> T { try JSONDecoder().decode(T.self, from: Data(s.utf8)) }

// Fixtures captured from a live server (GET only), trimmed.
private let usageJSON = #"""
{"cpu_cores_total": 12.0, "cpu_cores_used": 2.3449999999999998, "cpu_utilization_percent": 19.5, "memory_gb_total": 30.7, "memory_gb_used": 6.8, "memory_utilization_percent": 22.2, "storage_tb_total": 0.85, "storage_tb_used": 0.0, "storage_utilization_percent": 0.0, "pods_total": 250, "pods_used": 54, "node_count": 1}
"""#
private let projectionsJSON = #"""
[{"resource_type": "cpu", "current_utilization": 19.5, "projections": [{"date": "2026-11-08T13:23:35.521221986+00:00", "projected_utilization": 19.6, "required_capacity": 19.591666666666665}, {"date": "2026-11-15T13:23:35.521225510+00:00", "projected_utilization": 19.9, "required_capacity": 19.941666666666663}], "trend": "stable", "estimated_exhaustion": null}, {"resource_type": "memory", "current_utilization": 22.2, "projections": [{"date": "2026-11-08T13:23:35.521231041+00:00", "projected_utilization": 22.3, "required_capacity": 22.29098443962461}, {"date": "2026-11-15T13:23:35.521231568+00:00", "projected_utilization": 22.6, "required_capacity": 22.640984439624606}], "trend": "stable", "estimated_exhaustion": null}]
"""#
private let recsJSON = #"""
[{"id": "rec-1", "recommendation_type": "right_size", "resource_type": "pod", "resource_name": "zyvor-axiom-779ddfdf56-b5df6", "namespace": "axiom-system", "severity": "low", "title": "Reduce memory limit for axiom-system/zyvor-axiom-779ddfdf56-b5df6", "description": "Container 'zyvor-axiom' memory request (128Mi) is only 25% of limit (512Mi). Consider reducing limit (headroom only; no billed saving).", "current_config": {"memory_limit": "512Mi", "memory_request": "128Mi"}, "recommended_config": {"memory_limit": "192Mi"}, "estimated_savings_per_month": 0.0, "impact": "low", "created_at": "2026-11-07T13:23:38.010600727+00:00", "status": "pending"}]
"""#
private let pricingJSON = #"""
{"cpu_core_month": 30.368, "defaults": {"cpu_core_hour": 0.0416, "currency": "USD", "memory_gib_hour": 0.0104, "storage_gib_month": 0.1}, "env_warnings": [], "hours_per_month": 730.0, "memory_gib_month": 7.592, "pricing": {"cpu_core_hour": 0.0416, "currency": "USD", "memory_gib_hour": 0.0104, "storage_gib_month": 0.1}, "source": "default", "updated_at": null, "updated_by": null}
"""#
private let historyJSON = #"""
{"basis": "Recorded samples of the estimated run-rate from configured unit prices; not invoices.", "currency": "USD", "daily": [], "days": 30, "forecast": {"basis": "recorded samples", "coverage": null, "current_hourly": null, "month_to_date": null, "needed": 24, "projected_month_end": null, "ready": false, "reason": "Needs 24 recorded samples for a trend; 8 recorded so far (16 more). Samples are taken every 3600 s.", "samples": 8}, "name": null, "points": [{"hourly": 0.09633972602739724, "ts": 1794031586}, {"hourly": 0.09633972602739724, "ts": 1794035186}], "sampler": {"enabled": true, "interval_secs": 3600}, "scope": "cluster", "status": {"needed": 24, "newest": "2026-11-07T13:14:06+00:00", "oldest": "2026-11-07T06:06:26+00:00", "ready": false, "reason": "Needs 24 recorded samples for a trend; 8 recorded so far (16 more). Samples are taken every 3600 s.", "samples": 8}}
"""#
private let forecastsJSON = #"""
[{"forecast_id": "cpu-linear-30d", "name": "CPU utilization (30d)", "resource_type": "cpu", "forecast_method": "linear", "time_horizon_days": 30, "created_at": "2026-11-07T13:23:34.293595814+00:00", "last_updated": "2026-11-07T13:23:34.293595814+00:00", "confidence_level": 0.55, "method": "static", "custom": false}]
"""#

@Test func decodesCapacityUsage() throws {
    let u = try decode(CapacityUsage.self, usageJSON)
    #expect(u.cpuUtilizationPercent == 19.5 && u.podsTotal == 250 && u.nodeCount == 1)
}

@Test func decodesProjectionsWithFractionalDates() throws {
    let p = try decode(Listing<CapacityProjection>.self, projectionsJSON).items
    #expect(p.count == 2 && p[0].resourceType == "cpu" && p[0].projections.count == 2)
    #expect(p[0].projections[0].date != nil && p[0].projections[0].projectedUtilization == 19.6)
}

@Test func decodesForecasts() throws {
    let f = try decode(Listing<CapacityForecast>.self, forecastsJSON).items
    #expect(f[0].id == "cpu-linear-30d" && f[0].timeHorizonDays == 30)
}

@Test func decodesOptimizationRecommendations() throws {
    let r = try decode(Listing<OptimizationRecommendation>.self, recsJSON).items
    #expect(r[0].id == "rec-1" && r[0].recommendedConfig?["memory_limit"]?.string == "192Mi" && r[0].estimatedSavingsPerMonth == 0)
}

@Test func decodesPricingAndHistory() throws {
    let p = try decode(FinOpsPricing.self, pricingJSON)
    #expect(p.pricing?.cpuCoreHour == 0.0416 && p.pricing?.gpuHour == nil && p.source == "default")
    let h = try decode(CostHistory.self, historyJSON)
    #expect(h.points.count == 2 && h.ready == false && h.needed == 24 && h.projectedMonthEnd == nil)
}

@Test func emptyCapacityRecommendationsDecode() throws {
    #expect(try decode(Listing<JSONValue>.self, "[]").items.isEmpty)
}

// Write requests: request shape only. Never sent to a live server.
@Test func pricingUpdateBodyOmitsUnsetFields() throws {
    let c = ZeusClient(baseURL: URL(string: "https://zeus.test")!, token: "t")
    let r = try c.request("finops/pricing", method: "PUT", body: PricingUpdate(cpuCoreHour: 0.05, clearGPUHour: true))
    #expect(r.httpMethod == "PUT" && r.url?.path == "/api/v1/finops/pricing")
    let o = try JSONSerialization.jsonObject(with: r.httpBody ?? Data()) as? [String: Any]
    #expect(Set(o?.keys.map { $0 } ?? []) == ["cpu_core_hour", "clear_gpu_hour"])
}

@Test func deleteBudgetEncodesIDSegment() throws {
    let c = ZeusClient(baseURL: URL(string: "https://zeus.test")!, token: "t")
    let r = try c.request(ZeusClient.path(["finops", "budgets", "a b/c"]), method: "DELETE")
    #expect(r.httpMethod == "DELETE" && r.url?.absoluteString == "https://zeus.test/api/v1/finops/budgets/a%20b%2Fc")
}
