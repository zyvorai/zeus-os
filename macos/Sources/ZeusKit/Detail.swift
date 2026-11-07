import Foundation

// Detail views: node and host depth, workflow executions, SLOs, RBAC. Fields are optional unless certain.

public struct NodeCondition: Decodable, Sendable, Identifiable, Hashable {
    public let type: String
    public let status: String?
    public let reason: String?
    public let message: String?
    public let lastTransitionTime: String?
    public var id: String { type }
    /// For pressure and unavailable conditions "True" is bad; for "Ready" it is good.
    public var isHealthy: Bool {
        let positive = ["Ready"].contains(type)
        return positive ? status == "True" : status != "True"
    }
}

public struct NodeDetail: Decodable, Sendable {
    public let name: String
    public let status: String?
    public let roles: [String]
    public let version: String?
    public let age: String?
    public let podCapacity: Int?
    public let cpuCapacityMillicores: Double?
    public let memCapacityBytes: Double?
    public let conditions: [NodeCondition]
    public let capacity: [String: String]
    public let allocatable: [String: String]
    public let addresses: [String]
    public let osImage: String?
    public let kernelVersion: String?
    public let kubeletVersion: String?
    public let containerRuntime: String?
    public let unschedulable: Bool
    public let taints: [String]

    enum CodingKeys: String, CodingKey {
        case name, status, roles, version, age, raw
        case podCapacity = "pod_capacity", cpuCapacityMillicores = "cpu_capacity_millicores", memCapacityBytes = "mem_capacity_bytes"
    }
    struct Raw: Decodable {
        struct Spec: Decodable {
            struct Taint: Decodable { let key: String?; let value: String?; let effect: String? }
            let unschedulable: Bool?; let taints: [Taint]?
        }
        struct Status: Decodable {
            struct Addr: Decodable { let type: String?; let address: String? }
            struct Info: Decodable { let osImage: String?; let kernelVersion: String?; let kubeletVersion: String?; let containerRuntimeVersion: String? }
            let conditions: [NodeCondition]?; let capacity: [String: String]?; let allocatable: [String: String]?
            let addresses: [Addr]?; let nodeInfo: Info?
        }
        let spec: Spec?; let status: Status?
    }

    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        status = try? c.decodeIfPresent(String.self, forKey: .status)
        roles = (try? c.decodeIfPresent([String].self, forKey: .roles)) ?? []
        version = try? c.decodeIfPresent(String.self, forKey: .version)
        age = try? c.decodeIfPresent(String.self, forKey: .age)
        podCapacity = try? c.decodeIfPresent(Int.self, forKey: .podCapacity)
        cpuCapacityMillicores = try? c.decodeIfPresent(Double.self, forKey: .cpuCapacityMillicores)
        memCapacityBytes = try? c.decodeIfPresent(Double.self, forKey: .memCapacityBytes)
        let raw = try? c.decodeIfPresent(Raw.self, forKey: .raw)
        conditions = raw?.status?.conditions ?? []
        capacity = raw?.status?.capacity ?? [:]
        allocatable = raw?.status?.allocatable ?? [:]
        addresses = (raw?.status?.addresses ?? []).compactMap { a in a.address.map { "\(a.type ?? "") \($0)".trimmingCharacters(in: .whitespaces) } }
        osImage = raw?.status?.nodeInfo?.osImage
        kernelVersion = raw?.status?.nodeInfo?.kernelVersion
        kubeletVersion = raw?.status?.nodeInfo?.kubeletVersion
        containerRuntime = raw?.status?.nodeInfo?.containerRuntimeVersion
        unschedulable = raw?.spec?.unschedulable ?? false
        taints = (raw?.spec?.taints ?? []).map { "\($0.key ?? "?")\($0.value.map { "=\($0)" } ?? ""):\($0.effect ?? "")" }
    }
}

public struct NodeDrainStatus: Decodable, Sendable {
    public let node: String?
    public let cordoned: Bool?
    public let totalPods: Int?
    public let evictingPods: Int?
    public let completedPods: Int?
    public let vmsOnNode: [String]
    public let migrationsInProgress: [JSONValue]
    enum CodingKeys: String, CodingKey {
        case node, cordoned, totalPods = "total_pods", evictingPods = "evicting_pods", completedPods = "completed_pods"
        case vmsOnNode = "vms_on_node", migrationsInProgress = "migrations_in_progress"
    }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        node = try? c.decodeIfPresent(String.self, forKey: .node)
        cordoned = try? c.decodeIfPresent(Bool.self, forKey: .cordoned)
        totalPods = try? c.decodeIfPresent(Int.self, forKey: .totalPods)
        evictingPods = try? c.decodeIfPresent(Int.self, forKey: .evictingPods)
        completedPods = try? c.decodeIfPresent(Int.self, forKey: .completedPods)
        vmsOnNode = (try? c.decodeIfPresent([String].self, forKey: .vmsOnNode)) ?? []
        migrationsInProgress = (try? c.decodeIfPresent([JSONValue].self, forKey: .migrationsInProgress)) ?? []
    }
}

