import Foundation

// Read-only scheduling and cluster-policy feeds. Priority classes and PDBs have typed models confirmed
// against the live server; every other feed is carried as free-form JSON.

public struct PriorityClassInfo: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let value: Int?, usageCount: Int?
    public let globalDefault: Bool?
    public let description: String?, preemptionPolicy: String?, createdAt: String?
    public var id: String { name }
    enum CodingKeys: String, CodingKey {
        case name, value, description
        case usageCount = "usage_count", globalDefault = "global_default", preemptionPolicy = "preemption_policy", createdAt = "created_at"
    }
}

/// `GET /pdb`: one row per PodDisruptionBudget with live health counts. "N/A" means the field is unset.
public struct PDBStatus: Decodable, Sendable, Identifiable, Hashable {
    public let name: String, namespace: String
    public let minAvailable: String?, maxUnavailable: String?
    public let currentHealthy: Int?, desiredHealthy: Int?, disruptionsAllowed: Int?, expectedPods: Int?
    public var id: String { "\(namespace)/\(name)" }
    enum CodingKeys: String, CodingKey {
        case name, namespace
        case minAvailable = "min_available", maxUnavailable = "max_unavailable", currentHealthy = "current_healthy"
        case desiredHealthy = "desired_healthy", disruptionsAllowed = "disruptions_allowed", expectedPods = "expected_pods"
    }
}

public struct SchedFeed: Sendable, Identifiable, Hashable {
    public enum Kind: Sendable, Hashable { case json, priorityClasses, pdbs }
    public let title: String
    public let path: [String]
    public let kind: Kind
    public var id: String { path.joined(separator: "/") }
    init(_ title: String, _ path: String, kind: Kind = .json) {
        self.title = title; self.path = path.split(separator: "/").map(String.init); self.kind = kind
    }

    public static let placement: [SchedFeed] = [
        .init("Affinity conflicts", "affinity-rules/conflicts"),
        .init("Affinity violations", "affinity-rules/violations"),
        .init("Affinity statistics", "affinity-rules/statistics"),
        .init("Spread analysis", "affinity-rules/spread-analysis"),
        .init("Pod affinities", "pod-affinities"),
        .init("Node taints", "node-taints"),
        .init("Pod tolerations", "pod-tolerations"),
        .init("Taint coverage", "taints-tolerations/coverage"),
        .init("Taint statistics", "taints-tolerations/statistics"),
        .init("Topology nodes", "topology-manager/nodes"),
        .init("Topology zones", "topology-manager/zones"),
        .init("Topology violations", "topology-manager/violations"),
        .init("Placement templates", "placement/templates"),
    ]
    public static let classesAndBudgets: [SchedFeed] = [
        .init("Priority classes", "priority-classes", kind: .priorityClasses),
        .init("Priority usage", "priority-classes/usage"),
        .init("Preemption analysis", "priority-classes/preemption/analysis"),
        .init("Runtime classes", "runtime-classes"),
        .init("Runtime usage", "runtime-classes/usage"),
        .init("Runtime benchmarks", "runtime-classes/benchmarks"),
        .init("Disruption budgets", "pdb", kind: .pdbs),
        .init("Budget details", "pod-disruption-budgets"),
        .init("Budget coverage", "pod-disruption-budgets/coverage"),
        .init("Budget health", "pod-disruption-budgets/health"),
        .init("Budget recommendations", "pod-disruption-budgets/recommendations"),
    ]
    public static let quotasAndGovernance: [SchedFeed] = [
        .init("Quotas", "quotas"),
        .init("Quota dashboard", "quotas/dashboard"),
        .init("Resource quotas", "resource-quotas/quotas"),
        .init("Allocations", "resource-quotas/allocations"),
        .init("Capacity", "resource-quotas/capacity"),
        .init("Utilization", "resource-quotas/utilization"),
        .init("Reports", "resource-quotas/reports"),
        .init("Governance quotas", "governance/resourcequotas"),
        .init("Priority class usage", "governance/priorityclass-usage"),
        .init("Resource pools", "resource-pools"),
        .init("Scheduling stats", "scheduling/stats"),
        .init("Tags", "resource-tagging/tags"),
        .init("Tag recommendations", "resource-tagging/tag-recommendations"),
        .init("Tag compliance", "resource-tagging/compliance"),
        .init("Tag analytics", "resource-tagging/analytics"),
    ]
    public static let autoscaling: [SchedFeed] = [
        .init("HPA", "hpa"),
        .init("HPA statistics", "hpa/stats"),
        .init("VPA", "vpa"),
        .init("Autoscaler", "autoscaler"),
        .init("Autoscaler config", "autoscaler/config"),
        .init("Cluster status", "cluster-autoscaling/status"),
        .init("Cluster health", "cluster-autoscaling/health"),
        .init("Node groups", "cluster-autoscaling/node-groups"),
        .init("Limits", "cluster-autoscaling/limits"),
        .init("Metrics", "cluster-autoscaling/metrics"),
        .init("Forecast", "forecasting"),
        .init("Capacity forecast", "forecasting/capacity"),
        .init("Seasonal forecast", "forecasting/seasonal"),
    ]
    public static let devicesAndHosts: [SchedFeed] = [
        .init("Device plugins", "device-plugins"),
        .init("Device health", "device-plugins/health-checks"),
        .init("Device usage", "device-plugins/usage"),
        .init("Device capacity", "device-plugins/capacity"),
        .init("Device recommendations", "device-plugins/recommendations"),
        .init("GPUs", "devices/gpu"),
        .init("Mediated devices", "devices/mdev"),
        .init("Host groups", "host-groups"),
    ]
}

public extension ZeusClient {
    /// GET one feed as free-form JSON (list, `{items}` or a single object).
    func schedFeed(_ feed: SchedFeed) async throws -> JSONValue {
        let p = feed.path
        switch p.count {
        case 1: return try await get(p[0])
        case 2: return try await get(p[0], p[1])
        default: return try await get(p[0], p[1], p[2])
        }
    }
    func priorityClasses() async throws -> [PriorityClassInfo] { try await list("priority-classes") }
    func pdbStatuses() async throws -> [PDBStatus] { try await list("pdb") }
}

public extension JSONValue {
    /// Rows for a table: a bare array, the `items` of a wrapper, or nil for a single record.
    var tableRows: [JSONValue]? {
        if let a = array { return a }
        if let a = self["items"]?.array { return a }
        return nil
    }
}
