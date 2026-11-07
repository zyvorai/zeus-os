import Foundation

/// `GET /capacity/current-usage`. Every field optional: the server may omit what it can't measure.
public struct CapacityUsage: Decodable, Sendable, Equatable {
    public let cpuCoresTotal: Double?
    public let cpuCoresUsed: Double?
    public let cpuUtilizationPercent: Double?
    public let memoryGBTotal: Double?
    public let memoryGBUsed: Double?
    public let memoryUtilizationPercent: Double?
    public let storageTBTotal: Double?
    public let storageTBUsed: Double?
    public let storageUtilizationPercent: Double?
    public let podsTotal: Int?
    public let podsUsed: Int?
    public let nodeCount: Int?

    enum CodingKeys: String, CodingKey {
        case cpuCoresTotal = "cpu_cores_total", cpuCoresUsed = "cpu_cores_used", cpuUtilizationPercent = "cpu_utilization_percent"
        case memoryGBTotal = "memory_gb_total", memoryGBUsed = "memory_gb_used", memoryUtilizationPercent = "memory_utilization_percent"
        case storageTBTotal = "storage_tb_total", storageTBUsed = "storage_tb_used", storageUtilizationPercent = "storage_utilization_percent"
        case podsTotal = "pods_total", podsUsed = "pods_used", nodeCount = "node_count"
    }
}

public struct CapacityThresholds: Decodable, Sendable, Equatable {
    public let cpuWarningPercent: Double?
    public let cpuCriticalPercent: Double?
    public let memoryWarningPercent: Double?
    public let memoryCriticalPercent: Double?
    public let storageWarningPercent: Double?
    public let storageCriticalPercent: Double?
    public let leadTimeDays: Int?

    enum CodingKeys: String, CodingKey {
        case cpuWarningPercent = "cpu_warning_percent", cpuCriticalPercent = "cpu_critical_percent"
        case memoryWarningPercent = "memory_warning_percent", memoryCriticalPercent = "memory_critical_percent"
        case storageWarningPercent = "storage_warning_percent", storageCriticalPercent = "storage_critical_percent"
        case leadTimeDays = "lead_time_days"
    }
}

public struct ProjectionPoint: Decodable, Sendable, Hashable {
    public let date: Date?
    public let projectedUtilization: Double?
    public let requiredCapacity: Double?

    enum CodingKeys: String, CodingKey { case date, projectedUtilization = "projected_utilization", requiredCapacity = "required_capacity" }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        date = try c.decodeIfPresent(String.self, forKey: .date).flatMap(ZeusDates.parse)
        projectedUtilization = try c.decodeIfPresent(Double.self, forKey: .projectedUtilization)
        requiredCapacity = try c.decodeIfPresent(Double.self, forKey: .requiredCapacity)
    }
}

/// One resource's projection from `GET /capacity/projections`.
public struct CapacityProjection: Decodable, Sendable, Identifiable {
    public let resourceType: String
    public let currentUtilization: Double?
    public let projections: [ProjectionPoint]
    public let trend: String?
    /// Null while no exhaustion is predicted; kept raw because no live example has a value.
    public let estimatedExhaustion: JSONValue?

    public var id: String { resourceType }

    enum CodingKeys: String, CodingKey {
        case resourceType = "resource_type", currentUtilization = "current_utilization", projections, trend
        case estimatedExhaustion = "estimated_exhaustion"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        resourceType = try c.decode(String.self, forKey: .resourceType)
        currentUtilization = try c.decodeIfPresent(Double.self, forKey: .currentUtilization)
        projections = try c.decodeIfPresent([ProjectionPoint].self, forKey: .projections) ?? []
        trend = try c.decodeIfPresent(String.self, forKey: .trend)
        estimatedExhaustion = try c.decodeIfPresent(JSONValue.self, forKey: .estimatedExhaustion)
    }
}

public struct CapacityForecast: Decodable, Sendable, Identifiable, Hashable {
    public let forecastID: String
    public let name: String?
    public let resourceType: String?
    public let forecastMethod: String?
    public let timeHorizonDays: Int?
    public let confidenceLevel: Double?
    public let custom: Bool?

    public var id: String { forecastID }

    enum CodingKeys: String, CodingKey {
        case forecastID = "forecast_id", name, resourceType = "resource_type", forecastMethod = "forecast_method"
        case timeHorizonDays = "time_horizon_days", confidenceLevel = "confidence_level", custom
    }
}

/// Parses the server's RFC 3339 timestamps, with or without fractional seconds.
public enum ZeusDates {
    public static func parse(_ s: String) -> Date? {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f.date(from: s) { return d }
        f.formatOptions = [.withInternetDateTime]
        return f.date(from: s)
    }
}

/// `GET /optimization/recommendations` row.
public struct OptimizationRecommendation: Decodable, Sendable, Identifiable {
    public let id: String
    public let recommendationType: String?
    public let resourceType: String?
    public let resourceName: String?
    public let namespace: String?
    public let severity: String?
    public let title: String?
    public let description: String?
    public let currentConfig: JSONValue?
    public let recommendedConfig: JSONValue?
    public let estimatedSavingsPerMonth: Double?
    public let impact: String?
    public let status: String?

