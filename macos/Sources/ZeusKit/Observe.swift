import Foundation

// MARK: Logs

public struct LogSource: Decodable, Sendable, Hashable, Identifiable {
    public let resourceType: String?
    public let namespace: String?
    public let name: String
    public let container: String?
    public var id: String { "\(namespace ?? "")/\(name)/\(container ?? "")" }
    enum CodingKeys: String, CodingKey { case resourceType = "resource_type", namespace, name, container }
}

/// `GET /logs/pods/{ns}/{name}`. Lines are raw text, often JSON with a leading RFC 3339 timestamp.
public struct PodLogs: Decodable, Sendable {
    public let source: LogSource?
    public let logs: [String]
}

/// One parsed log line: optional leading timestamp, a best-effort level, and the message.
public struct LogLine: Sendable, Identifiable, Hashable {
    public let id: Int
    public let raw: String
    public let timestamp: Date?
    public let level: String
    public let message: String

    public init(id: Int, raw: String) {
        self.id = id; self.raw = raw
        var text = raw
        var ts: Date?
        if let sp = raw.firstIndex(of: " "), let d = ZeusDates.parse(String(raw[..<sp])) {
            ts = d; text = String(raw[raw.index(after: sp)...])
        }
        timestamp = ts
        var level = "info", message = text
        if text.hasPrefix("{"), let obj = try? JSONDecoder().decode([String: JSONValue].self, from: Data(text.utf8)) {
            if case .string(let l)? = obj["level"] { level = l.lowercased() }
            if case .string(let m)? = obj["msg"] ?? obj["message"] { message = m }
        } else {
            let l = text.lowercased()
            if l.contains("error") || l.contains("fatal") { level = "error" } else if l.contains("warn") { level = "warning" }
        }
        self.level = level; self.message = message
    }
}

public struct LogEvent: Decodable, Sendable, Identifiable {
    public let timestamp: String?
    public let source: LogSource?
    public let level: String?
    public let message: String?
    public let metadata: [String: String]?
    public var id: String { "\(timestamp ?? "")\(source?.id ?? "")\(message ?? "")" }
    public var date: Date? { timestamp.flatMap(ZeusDates.parse) }
}

public struct LogErrorSource: Decodable, Sendable, Identifiable {
    public let podName: String?
    public let container: String?
    public let errorCount: Int?
    public let lastError: String?
    public var id: String { "\(podName ?? "")/\(container ?? "")" }
    enum CodingKeys: String, CodingKey { case podName = "pod_name", container, errorCount = "error_count", lastError = "last_error" }
}

public struct LogStats: Decodable, Sendable {
    public let namespace: String?
    public let totalPods: Int?
    public let podsWithErrors: Int?
    public let totalLogLines: Int?
    public let errorRatePercent: Double?
    public let warningRatePercent: Double?
    public let topErrorSources: [LogErrorSource]?
    enum CodingKeys: String, CodingKey {
        case namespace, totalPods = "total_pods", podsWithErrors = "pods_with_errors", totalLogLines = "total_log_lines"
        case errorRatePercent = "error_rate_percent", warningRatePercent = "warning_rate_percent", topErrorSources = "top_error_sources"
    }
}

// MARK: Events and anomalies

public struct EventAnomaly: Decodable, Sendable, Identifiable {
    public let anomalyId: String
    public let anomalyType: String?
    public let description: String?
    public let detectedAt: String?
    public let confidenceScore: Double?
    public let severity: String?
    public let baselineMetric: String?
    public let expectedValue: Double?
    public let actualValue: Double?
    public let deviationPercent: Double?
    public var id: String { anomalyId }
    public var date: Date? { detectedAt.flatMap(ZeusDates.parse) }
    enum CodingKeys: String, CodingKey {
        case anomalyId = "anomaly_id", anomalyType = "anomaly_type", description, detectedAt = "detected_at"
        case confidenceScore = "confidence_score", severity, baselineMetric = "baseline_metric"
        case expectedValue = "expected_value", actualValue = "actual_value", deviationPercent = "deviation_percent"
    }
}

public struct TimelineEvent: Decodable, Sendable, Identifiable {
    public let timestamp: String?
    public let eventType: String?
    public let reason: String?
    public let resource: String?
    public let namespace: String?
    public let message: String?
    public let severity: String?
    public var id: String { "\(timestamp ?? "")\(resource ?? "")\(reason ?? "")\(message ?? "")" }
    public var date: Date? { timestamp.flatMap(ZeusDates.parse) }
    enum CodingKeys: String, CodingKey { case timestamp, eventType = "event_type", reason, resource, namespace, message, severity }
}

