import Foundation

public struct CostBreakdown: Decodable, Sendable, Hashable {
    public let cpuCost: Double
    public let memoryCost: Double
    public let storageCost: Double
    public let networkCost: Double

    enum CodingKeys: String, CodingKey {
        case cpuCost = "cpu_cost", memoryCost = "memory_cost", storageCost = "storage_cost", networkCost = "network_cost"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        cpuCost = try c.decodeIfPresent(Double.self, forKey: .cpuCost) ?? 0
        memoryCost = try c.decodeIfPresent(Double.self, forKey: .memoryCost) ?? 0
        storageCost = try c.decodeIfPresent(Double.self, forKey: .storageCost) ?? 0
        networkCost = try c.decodeIfPresent(Double.self, forKey: .networkCost) ?? 0
    }
}

/// Modelled (not billed) cost for one machine, from the configured price model.
public struct VMCost: Decodable, Sendable, Identifiable, Hashable {
    public let vmName: String
    public let namespace: String
    public let dailyCost: Double
    public let monthlyEstimate: Double
    public let breakdown: CostBreakdown?
    public let optimizationAvailable: Bool?

    public var id: String { "\(namespace)/\(vmName)" }

    enum CodingKeys: String, CodingKey {
        case vmName = "vm_name", namespace, breakdown
        case dailyCost = "daily_cost", monthlyEstimate = "monthly_estimate", optimizationAvailable = "optimization_available"
    }
}

public struct CostSummary: Decodable, Sendable {
    public let totalMonthlyCost: Double
    public let totalDailyCost: Double
    public let optimizationAvailable: Double
    public let wasteDetected: Double
    public let vmCount: Int

    enum CodingKeys: String, CodingKey {
        case totalMonthlyCost = "total_monthly_cost", totalDailyCost = "total_daily_cost"
        case optimizationAvailable = "optimization_available", wasteDetected = "waste_detected", vmCount = "vm_count"
    }
}

public struct CostOverview: Decodable, Sendable {
    public let summary: CostSummary
}

public struct WasteReport: Decodable, Sendable {
    public let totalPotentialSavings: Double
    public let wasteItems: [JSONValue]
    public let idleVMCount: Int
    public let overprovisionedVMCount: Int
    public let stoppedVMCount: Int

    enum CodingKeys: String, CodingKey {
        case totalPotentialSavings = "total_potential_savings", wasteItems = "waste_items"
        case idleVMCount = "idle_vm_count", overprovisionedVMCount = "overprovisioned_vm_count", stoppedVMCount = "stopped_vm_count"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        totalPotentialSavings = try c.decodeIfPresent(Double.self, forKey: .totalPotentialSavings) ?? 0
        wasteItems = try c.decodeIfPresent([JSONValue].self, forKey: .wasteItems) ?? []
        idleVMCount = try c.decodeIfPresent(Int.self, forKey: .idleVMCount) ?? 0
        overprovisionedVMCount = try c.decodeIfPresent(Int.self, forKey: .overprovisionedVMCount) ?? 0
        stoppedVMCount = try c.decodeIfPresent(Int.self, forKey: .stoppedVMCount) ?? 0
    }
}

/// `GET /finops/budgets`. Budget rows are untyped until we have a real one to decode.
public struct BudgetReport: Decodable, Sendable {
    public let basis: String?
    public let budgets: [JSONValue]
    public let currency: String?
    public let period: String?

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        basis = try c.decodeIfPresent(String.self, forKey: .basis)
        budgets = try c.decodeIfPresent([JSONValue].self, forKey: .budgets) ?? []
        currency = try c.decodeIfPresent(String.self, forKey: .currency)
        period = try c.decodeIfPresent(String.self, forKey: .period)
    }
    enum CodingKeys: String, CodingKey { case basis, budgets, currency, period }
}

extension ZeusClient {
    public func costOverview() async throws -> CostOverview { try await get("cost-intelligence", "overview") }
    public func vmCosts() async throws -> [VMCost] { try await list("cost-intelligence", "vms") }
    public func wasteReport() async throws -> WasteReport { try await get("cost-intelligence", "waste") }
    public func budgets() async throws -> BudgetReport { try await get("finops", "budgets") }
}
