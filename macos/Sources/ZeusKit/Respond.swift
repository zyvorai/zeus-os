import Foundation

/// Parses a server timestamp for display; nil when absent or unparseable.
public func zeusDate(_ s: String?) -> Date? { s.flatMap(ZeusDate.parse) }

/// Condition of an alerting rule (`GET /alerting/rules`).
public struct RuleCondition: Decodable, Sendable, Hashable {
    public let metric: String?
    public let `operator`: String?
    public let threshold: Double?
    public let durationMinutes: Int?

    enum CodingKeys: String, CodingKey { case metric, `operator`, threshold, durationMinutes = "duration_minutes" }

    public var summary: String {
        [metric, `operator`, threshold.map { $0.formatted() }].compactMap { $0 }.joined(separator: " ")
            + (durationMinutes.map { " for \($0)m" } ?? "")
    }
}

public struct AlertingRule: Decodable, Sendable, Identifiable, Hashable {
    public let ruleId: String
    public let name: String?
    public let description: String?
    public let severity: String?
    public let enabled: Bool?
    public let condition: RuleCondition?
    public let notificationChannels: [String]?
    public let lastTriggered: String?
    public let createdAt: String?

    public var id: String { ruleId }

    enum CodingKeys: String, CodingKey {
        case name, description, severity, enabled, condition
        case ruleId = "rule_id", notificationChannels = "notification_channels"
        case lastTriggered = "last_triggered", createdAt = "created_at"
    }
}

/// Channel from `/alerting/channels`. The `configuration` object is deliberately not decoded:
/// it holds webhook URLs and tokens that must never reach the UI.
public struct AlertingChannel: Decodable, Sendable, Identifiable, Hashable {
    public let channelId: String
    public let name: String?
    public let channelType: String?
    public let enabled: Bool?
    public let createdAt: String?

    public var id: String { channelId }

    enum CodingKeys: String, CodingKey {
        case name, enabled
        case channelId = "channel_id", channelType = "channel_type", createdAt = "created_at"
    }
}

/// Channel from `/notifications/channels`; `config` is deliberately not decoded (secrets).
public struct NotificationChannel: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String?
    public let channelType: String?
    public let enabled: Bool?
    public let lastUsed: String?
    public let ownerTenant: String?

    enum CodingKeys: String, CodingKey {
        case id, name, enabled
        case channelType = "channel_type", lastUsed = "last_used", ownerTenant = "owner_tenant"
    }
}

public struct NotificationRecord: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let channelId: String?
    public let channelType: String?
    public let subject: String?
    public let severity: String?
    public let status: String?
    public let error: String?
    public let sentAt: String?
    public let deliveredAt: String?

    enum CodingKeys: String, CodingKey {
        case id, subject, severity, status, error
        case channelId = "channel_id", channelType = "channel_type", sentAt = "sent_at", deliveredAt = "delivered_at"
    }
}

/// `GET /slo/slos`. `budgetRemaining` is a percentage (100 = untouched).
public struct SLO: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String?
    public let service: String?
    public let sloType: String?
    public let target: Double?
    public let current: Double?
    public let status: String?
    public let timeWindow: String?
    public let budgetRemaining: Double?

    public var id: String { "\(namespace ?? "")/\(name)" }

    enum CodingKeys: String, CodingKey {
        case name, namespace, service, target, current, status
        case sloType = "slo_type", timeWindow = "time_window", budgetRemaining = "budget_remaining"
    }
}

public struct SLOStats: Decodable, Sendable {
    public let totalSlos: Int?
    public let meetingTarget: Int?
    public let atRisk: Int?
    public let violated: Int?
    public let averageErrorBudgetRemaining: Double?

    enum CodingKeys: String, CodingKey {
        case totalSlos = "total_slos", meetingTarget = "meeting_target", atRisk = "at_risk", violated
        case averageErrorBudgetRemaining = "average_error_budget_remaining"
    }
}

/// `GET /alerting/incidents` item. The live collection was empty; shape is from the OpenAPI schema.
public struct AlertIncident: Decodable, Sendable, Identifiable, Hashable {
    public let incidentId: String
    public let title: String?
    public let description: String?
    public let severity: String?
    public let status: String?
    public let assignedTo: String?
    public let alertIds: [String]?
    public let createdAt: String?
    public let resolvedAt: String?

    public var id: String { incidentId }

    enum CodingKeys: String, CodingKey {
        case title, description, severity, status
        case incidentId = "incident_id", assignedTo = "assigned_to", alertIds = "alert_ids"
        case createdAt = "created_at", resolvedAt = "resolved_at"
    }
}

public struct ClusterHealth: Decodable, Sendable, Hashable {
    public let status: String?
    public let totalNodes: Int?
    public let readyNodes: Int?
    public let totalVms: Int?
    public let runningVms: Int?
    public let warningEventsLastHour: Int?

    enum CodingKeys: String, CodingKey {
        case status, totalNodes = "total_nodes", readyNodes = "ready_nodes"
        case totalVms = "total_vms", runningVms = "running_vms", warningEventsLastHour = "warning_events_last_hour"
    }
}

/// `GET /cluster/incidents`: cluster-detected incidents plus health. Items are free-form (always empty so far).
public struct ClusterIncidents: Decodable, Sendable {
    public let incidents: [JSONValue]
    public let clusterHealth: ClusterHealth?

    enum CodingKeys: String, CodingKey { case incidents, clusterHealth = "cluster_health" }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        incidents = try c.decodeIfPresent([JSONValue].self, forKey: .incidents) ?? []
        clusterHealth = try c.decodeIfPresent(ClusterHealth.self, forKey: .clusterHealth)
    }
}

public struct Tenant: Decodable, Sendable, Identifiable, Hashable {
    public let tenantId: String
    public let name: String?
    public let displayName: String?
    public let tier: String?
    public let status: String?
    public let namespaceCount: Int?
    public let totalCpuCores: Double?
    public let totalMemoryGb: Double?

    public var id: String { tenantId }

    enum CodingKeys: String, CodingKey {
        case name, tier, status
        case tenantId = "tenant_id", displayName = "display_name", namespaceCount = "namespace_count"
        case totalCpuCores = "total_cpu_cores", totalMemoryGb = "total_memory_gb"
    }
}

extension ZeusClient {
    public func alertingRules() async throws -> [AlertingRule] { try await list("alerting", "rules") }
    public func alertingChannels() async throws -> [AlertingChannel] { try await list("alerting", "channels") }
    public func notificationChannels() async throws -> [NotificationChannel] { try await list("notifications", "channels") }
    public func notificationHistory() async throws -> [NotificationRecord] { try await list("notifications", "history") }
    public func slos() async throws -> [SLO] { try await list("slo", "slos") }
    public func sloStats() async throws -> SLOStats { try await get("slo", "stats") }
    public func alertIncidents() async throws -> [AlertIncident] { try await list("alerting", "incidents") }
    public func clusterIncidents() async throws -> ClusterIncidents { try await get("cluster", "incidents") }
    public func tenants() async throws -> [Tenant] { try await list("tenancy", "tenants") }
}