    enum CodingKeys: String, CodingKey {
        case id, recommendationType = "recommendation_type", resourceType = "resource_type", resourceName = "resource_name"
        case namespace, severity, title, description, impact, status
        case currentConfig = "current_config", recommendedConfig = "recommended_config"
        case estimatedSavingsPerMonth = "estimated_savings_per_month"
    }
}

/// `GET /finops/pricing`. `pricing` is the effective unit price set.
public struct FinOpsPricing: Decodable, Sendable, Equatable {
    public struct Prices: Decodable, Sendable, Equatable {
        public let cpuCoreHour: Double?
        public let memoryGiBHour: Double?
        public let storageGiBMonth: Double?
        public let gpuHour: Double?
        public let currency: String?
        enum CodingKeys: String, CodingKey {
            case cpuCoreHour = "cpu_core_hour", memoryGiBHour = "memory_gib_hour", storageGiBMonth = "storage_gib_month"
            case gpuHour = "gpu_hour", currency
        }
    }
    public let pricing: Prices?
    public let defaults: Prices?
    public let source: String?
    public let hoursPerMonth: Double?
    public let updatedBy: String?
    public let envWarnings: [String]?

    enum CodingKeys: String, CodingKey {
        case pricing, defaults, source, hoursPerMonth = "hours_per_month", updatedBy = "updated_by", envWarnings = "env_warnings"
    }
}

/// Body of `PUT /finops/pricing`. Unset fields are omitted and keep their server value (partial update).
public struct PricingUpdate: Encodable, Sendable, Equatable {
    public var cpuCoreHour: Double?
    public var memoryGiBHour: Double?
    public var storageGiBMonth: Double?
    public var gpuHour: Double?
    public var currency: String?
    public var clearGPUHour: Bool?

    public init(cpuCoreHour: Double? = nil, memoryGiBHour: Double? = nil, storageGiBMonth: Double? = nil,
                gpuHour: Double? = nil, currency: String? = nil, clearGPUHour: Bool? = nil) {
        self.cpuCoreHour = cpuCoreHour; self.memoryGiBHour = memoryGiBHour; self.storageGiBMonth = storageGiBMonth
        self.gpuHour = gpuHour; self.currency = currency; self.clearGPUHour = clearGPUHour
    }

    enum CodingKeys: String, CodingKey {
        case cpuCoreHour = "cpu_core_hour", memoryGiBHour = "memory_gib_hour", storageGiBMonth = "storage_gib_month"
        case gpuHour = "gpu_hour", currency, clearGPUHour = "clear_gpu_hour"
    }
}

public struct CostHistoryPoint: Decodable, Sendable, Hashable {
    public let ts: Date
    public let hourly: Double

    enum CodingKeys: String, CodingKey { case ts, hourly }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        ts = Date(timeIntervalSince1970: try c.decode(Double.self, forKey: .ts))
        hourly = try c.decode(Double.self, forKey: .hourly)
    }
}

/// `GET /finops/cost-history`: recorded samples of the estimated hourly run-rate.
public struct CostHistory: Decodable, Sendable {
    public let currency: String?
    public let points: [CostHistoryPoint]
    public let samples: Int?
    public let needed: Int?
    public let ready: Bool?
    public let reason: String?
    public let projectedMonthEnd: Double?

    enum CodingKeys: String, CodingKey { case currency, points, forecast }
    enum ForecastKeys: String, CodingKey { case samples, needed, ready, reason, projectedMonthEnd = "projected_month_end" }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        currency = try c.decodeIfPresent(String.self, forKey: .currency)
        points = try c.decodeIfPresent([CostHistoryPoint].self, forKey: .points) ?? []
        if let f = try? c.nestedContainer(keyedBy: ForecastKeys.self, forKey: .forecast) {
            samples = try f.decodeIfPresent(Int.self, forKey: .samples)
            needed = try f.decodeIfPresent(Int.self, forKey: .needed)
            ready = try f.decodeIfPresent(Bool.self, forKey: .ready)
            reason = try f.decodeIfPresent(String.self, forKey: .reason)
            projectedMonthEnd = try f.decodeIfPresent(Double.self, forKey: .projectedMonthEnd)
        } else { samples = nil; needed = nil; ready = nil; reason = nil; projectedMonthEnd = nil }
    }
}

extension ZeusClient {
    public func capacityUsage() async throws -> CapacityUsage { try await get("capacity", "current-usage") }
    public func capacityThresholds() async throws -> CapacityThresholds { try await get("capacity", "thresholds") }
    public func capacityProjections() async throws -> [CapacityProjection] { try await list("capacity", "projections") }
    public func capacityForecasts() async throws -> [CapacityForecast] { try await list("capacity", "forecasts") }
    /// Capacity recommendations have only been seen empty live, so rows stay untyped.
    public func capacityRecommendations() async throws -> [JSONValue] { try await list("capacity", "recommendations") }
    public func optimizationRecommendations() async throws -> [OptimizationRecommendation] {
        try await list("optimization", "recommendations")
    }
    public func pricing() async throws -> FinOpsPricing { try await get("finops", "pricing") }
    public func updatePricing(_ update: PricingUpdate) async throws { try await put("finops", "pricing", body: update) }
    public func costHistory() async throws -> CostHistory { try await get("finops", "cost-history") }
    public func deleteBudget(id: String) async throws { try await delete("finops", "budgets", id) }
}