public struct NodeProblem: Decodable, Sendable, Identifiable, Hashable {
    public let conditionType: String
    public let status: String?
    public let message: String?
    public let lastTransition: String?
    public var id: String { conditionType }
    enum CodingKeys: String, CodingKey { case conditionType = "condition_type", status, message, lastTransition = "last_transition" }
}

public struct NodePod: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String
    public let status: String?
    public let node: String?
    public let age: String?
    public let ready: String?
    public let restartCount: Int?
    public var id: String { "\(namespace)/\(name)" }
    enum CodingKeys: String, CodingKey { case name, namespace, status, node, age, ready, restartCount = "restart_count" }
}

public struct HostPCIDevice: Decodable, Sendable, Identifiable, Hashable {
    public let slot: String
    public let deviceClass: String?
    public let vendor: String?
    public let device: String?
    public let iommuGroup: String?
    public var id: String { slot }
    enum CodingKeys: String, CodingKey { case slot, deviceClass = "class", vendor, device, iommuGroup = "iommu_group" }
}

public struct HostInterface: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let macAddress: String?
    public let ipAddresses: [String]
    public let mtu: Int?
    public let state: String?
    public let speedMbps: Double?
    public let rxBytes: Double?
    public let txBytes: Double?
    public var id: String { name }
    enum CodingKeys: String, CodingKey {
        case name, mtu, state
        case macAddress = "mac_address", ipAddresses = "ip_addresses", speedMbps = "speed_mbps", rxBytes = "rx_bytes", txBytes = "tx_bytes"
    }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        macAddress = try? c.decodeIfPresent(String.self, forKey: .macAddress)
        ipAddresses = (try? c.decodeIfPresent([String].self, forKey: .ipAddresses)) ?? []
        mtu = try? c.decodeIfPresent(Int.self, forKey: .mtu)
        state = try? c.decodeIfPresent(String.self, forKey: .state)
        speedMbps = try? c.decodeIfPresent(Double.self, forKey: .speedMbps)
        rxBytes = try? c.decodeIfPresent(Double.self, forKey: .rxBytes)
        txBytes = try? c.decodeIfPresent(Double.self, forKey: .txBytes)
    }
}

public struct HostService: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let state: String?
    public let subState: String?
    public let description: String?
    public var id: String { name }
    enum CodingKeys: String, CodingKey { case name, state, description, subState = "sub_state" }
}

// MARK: Workflows

extension WorkflowExecution {
    /// The server addresses an execution by its workflow name, i.e. the part of `namespace/name` after the slash.
    /// The full id with the slash (raw or %2F-encoded) 404s on the live server, and `workflow_id` is that last part.
    public var pathKey: String { WorkflowExecution.pathKey(forId: id, workflowId: workflowId) }
    public static func pathKey(forId id: String, workflowId: String?) -> String {
        if let w = workflowId, !w.isEmpty { return w }
        return id.split(separator: "/").last.map(String.init) ?? id
    }
}

public struct WorkflowStepResult: Decodable, Sendable, Identifiable {
    public let stepName: String
    public let status: String?
    public let startedAt: String?
    public let finishedAt: String?
    public let output: JSONValue?
    public let error: String?
    public var id: String { stepName }
    enum CodingKeys: String, CodingKey { case stepName = "step_name", status, startedAt = "started_at", finishedAt = "finished_at", output, error }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        stepName = try c.decode(String.self, forKey: .stepName)
        status = try? c.decodeIfPresent(String.self, forKey: .status)
        startedAt = try? c.decodeIfPresent(String.self, forKey: .startedAt)
        finishedAt = try? c.decodeIfPresent(String.self, forKey: .finishedAt)
        output = try? c.decodeIfPresent(JSONValue.self, forKey: .output)
        error = try? c.decodeIfPresent(String.self, forKey: .error)
    }
}

public struct WorkflowExecutionDetail: Decodable, Sendable {
    public let execution: WorkflowExecution
    public let stepResults: [WorkflowStepResult]
    public let output: JSONValue?
    enum CodingKeys: String, CodingKey { case execution, stepResults = "step_results", output }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        execution = try c.decode(WorkflowExecution.self, forKey: .execution)
        stepResults = (try? c.decodeIfPresent([WorkflowStepResult].self, forKey: .stepResults)) ?? []
        output = try? c.decodeIfPresent(JSONValue.self, forKey: .output)
    }
}

