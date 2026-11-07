import Foundation

// Read-only identity and platform models. Secrets (token values, client secrets, headers) are never modelled.

public struct AuthUser: Decodable, Sendable, Identifiable, Hashable {
    public let username: String
    public let role: String?
    public var id: String { username }
}

public struct AuthSession: Decodable, Sendable, Identifiable, Hashable {
    public let sessionId: String
    public let subject: String?
    public let role: String?
    public let createdAtSecs: Double?
    public var id: String { sessionId }
    public var createdSort: Double { createdAtSecs ?? 0 }
    public var created: Date? { createdAtSecs.map { Date(timeIntervalSince1970: $0) } }
    enum CodingKeys: String, CodingKey { case sessionId = "session_id", subject, role, createdAtSecs = "created_at_secs" }
}

/// Token metadata only. The live list was empty, so field names are a tolerant guess; the value is never decoded.
public struct APIToken: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String?
    public let scopes: [String]
    public let role: String?
    public let createdAt: String?
    public let lastUsedAt: String?
    public let expiresAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, scopes, role, createdAt = "created_at", lastUsedAt = "last_used_at", expiresAt = "expires_at"
    }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        let rawId = try? c.decodeIfPresent(String.self, forKey: .id)
        name = try? c.decodeIfPresent(String.self, forKey: .name)
        id = rawId ?? name ?? UUID().uuidString
        scopes = (try? c.decodeIfPresent([String].self, forKey: .scopes)) ?? []
        role = try? c.decodeIfPresent(String.self, forKey: .role)
        createdAt = try? c.decodeIfPresent(String.self, forKey: .createdAt)
        lastUsedAt = try? c.decodeIfPresent(String.self, forKey: .lastUsedAt)
        expiresAt = try? c.decodeIfPresent(String.self, forKey: .expiresAt)
    }
}

public struct AuthConfig: Decodable, Sendable {
    public let authRequired: Bool?
    public let mode: String?
}

public struct SSOStatus: Sendable {
    public let mode: String?
    public let oidcConfigured: Bool
    public let oidcIssuer: String?
    public let ldapConfigured: Bool
    public let ldapURL: String?
    public let webauthnEnabled: Bool
    public let webauthnCredentials: Int
}

struct OIDCEnvelope: Decodable { struct Body: Decodable { let configured: Bool?; let issuer: String? }; let oidc: Body? }
struct LDAPEnvelope: Decodable { struct Body: Decodable { let configured: Bool?; let url: String? }; let ldap: Body? }
struct WebAuthnStatus: Decodable { let enabled: Bool?; let credentials: [JSONValue]? }

public struct FleetCluster: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let apiEndpoint: String?
    public let clusterType: String?
    public let region: String?
    public let isLocal: Bool?
    public let status: String?
    public let healthReason: String?
    public let version: String?
    public let nodes: Int?
    public let readyNodes: Int?
    public let vms: Int?
    public let runningVMs: Int?
    public let cpuCores: Double?
    public let memoryGB: Double?
    public let healthScore: Double?
    public var id: String { name }
    enum CodingKeys: String, CodingKey {
        case name, region, status, version, nodes, vms
        case apiEndpoint = "api_endpoint", clusterType = "cluster_type", isLocal = "is_local", healthReason = "health_reason"
        case readyNodes = "ready_nodes", runningVMs = "running_vms", cpuCores = "cpu_cores", memoryGB = "memory_gb", healthScore = "health_score"
    }
}

public struct FleetStats: Decodable, Sendable {
    public let totalClusters: Int?, connectedClusters: Int?, failingClusters: Int?
    public let totalNodes: Int?, totalVMs: Int?, totalCPUCores: Double?, totalMemoryGB: Double?
    enum CodingKeys: String, CodingKey {
        case totalClusters = "total_clusters", connectedClusters = "connected_clusters", failingClusters = "failing_clusters"
        case totalNodes = "total_nodes", totalVMs = "total_vms", totalCPUCores = "total_cpu_cores", totalMemoryGB = "total_memory_gb"
    }
}

public struct FleetData: Sendable { public let clusters: [FleetCluster]; public let stats: FleetStats? }
struct FleetEnvelope: Decodable { let clusters: [FleetCluster]? }

public struct ClusterNode: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let status: String?
    public let roles: [String]
    public let age: String?
    public let version: String?
    public let cpuCapacity: String?
    public let memoryCapacity: String?
    public let schedulable: Bool?
    public var id: String { name }
    enum CodingKeys: String, CodingKey { case name, status, roles, age, version, schedulable, cpuCapacity = "cpu_capacity", memoryCapacity = "memory_capacity" }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        status = try c.decodeIfPresent(String.self, forKey: .status)
        roles = try c.decodeIfPresent([String].self, forKey: .roles) ?? []
        age = try c.decodeIfPresent(String.self, forKey: .age)
        version = try c.decodeIfPresent(String.self, forKey: .version)
        cpuCapacity = try c.decodeIfPresent(String.self, forKey: .cpuCapacity)
        memoryCapacity = try c.decodeIfPresent(String.self, forKey: .memoryCapacity)
        schedulable = try c.decodeIfPresent(Bool.self, forKey: .schedulable)
    }
    /// Kubernetes reports memory as e.g. "32178144Ki".
    public var memoryBytes: Double? {
        guard var s = memoryCapacity else { return nil }
        let units: [(String, Double)] = [("Ki", 1024), ("Mi", 1_048_576), ("Gi", 1_073_741_824), ("Ti", 1_099_511_627_776)]
        for (u, m) in units where s.hasSuffix(u) { s.removeLast(2); return Double(s).map { $0 * m } }
        return Double(s)
    }
}