/// Incidents, patterns, correlations: no live rows exist, so keep them free-form with the common fields lifted out.
public struct EventRecord: Decodable, Sendable, Identifiable {
    public let raw: [String: JSONValue]
    public var id: String { string("incident_id") ?? string("pattern_id") ?? string("correlation_id") ?? string("id") ?? raw.keys.sorted().joined(separator: ",") }
    public init(from decoder: Decoder) throws { raw = try decoder.singleValueContainer().decode([String: JSONValue].self) }
    public func string(_ k: String) -> String? {
        switch raw[k] { case .string(let s)?: s; case .number(let n)?: String(n); default: nil }
    }
}

// MARK: Topology

public struct TopologyNode: Decodable, Sendable, Identifiable {
    public let id: String
    public let name: String?
    public let status: String?
    public let cpuUsage: Double?
    public let memoryUsage: Double?
    public let vmCount: Int?
    enum CodingKeys: String, CodingKey { case id, name, status, cpuUsage = "cpu_usage", memoryUsage = "memory_usage", vmCount = "vm_count" }
}

public struct TopologyVM: Decodable, Sendable, Identifiable {
    public let id: String
    public let name: String?
    public let namespace: String?
    public let status: String?
    public let node: String?
    public let cpuUsage: Double?
    public let memoryUsage: Double?
    enum CodingKeys: String, CodingKey { case id, name, namespace, status, node, cpuUsage = "cpu_usage", memoryUsage = "memory_usage" }
}

/// `GET /topology`: nodes with the VMs placed on them.
public struct Topology: Decodable, Sendable {
    public let nodes: [TopologyNode]
    public let vms: [TopologyVM]
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        nodes = try c.decodeIfPresent([TopologyNode].self, forKey: .nodes) ?? []
        vms = try c.decodeIfPresent([TopologyVM].self, forKey: .vms) ?? []
    }
    enum CodingKeys: String, CodingKey { case nodes, vms }
}

public struct DVRStatus: Decodable, Sendable {
    public let enabled: Bool?
    public let intervalSecs: Int?
    public let clusterFrames: Int?
    public let trackedVMs: Int?
    public let oldest: String?
    public let newest: String?
    enum CodingKeys: String, CodingKey {
        case enabled, intervalSecs = "interval_secs", clusterFrames = "cluster_frames", trackedVMs = "tracked_vms", oldest, newest
    }
}

public struct DVRFrame: Decodable, Sendable, Identifiable {
    public let ts: String
    public let nodesTotal: Int?
    public let nodesReady: Int?
    public let vmsTotal: Int?
    public let vmsRunning: Int?
    public let vmsFailed: Int?
    public let warningEvents: Int?
    public var id: String { ts }
    public var date: Date? { ZeusDates.parse(ts) }
    enum CodingKeys: String, CodingKey {
        case ts, nodesTotal = "nodes_total", nodesReady = "nodes_ready", vmsTotal = "vms_total", vmsRunning = "vms_running"
        case vmsFailed = "vms_failed", warningEvents = "warning_events"
    }
}

public struct DVRCluster: Decodable, Sendable {
    public let intervalSecs: Int?
    public let enabled: Bool?
    public let frames: [DVRFrame]
    enum CodingKeys: String, CodingKey { case intervalSecs = "interval_secs", enabled, frames }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        intervalSecs = try c.decodeIfPresent(Int.self, forKey: .intervalSecs)
        enabled = try c.decodeIfPresent(Bool.self, forKey: .enabled)
        frames = try c.decodeIfPresent([DVRFrame].self, forKey: .frames) ?? []
    }
}

// MARK: APM

public struct APMService: Decodable, Sendable, Identifiable {
    public let name: String
    public let environment: String?
    public let instanceCount: Int?
    public let restartsPerPod: Double?
    public let requestsPerMinute: Double?
    public let errorRate: Double?
    public let avgLatencyMs: Double?
    public let p95LatencyMs: Double?
    public let p99LatencyMs: Double?
    public let apdexScore: Double?
    public let latencySource: String?
    public let latencyReason: String?
    public var id: String { "\(environment ?? "")/\(name)" }
    enum CodingKeys: String, CodingKey {
        case name, environment, instanceCount = "instance_count", restartsPerPod = "restarts_per_pod"
        case requestsPerMinute = "requests_per_minute", errorRate = "error_rate", avgLatencyMs = "avg_latency_ms"
        case p95LatencyMs = "p95_latency_ms", p99LatencyMs = "p99_latency_ms", apdexScore = "apdex_score"
        case latencySource = "latency_source", latencyReason = "latency_reason"
    }
}

// MARK: AI

public struct AIProvider: Decodable, Sendable, Identifiable {
    public let raw: [String: JSONValue]
    public init(from decoder: Decoder) throws { raw = try decoder.singleValueContainer().decode([String: JSONValue].self) }
    public var id: String { string("id") ?? string("name") ?? raw.keys.sorted().joined(separator: ",") }
    public func string(_ k: String) -> String? {
        switch raw[k] { case .string(let s)?: s; case .number(let n)?: String(n); case .bool(let b)?: String(b); default: nil }
    }
}

