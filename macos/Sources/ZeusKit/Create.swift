import Foundation

/// A VM template (`GET /templates`). Built-in templates have an empty `namespace` and an id like `built-in/<name>`.
public struct VMTemplateInfo: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let namespace: String?
    public let displayName: String?
    public let description: String?
    public let category: String?
    public let osType: String?
    public let version: String?
    public let source: String?
    public let tags: [String]?
    public let cpuCores: Int?
    public let memoryGi: Double?
    public let diskSizeGi: Double?
    public let status: String?

    public var isBuiltIn: Bool { (namespace ?? "").isEmpty }
    public var title: String { displayName ?? name }

    enum CodingKeys: String, CodingKey {
        case id, name, namespace, description, category, version, source, tags, spec
        case displayName = "display_name", osType = "os_type", status = "template_status"
    }
    enum SpecKeys: String, CodingKey {
        case cpuCores = "cpu_cores", memoryGi = "memory_gi", diskSizeGi = "disk_size_gi"
    }

    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        namespace = try c.decodeIfPresent(String.self, forKey: .namespace)
        displayName = try c.decodeIfPresent(String.self, forKey: .displayName)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        category = try c.decodeIfPresent(String.self, forKey: .category)
        osType = try c.decodeIfPresent(String.self, forKey: .osType)
        version = try c.decodeIfPresent(String.self, forKey: .version)
        source = try c.decodeIfPresent(String.self, forKey: .source)
        tags = try c.decodeIfPresent([String].self, forKey: .tags)
        status = try c.decodeIfPresent(String.self, forKey: .status)
        let s = try? c.nestedContainer(keyedBy: SpecKeys.self, forKey: .spec)
        cpuCores = try s?.decodeIfPresent(Int.self, forKey: .cpuCores)
        memoryGi = try s?.decodeIfPresent(Double.self, forKey: .memoryGi)
        diskSizeGi = try s?.decodeIfPresent(Double.self, forKey: .diskSizeGi)
    }
}

/// `GET /instance-types`.
public struct InstanceTypeInfo: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let cpuCores: Int?
    public let memory: String?
    public let gpu: String?
    public let features: [String]?
    public var id: String { name }
    enum CodingKeys: String, CodingKey { case name, memory, gpu, features, cpuCores = "cpu_cores" }
}

/// `GET /migrations`.
public struct MigrationInfo: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String
    public let vmiName: String?
    public let phase: String?
    public let sourceNode: String?
    public let targetNode: String?
    public let created: String?
    public var id: String { "\(namespace)/\(name)" }
    enum CodingKeys: String, CodingKey {
        case name, namespace, phase, created
        case vmiName = "vmi_name", sourceNode = "source_node", targetNode = "target_node"
    }
}

public struct MigrationCheck: Decodable, Sendable, Identifiable, Hashable {
    public let check: String
    public let status: String?
    public let message: String?
    public var id: String { "\(check)|\(message ?? "")" }
}

/// `GET /migrations/preflight/{ns}/{vm}`.
public struct MigrationPreflight: Decodable, Sendable {
    public let ready: Bool
    public let checks: [MigrationCheck]
    public let blockers: [String]
    public let remediation: String?

    enum CodingKeys: String, CodingKey { case ready, checks, blockers, remediation }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        ready = try c.decodeIfPresent(Bool.self, forKey: .ready) ?? false
        checks = try c.decodeIfPresent([MigrationCheck].self, forKey: .checks) ?? []
        blockers = try c.decodeIfPresent([String].self, forKey: .blockers) ?? []
        remediation = try c.decodeIfPresent(String.self, forKey: .remediation)
    }
}

/// `GET /vm-groups`.
public struct VMGroup: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let description: String?
    public let namespace: String?
    public let selector: [String: String]?
}

public struct GroupActionResult: Decodable, Sendable {
    public let action: String?
    public let total: Int?
    public let succeeded: Int?
    public let failed: Int?
}

/// Body for `POST /migrations` (untested live: it would move a real machine).
struct MigrationBody: Encodable {
    let vmiName: String
    let namespace: String
    let targetNodeName: String?
    enum CodingKeys: String, CodingKey {
        case vmiName = "vmi_name", namespace, targetNodeName = "target_node_name"
    }
}

struct GroupActionBody: Encodable { let action: String }

extension ZeusClient {
    public func templates() async throws -> [VMTemplateInfo] { try await list("templates") }
    public func instanceTypes() async throws -> [InstanceTypeInfo] { try await list("instance-types") }
    public func migrations() async throws -> [MigrationInfo] { try await list("migrations") }
    public func migrationPreflight(_ vm: VM) async throws -> MigrationPreflight {
        try await get("migrations", "preflight", vm.namespace, vm.name)
    }
    public func vmGroups() async throws -> [VMGroup] { try await list("vm-groups") }

    /// Starts a live migration of a running machine; the scheduler picks the target unless one is given.
    public func liveMigrate(_ vm: VM, toNode node: String? = nil) async throws {
        try await post("migrations", body: MigrationBody(vmiName: vm.name, namespace: vm.namespace, targetNodeName: node))
    }

    /// Runs a power action over every member of a group.
    public func groupAction(_ group: VMGroup, action: String) async throws -> GroupActionResult {
        try await post("vm-groups", group.id, "action", body: GroupActionBody(action: action))
    }
}