public struct HostInfo: Decodable, Sendable {
    public let hostname: String?, osPrettyName: String?, kernelVersion: String?, architecture: String?
    public let cpuModel: String?, cpuCores: Int?, cpuThreads: Int?, virtualization: String?
    public let biosVendor: String?, biosVersion: String?, systemVendor: String?, productName: String?
    enum CodingKeys: String, CodingKey {
        case hostname, architecture, virtualization
        case osPrettyName = "os_pretty_name", kernelVersion = "kernel_version", cpuModel = "cpu_model", cpuCores = "cpu_cores", cpuThreads = "cpu_threads"
        case biosVendor = "bios_vendor", biosVersion = "bios_version", systemVendor = "system_vendor", productName = "product_name"
    }
}

/// The live list was empty; fields are a tolerant guess.
public struct HypervisorConnection: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String?
    public let kind: String?
    public let status: String?
    public let host: String?
    enum CodingKeys: String, CodingKey { case id, name, kind, status, host }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        name = try? c.decodeIfPresent(String.self, forKey: .name)
        id = (try? c.decodeIfPresent(String.self, forKey: .id)) ?? name ?? UUID().uuidString
        kind = try? c.decodeIfPresent(String.self, forKey: .kind)
        status = try? c.decodeIfPresent(String.self, forKey: .status)
        host = try? c.decodeIfPresent(String.self, forKey: .host)
    }
}

public struct PluginInfo: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let displayName: String?
    public let description: String?
    public let version: String?
    public let enabled: Bool?
    public let disabledReason: String?
    public let consecutiveFailures: Int?
    public let deliveryCount: Int?
    enum CodingKeys: String, CodingKey {
        case id, description, version, enabled
        case displayName = "display_name", disabledReason = "disabled_reason", consecutiveFailures = "consecutive_failures", deliveryCount = "delivery_count"
    }
}

/// Headers can carry credentials, so they are deliberately not decoded.
public struct LogDestination: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String?
    public let kind: String?
    public let url: String?
    public let enabled: Bool?
}

public struct LogShipRule: Decodable, Sendable, Identifiable, Hashable {
    public let ruleId: String
    public let lastTickAt: String?
    public let linesShipped: Int?
    public let lastError: String?
    public var id: String { ruleId }
    enum CodingKeys: String, CodingKey { case ruleId = "rule_id", lastTickAt = "last_tick_at", linesShipped = "lines_shipped", lastError = "last_error" }
}

public struct MaintenanceWindowInfo: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String?
    public let startTime: String?
    public let endTime: String?
    public let active: Bool?
    public let enabled: Bool?
    public let recurrence: String?
    enum CodingKeys: String, CodingKey { case id, name, active, enabled, recurrence, startTime = "start_time", endTime = "end_time" }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        name = try? c.decodeIfPresent(String.self, forKey: .name)
        id = (try? c.decodeIfPresent(String.self, forKey: .id)) ?? name ?? UUID().uuidString
        startTime = try? c.decodeIfPresent(String.self, forKey: .startTime)
        endTime = try? c.decodeIfPresent(String.self, forKey: .endTime)
        active = try? c.decodeIfPresent(Bool.self, forKey: .active)
        enabled = try? c.decodeIfPresent(Bool.self, forKey: .enabled)
        recurrence = try? c.decodeIfPresent(String.self, forKey: .recurrence)
    }
}

public struct MaintenanceData: Sendable { public let windows: [MaintenanceWindowInfo]; public let note: String? }
struct MaintenanceEnvelope: Decodable {
    struct Exec: Decodable { let note: String? }
    let execution: Exec?
    let windows: [MaintenanceWindowInfo]?
}

extension ZeusClient {
    public func authUsers() async throws -> [AuthUser] { try await list("auth", "users") }
    public func authSessions() async throws -> [AuthSession] { try await list("auth", "sessions") }
    public func apiTokens() async throws -> [APIToken] { try await list("auth", "api-tokens") }

    public func ssoStatus() async throws -> SSOStatus {
        async let cfg: AuthConfig? = try? get("auth", "config")
        async let oidc: OIDCEnvelope? = try? get("auth", "oidc", "config")
        async let ldap: LDAPEnvelope? = try? get("auth", "ldap", "config")
        async let wa: WebAuthnStatus? = try? get("auth", "webauthn", "status")
        let (c, o, l, w) = await (cfg, oidc, ldap, wa)
        return SSOStatus(mode: c?.mode, oidcConfigured: o?.oidc?.configured ?? false, oidcIssuer: o?.oidc?.issuer,
                         ldapConfigured: l?.ldap?.configured ?? false, ldapURL: l?.ldap?.url,
                         webauthnEnabled: w?.enabled ?? false, webauthnCredentials: w?.credentials?.count ?? 0)
    }

    public func fleet() async throws -> FleetData {
        let env: FleetEnvelope = try await get("multicluster", "clusters")
        let stats: FleetStats? = try? await get("multicluster", "stats")
        return FleetData(clusters: env.clusters ?? [], stats: stats)
    }

    public func clusterNodes() async throws -> [ClusterNode] { try await list("nodes") }
    public func hostInfo() async throws -> HostInfo { try await get("host", "system-info") }
    public func hypervisorConnections() async throws -> [HypervisorConnection] { try await list("hypervisor", "connections") }
    public func plugins() async throws -> [PluginInfo] { try await list("plugins") }
    public func logDestinations() async throws -> [LogDestination] { try await list("log-shipping", "destinations") }
    public func logShipRules() async throws -> [LogShipRule] { try await list("log-shipping", "status") }
    public func maintenanceWindows() async throws -> MaintenanceData {
        let e: MaintenanceEnvelope = try await get("maintenance", "windows")
        return MaintenanceData(windows: e.windows ?? [], note: e.execution?.note)
    }
}