// MARK: SLOs

public struct SLOBudget: Decodable, Sendable {
    public let totalBudget: Double?, consumed: Double?, remaining: Double?, remainingPercentage: Double?
    public let burnRate: Double?, estimatedDepletion: String?
    enum CodingKeys: String, CodingKey {
        case consumed, remaining
        case totalBudget = "total_budget", remainingPercentage = "remaining_percentage", burnRate = "burn_rate", estimatedDepletion = "estimated_depletion"
    }
}

public struct SLOHistoryPoint: Decodable, Sendable, Identifiable, Hashable {
    public let timestamp: String
    public let value: Double?
    public let budgetRemaining: Double?
    public var id: String { timestamp }
    enum CodingKeys: String, CodingKey { case timestamp, value, budgetRemaining = "budget_remaining" }
}

public struct SLODetail: Decodable, Sendable {
    public struct Config: Decodable, Sendable {
        public let sloType: String?, targetPercentage: Double?, measurementMethod: String?
        enum CodingKeys: String, CodingKey { case sloType = "slo_type", targetPercentage = "target_percentage", measurementMethod = "measurement_method" }
    }
    public struct Performance: Decodable, Sendable {
        public let currentPercentage: Double?, totalRequests: Double?, goodRequests: Double?, badRequests: Double?, status: String?
        enum CodingKeys: String, CodingKey {
            case status, currentPercentage = "current_percentage", totalRequests = "total_requests", goodRequests = "good_requests", badRequests = "bad_requests"
        }
    }
    public let name: String
    public let namespace: String?
    public let service: String?
    public let description: String?
    public let sloConfig: Config?
    public let currentPerformance: Performance?
    public let errorBudget: SLOBudget?
    public let historicalData: [SLOHistoryPoint]
    public let alertCount: Int
    enum CodingKeys: String, CodingKey {
        case name, namespace, service, description, alerts
        case sloConfig = "slo_config", currentPerformance = "current_performance", errorBudget = "error_budget", historicalData = "historical_data"
    }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        namespace = try? c.decodeIfPresent(String.self, forKey: .namespace)
        service = try? c.decodeIfPresent(String.self, forKey: .service)
        description = try? c.decodeIfPresent(String.self, forKey: .description)
        sloConfig = try? c.decodeIfPresent(Config.self, forKey: .sloConfig)
        currentPerformance = try? c.decodeIfPresent(Performance.self, forKey: .currentPerformance)
        errorBudget = try? c.decodeIfPresent(SLOBudget.self, forKey: .errorBudget)
        historicalData = (try? c.decodeIfPresent([SLOHistoryPoint].self, forKey: .historicalData)) ?? []
        alertCount = ((try? c.decodeIfPresent([JSONValue].self, forKey: .alerts)) ?? []).count
    }
}

// MARK: RBAC

public struct RoleSummary: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String?
    public let isClusterRole: Bool
    public let rulesCount: Int?
    public var id: String { "\(namespace ?? "*")/\(name)" }
    enum CodingKeys: String, CodingKey { case name, namespace, isClusterRole = "is_cluster_role", rulesCount = "rules_count" }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        namespace = try? c.decodeIfPresent(String.self, forKey: .namespace)
        isClusterRole = (try? c.decodeIfPresent(Bool.self, forKey: .isClusterRole)) ?? (namespace == nil)
        rulesCount = try? c.decodeIfPresent(Int.self, forKey: .rulesCount)
    }
}

public struct RoleRule: Decodable, Sendable, Identifiable, Hashable {
    public let apiGroups: [String], resources: [String], verbs: [String], resourceNames: [String]
    public let id = UUID()
    enum CodingKeys: String, CodingKey { case apiGroups = "api_groups", resources, verbs, resourceNames = "resource_names" }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        apiGroups = (try? c.decodeIfPresent([String].self, forKey: .apiGroups)) ?? []
        resources = (try? c.decodeIfPresent([String].self, forKey: .resources)) ?? []
        verbs = (try? c.decodeIfPresent([String].self, forKey: .verbs)) ?? []
        resourceNames = (try? c.decodeIfPresent([String].self, forKey: .resourceNames)) ?? []
    }
    public var isWildcard: Bool { verbs.contains("*") && resources.contains("*") }
}

public struct RoleDetail: Decodable, Sendable {
    public let name: String
    public let namespace: String?
    public let rules: [RoleRule]
    enum CodingKeys: String, CodingKey { case name, namespace, rules }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        namespace = try? c.decodeIfPresent(String.self, forKey: .namespace)
        rules = (try? c.decodeIfPresent([RoleRule].self, forKey: .rules)) ?? []
    }
}