public struct AIStatus: Decodable, Sendable {
    public let enabledCount: Int?
    public let defaultProviderName: String?
    public let defaultSource: String?
    public let airGapMode: Bool?
    public let providers: [AIProvider]
    enum CodingKeys: String, CodingKey {
        case enabledCount = "enabled_count", defaultProviderName = "default_provider_name", defaultSource = "default_source"
        case airGapMode = "air_gap_mode", providers
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        enabledCount = try c.decodeIfPresent(Int.self, forKey: .enabledCount)
        defaultProviderName = try c.decodeIfPresent(String.self, forKey: .defaultProviderName)
        defaultSource = try c.decodeIfPresent(String.self, forKey: .defaultSource)
        airGapMode = try c.decodeIfPresent(Bool.self, forKey: .airGapMode)
        providers = try c.decodeIfPresent([AIProvider].self, forKey: .providers) ?? []
    }
}

public struct DoctorSummary: Decodable, Sendable {
    public let p1Count: Int?
    public let totalFindings: Int?
    enum CodingKeys: String, CodingKey { case p1Count = "p1_count", totalFindings = "total_findings" }
}

public struct GuestIssue: Decodable, Sendable, Identifiable {
    public let id: String
    public let count: Int?
    public let message: String?
}

public struct GuestFleet: Decodable, Sendable {
    public let vmsScanned: Int?
    public let vmsWithProfile: Int?
    public let issues: [GuestIssue]
    enum CodingKeys: String, CodingKey { case vmsScanned = "vms_scanned", vmsWithProfile = "vms_with_profile", issues }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        vmsScanned = try c.decodeIfPresent(Int.self, forKey: .vmsScanned)
        vmsWithProfile = try c.decodeIfPresent(Int.self, forKey: .vmsWithProfile)
        issues = try c.decodeIfPresent([GuestIssue].self, forKey: .issues) ?? []
    }
}

// MARK: Chaos

public struct ChaosStats: Decodable, Sendable {
    public let totalExperiments: Int?
    public let runningExperiments: Int?
    public let succeededExperiments: Int?
    public let failedExperiments: Int?
    public let resilienceScore: Double?
    enum CodingKeys: String, CodingKey {
        case totalExperiments = "total_experiments", runningExperiments = "running_experiments"
        case succeededExperiments = "succeeded_experiments", failedExperiments = "failed_experiments", resilienceScore = "resilience_score"
    }
}

/// No live experiments exist; decoded per the loose schema, everything optional.
public struct ChaosExperiment: Decodable, Sendable, Identifiable {
    public let name: String?
    public let namespace: String?
    public let experimentType: String?
    public let status: String?
    public var id: String { "\(namespace ?? "")/\(name ?? "")" }
    enum CodingKeys: String, CodingKey { case name, namespace, experimentType = "experiment_type", status }
}

// MARK: Client

extension ZeusClient {
    public func logSources(namespace: String) async throws -> [LogSource] { try await list("logs", "pods", namespace) }

    public func podLogs(namespace: String, pod: String, container: String? = nil, tail: Int = 200) async throws -> PodLogs {
        var q = [URLQueryItem(name: "tail_lines", value: String(tail))]
        if let container { q.append(URLQueryItem(name: "container", value: container)) }
        return try await get("logs", "pods", namespace, pod, query: q)
    }

    public func logEvents(namespace: String) async throws -> [LogEvent] { try await list("logs", "events", namespace) }
    public func logStats(namespace: String) async throws -> LogStats { try await get("logs", "stats", namespace) }

    public func eventAnomalies() async throws -> [EventAnomaly] { try await list("event-analysis", "anomalies") }
    public func eventTimeline() async throws -> [TimelineEvent] { try await list("event-analysis", "timeline") }
    public func eventIncidents() async throws -> [EventRecord] { try await list("event-analysis", "incidents") }

    public func topology() async throws -> Topology { try await get("topology") }
    public func dvrStatus() async throws -> DVRStatus { try await get("dvr", "status") }
    public func dvrCluster() async throws -> DVRCluster { try await get("dvr", "cluster") }

    public func apmServices() async throws -> [APMService] { try await list("apm", "services") }

    public func aiStatus() async throws -> AIStatus { try await get("ai", "status") }
    public func aiDoctor() async throws -> DoctorSummary { try await get("ai", "doctor", "summary") }
    public func guestFleet() async throws -> GuestFleet { try await get("guest-intelligence", "fleet") }

    public func chaosStats() async throws -> ChaosStats { try await get("chaos", "stats") }
    public func chaosExperiments() async throws -> [ChaosExperiment] { try await list("chaos", "experiments") }
}
