import Foundation

/// One read-only GET list/status endpoint shown on a tail-observability screen. Every one is a plain GET;
/// nothing here starts a run, a test, a simulation or a remediation.
public struct TailEndpoint: Sendable, Identifiable, Hashable {
    public let title: String
    public let group: String
    public let segments: [String]
    public var id: String { segments.joined(separator: "/") }
    public init(_ title: String, _ group: String, _ segments: String...) {
        self.title = title; self.group = group; self.segments = segments
    }
}

/// The shape a free-form response takes on screen: a table (with any scalar siblings as a summary) or a record.
public enum TailPayload: Sendable, Equatable {
    case rows([JSONValue], summary: [String: JSONValue])
    case record(JSONValue)

    public init(_ value: JSONValue) {
        let value = TailPayload.redacted(value)
        if let a = value.array { self = .rows(a, summary: [:]); return }
        if let o = value.object {
            // The biggest array of objects is the table; scalar siblings (totals, messages) become the summary.
            let tables = o.filter { $0.value.array?.contains { $0.object != nil } == true }
            if let key = tables.max(by: { ($0.value.array?.count ?? 0) < ($1.value.array?.count ?? 0) })?.key,
               let rows = o[key]?.array {
                self = .rows(rows, summary: o.filter { TailPayload.scalar($0.value) }); return
            }
        }
        self = .record(value)
    }

    static func scalar(_ v: JSONValue) -> Bool {
        switch v { case .array, .object: false; default: true }
    }

    static let secretWords = ["token", "key", "secret", "password"]

    /// Masks any non-empty string under a credential-looking key (the SIEM config carries HEC tokens and shared keys).
    public static func redacted(_ v: JSONValue) -> JSONValue {
        switch v {
        case .array(let a): return .array(a.map(redacted))
        case .object(let o):
            return .object(o.reduce(into: [:]) { out, kv in
                let secret = secretWords.contains { kv.key.localizedCaseInsensitiveContains($0) }
                if secret, case .string(let s) = kv.value, !s.isEmpty { out[kv.key] = .string("••••••") }
                else { out[kv.key] = redacted(kv.value) }
            })
        default: return v
        }
    }
}

/// `/heatmap`: one cell per machine, with usage per metric. Units differ per metric, so a view colours one metric at a time.
public struct HeatmapCell: Decodable, Sendable, Identifiable, Equatable {
    public let vmName: String
    public let namespace: String
    public let node: String?
    public let cpuUsage: Double
    public let memoryUsage: Double
    public let diskUsage: Double
    public let networkUsage: Double
    public let status: String
    public let healthScore: Double
    public var id: String { "\(namespace)/\(vmName)" }

    enum CodingKeys: String, CodingKey {
        case vmName = "vm_name", namespace, node, status
        case cpuUsage = "cpu_usage", memoryUsage = "memory_usage", diskUsage = "disk_usage"
        case networkUsage = "network_usage", healthScore = "health_score"
    }

    public func value(_ metric: String) -> Double {
        switch metric {
        case "memory": memoryUsage
        case "disk": diskUsage
        case "network": networkUsage
        default: cpuUsage
        }
    }
}

public struct Heatmap: Decodable, Sendable, Equatable {
    public let cells: [HeatmapCell]
    public let metrics: [String]
    public let timestamp: String?
}

extension ZeusClient {
    public func tail(_ e: TailEndpoint) async throws -> TailPayload {
        let v: JSONValue
        switch e.segments.count {
        case 1: v = try await get(e.segments[0])
        case 2: v = try await get(e.segments[0], e.segments[1])
        default: v = try await get(e.segments[0], e.segments[1], e.segments[2])
        }
        return TailPayload(v)
    }

    public func heatmap() async throws -> Heatmap { try await get("heatmap") }
}

public enum TailCatalog {
    public static let metrics: [TailEndpoint] = [
        .init("Custom metrics", "Metrics", "custom-metrics", "metrics"),
        .init("Providers", "Metrics", "custom-metrics", "providers"),
        .init("Adapters", "Metrics", "custom-metrics", "adapters"),
        .init("External metrics", "Metrics", "custom-metrics", "external-metrics"),
        .init("Metric alerts", "Metrics", "custom-metrics", "alerts"),
        .init("Configurations", "Metrics", "custom-metrics", "configurations"),
        .init("Metric dashboards", "Metrics", "custom-metrics", "dashboards"),
        .init("Statistics", "Metrics", "custom-metrics", "statistics"),
        .init("Metrics audit", "Metrics", "custom-metrics", "audit"),
        .init("Dashboards", "Dashboards", "custom-dashboards", "dashboards"),
        .init("Favorites", "Dashboards", "custom-dashboards", "favorites"),
        .init("Shared", "Dashboards", "custom-dashboards", "shared"),
        .init("Templates", "Dashboards", "custom-dashboards", "templates"),
        .init("Widget types", "Dashboards", "custom-dashboards", "widgets", "types"),
        .init("Folders", "Dashboards", "folders"),
        .init("Prometheus instances", "Prometheus", "prometheus"),
        .init("Prometheus rules", "Prometheus", "prometheusrules"),
        .init("Service monitors", "Prometheus", "servicemonitors"),
        .init("Monitoring stats", "Prometheus", "monitoring", "stats"),
        .init("Monitoring targets", "Prometheus", "monitoring", "targets"),
        .init("Exporters", "Tracing", "observability", "exporters"),
        .init("Samplers", "Tracing", "observability", "samplers"),
        .init("Instrumentation", "Tracing", "observability", "instrumentation", "status"),
    ]