public struct RoleBindingSummary: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String?
    public let isClusterBinding: Bool?
    public let roleName: String?
    public let roleKind: String?
    public let subjectsCount: Int?
    public var id: String { "\(namespace ?? "*")/\(name)" }
    enum CodingKeys: String, CodingKey {
        case name, namespace, isClusterBinding = "is_cluster_binding", roleName = "role_name", roleKind = "role_kind", subjectsCount = "subjects_count"
    }
}

public struct MyPermissions: Decodable, Sendable {
    public struct NS: Decodable, Sendable, Identifiable, Hashable {
        public let namespace: String
        public let canManageVMs: Bool?
        public var id: String { namespace }
        enum CodingKeys: String, CodingKey { case namespace, canManageVMs = "can_manage_vms" }
    }
    public let flags: [String: Bool]
    public let namespaceAccess: [NS]
    enum CodingKeys: String, CodingKey { case namespaceAccess = "namespace_access" }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        namespaceAccess = (try? c.decodeIfPresent([NS].self, forKey: .namespaceAccess)) ?? []
        let all = try d.singleValueContainer().decode([String: JSONValue].self)
        flags = all.compactMapValues { $0.bool }
    }
}

// MARK: Client

extension ZeusClient {
    public func nodeDetail(_ name: String) async throws -> NodeDetail { try await get("nodes", name) }
    public func nodeDrainStatus(_ name: String) async throws -> NodeDrainStatus { try await get("nodes", name, "drain-status") }
    public func nodeProblems(_ name: String) async throws -> [NodeProblem] { try await list("nodes", name, "problems") }
    public func nodePods(_ name: String) async throws -> [NodePod] {
        let all: [NodePod] = try await list("pods")
        return all.filter { $0.node == name }
    }

    /// Removes the node from maintenance (uncordon). The response is a free-form result we ignore; callers re-read the node.
    /// NOTE: unit-tested for request shape only; never exercised against the shared live server.
    public func uncordonNode(_ name: String) async throws { _ = try await raw(try request(Self.uncordonPath(name), method: "POST")) }
    static func uncordonPath(_ name: String) -> String { Self.path(["nodes", name, "uncordon"]) }

    public func hostPCI() async throws -> [HostPCIDevice] { try await list("host", "pci") }
    public func hostInterfaces() async throws -> [HostInterface] { try await list("host", "interfaces") }
    public func hostServices() async throws -> [HostService] { try await list("host", "services") }

    public func workflowExecution(_ e: WorkflowExecution) async throws -> WorkflowExecutionDetail {
        try await get("workflows", "executions", e.pathKey)
    }
    public func workflowExecutionLogs(_ e: WorkflowExecution) async throws -> [String] {
        try await list("workflows", "executions", e.pathKey, "logs")
    }
    public func pipelineRuns(of pipelineID: String) async throws -> [JSONValue] { try await list("cicd", "pipelines", pipelineID, "runs") }

    public func sloDetail(_ s: SLO) async throws -> SLODetail { try await get("slo", "slos", s.namespace ?? "default", s.name) }

    /// Cluster roles are only listed (the server has no detail route for them); namespaced roles come from `?namespace=`.
    public func roles(namespace: String? = nil) async throws -> [RoleSummary] {
        try await list("rbac", "roles", query: namespace.map { [URLQueryItem(name: "namespace", value: $0)] } ?? [])
    }
    /// Cluster roles plus the namespaced roles of each given namespace (the list only returns namespaced roles when asked per namespace).
    public func allRoles(namespaces: [String]) async -> [RoleSummary] {
        var out = (try? await roles()) ?? []
        await withTaskGroup(of: [RoleSummary].self) { group in
            for ns in namespaces { group.addTask { ((try? await self.roles(namespace: ns)) ?? []).filter { !$0.isClusterRole } } }
            for await r in group { out += r }
        }
        var seen = Set<String>()
        return out.filter { seen.insert($0.id).inserted }.sorted { $0.name < $1.name }
    }
    public func roleDetail(namespace: String, name: String) async throws -> RoleDetail { try await get("rbac", "roles", namespace, name) }
    public func roleBindings() async throws -> [RoleBindingSummary] { try await list("rbac", "rolebindings") }
    public func myPermissions() async throws -> MyPermissions { try await get("rbac", "permissions") }

    /// Untyped lists (image scanning, compliance, gatekeeper, mesh, registry, dependencies, observability).
    public func rows(_ path: [String]) async throws -> [JSONValue] {
        let l: Listing<JSONValue> = try await send(Self.path(path))
        return l.items
    }
}