    /// The heatmap is a custom view, listed first on the Activity screen.
    public static let activity: [TailEndpoint] = [
        .init("Event feed", "Activity", "activity", "feed"),
        .init("Alert history", "Activity", "alert-history"),
        .init("Alert rules", "Activity", "alert-rules"),
        .init("Capacity trend", "Analytics", "analytics", "capacity-trend"),
        .init("Cluster health", "Health", "health", "cluster"),
        .init("Readiness", "Health", "health", "readiness"),
    ]

    public static let databases: [TailEndpoint] = [
        .init("Databases", "DB ops", "dbops", "databases"),
        .init("Connections", "DB ops", "dbops", "connections"),
        .init("Slow queries", "DB ops", "dbops", "queries"),
        .init("Locks", "DB ops", "dbops", "locks"),
        .init("Index recommendations", "DB ops", "dbops", "indexes"),
        .init("Migrations", "DB ops", "dbops", "migrations"),
        .init("Schema changes", "DB ops", "dbops", "schema-changes"),
        .init("DB backups", "DB ops", "dbops", "backups"),
        .init("Databases", "Data", "data", "databases"),
        .init("Datasets", "Data", "data", "datasets"),
        .init("Volumes", "Data", "data", "volumes"),
        .init("Snapshots", "Data", "data", "snapshots"),
        .init("Backups", "Data", "data", "backups"),
        .init("Pipelines", "Data", "data", "pipelines"),
        .init("ETL jobs", "Data", "data", "etl-jobs"),
        .init("Quality checks", "Data", "data", "data-quality", "checks"),
        .init("Quality reports", "Data", "data", "data-quality", "reports"),
    ]

    public static let testing: [TailEndpoint] = [
        .init("Capabilities", "Load tests", "perf-testing", "capabilities"),
        .init("Tests", "Load tests", "perf-testing", "tests"),
        .init("Runs", "Load tests", "perf-testing", "runs"),
        .init("Live metrics", "Load tests", "perf-testing", "metrics", "live"),
        .init("Profiles", "Load tests", "perf-testing", "profiles"),
        .init("Benchmarks", "Load tests", "perf-testing", "benchmarks"),
        .init("Reports", "Load tests", "perf-testing", "reports"),
        .init("Cluster performance", "Performance", "performance", "cluster"),
        .init("Bottlenecks", "Performance", "performance", "bottlenecks"),
        .init("Trends", "Performance", "performance", "trends"),
    ]

    public static let operations: [TailEndpoint] = [
        .init("Backup schedules", "Operations", "backup-schedules"),
        .init("Migration engines", "Operations", "migration-engines", "config"),
        .init("Automation rules", "Automation", "automation", "rules"),
        .init("Automation triggers", "Automation", "automation", "triggers"),
        .init("Automation actions", "Automation", "automation", "actions"),
        .init("Remediation audit", "Operations", "remediation", "audit"),
        .init("SIEM config", "Operations", "siem", "config"),
        .init("Chargeback", "Cost", "chargeback", "engine"),
        .init("Cost per namespace", "Cost", "cost", "per-namespace"),
        .init("VM costs", "Cost", "costs", "vms"),
        .init("Cost optimizations", "Cost", "costs", "optimizations"),
        .init("SLO objectives", "SLO management", "slo-management", "objectives"),
        .init("SLAs", "SLO management", "slo-management", "slas"),
        .init("Error budgets", "SLO management", "slo-management", "error-budgets"),
        .init("Burn rate", "SLO management", "slo-management", "burn-rate"),
        .init("Compliance windows", "SLO management", "slo-management", "windows"),
        .init("SLO alerts", "SLO management", "slo-management", "alerts"),
        .init("SLA reports", "SLO management", "slo-management", "sla-reports"),
        .init("SLO metrics", "SLO management", "slo-management", "metrics"),
    ]
}
