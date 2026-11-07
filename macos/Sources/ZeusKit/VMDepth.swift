import Foundation

/// A disk attached to a machine (`GET /vms/{ns}/{name}/disks`, a bare array).
public struct VMDisk: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String?
    public let size: String?
    public let storageClass: String?
    public let accessMode: String?
    public let diskType: String?
    public let status: String?
    public let bus: String?
    public let isCDROM: Bool?
    public let usedBy: [String]?

    public var id: String { name }

    enum CodingKeys: String, CodingKey {
        case name, namespace, size, status, bus
        case storageClass = "storage_class", accessMode = "access_mode", diskType = "disk_type"
        case isCDROM = "is_cdrom", usedBy = "used_by"
    }
}

public struct GuestInterface: Decodable, Sendable, Hashable, Identifiable {
    public let name: String?
    public let mac: String?
    public let ipAddresses: [String]
    public var id: String { "\(name ?? "")|\(mac ?? "")" }

    enum CodingKeys: String, CodingKey { case name, mac, ipAddresses = "ip_addresses" }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        mac = try c.decodeIfPresent(String.self, forKey: .mac)
        ipAddresses = try c.decodeIfPresent([String].self, forKey: .ipAddresses) ?? []
    }
}

/// `GET /vms/{ns}/{name}/guest-info`. Works without the guest agent (interfaces come from KubeVirt);
/// the OS fields are null until the agent connects.
public struct GuestInfo: Decodable, Sendable {
    public let hostname: String?
    public let osName: String?
    public let osVersion: String?
    public let kernelVersion: String?
    public let architecture: String?
    public let timezone: String?
    public let interfaces: [GuestInterface]
    public let agentConnected: Bool

    enum CodingKeys: String, CodingKey {
        case hostname, architecture, timezone, interfaces
        case osName = "os_name", osVersion = "os_version", kernelVersion = "kernel_version"
        case agentConnected = "agent_connected"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        hostname = try c.decodeIfPresent(String.self, forKey: .hostname)
        osName = try c.decodeIfPresent(String.self, forKey: .osName)
        osVersion = try c.decodeIfPresent(String.self, forKey: .osVersion)
        kernelVersion = try c.decodeIfPresent(String.self, forKey: .kernelVersion)
        architecture = try c.decodeIfPresent(String.self, forKey: .architecture)
        timezone = try c.decodeIfPresent(String.self, forKey: .timezone)
        interfaces = try c.decodeIfPresent([GuestInterface].self, forKey: .interfaces) ?? []
        agentConnected = try c.decodeIfPresent(Bool.self, forKey: .agentConnected) ?? false
    }
}

public struct VMChange: Decodable, Sendable, Hashable, Identifiable {
    public let timestamp: String?
    public let changeType: String?
    public let description: String?
    public let source: String?
    public var id: String { "\(timestamp ?? "")|\(changeType ?? "")|\(description ?? "")" }

    enum CodingKeys: String, CodingKey {
        case timestamp, description, source
        case changeType = "change_type"
    }
}

/// `GET /vms/{ns}/{name}/changes`.
public struct VMChanges: Decodable, Sendable {
    public let currentGeneration: Int?
    public let lastModified: String?
    public let changes: [VMChange]

    enum CodingKeys: String, CodingKey {
        case changes
        case currentGeneration = "current_generation", lastModified = "last_modified"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        currentGeneration = try c.decodeIfPresent(Int.self, forKey: .currentGeneration)
        lastModified = try c.decodeIfPresent(String.self, forKey: .lastModified)
        changes = try c.decodeIfPresent([VMChange].self, forKey: .changes) ?? []
    }
}

/// `GET/PUT /vms/{ns}/{name}/cloud-init`.
public struct CloudInitConfig: Decodable, Sendable {
    public let userData: String?
    public let networkData: String?
    public let metaData: String?
    public let sourceType: String?

    enum CodingKeys: String, CodingKey {
        case userData = "user_data", networkData = "network_data", metaData = "meta_data", sourceType = "source_type"
    }
}

/// Only user-data is sent, so saving never clears network or meta data.
struct CloudInitUpdate: Encodable {
    let userData: String?
    enum CodingKeys: String, CodingKey { case userData = "user_data" }
}

struct CloneRequest: Encodable {
    let newName: String
    let newNamespace: String?
    let cloneDisks: Bool
    let startAfterClone: Bool
    enum CodingKeys: String, CodingKey {
        case newName = "new_name", newNamespace = "new_namespace"
        case cloneDisks = "clone_disks", startAfterClone = "start_after_clone"
    }
}

struct CloneFromSnapshotRequest: Encodable {
    let snapshotName: String
    let newName: String
    let newNamespace: String?
    let startAfterClone: Bool
    enum CodingKeys: String, CodingKey {
        case snapshotName = "snapshot_name", newName = "new_name"
        case newNamespace = "new_namespace", startAfterClone = "start_after_clone"
    }
}

/// Which read-only guest-agent view to fetch. Responses are untyped on the server and the agent
/// is not connected on the machines we could inspect, so they are carried as `JSONValue`.
public enum GuestAgentView: String, CaseIterable, Sendable {
    case osInfo = "os-info", networkInterfaces = "network-interfaces"
    case processes, users, filesystems
}

extension ZeusClient {
    public func disks(of vm: VM) async throws -> [VMDisk] { try await list("vms", vm.namespace, vm.name, "disks") }
    public func guestInfo(of vm: VM) async throws -> GuestInfo { try await get("vms", vm.namespace, vm.name, "guest-info") }
    public func changes(of vm: VM) async throws -> VMChanges { try await get("vms", vm.namespace, vm.name, "changes") }
    public func cloudInit(of vm: VM) async throws -> CloudInitConfig { try await get("vms", vm.namespace, vm.name, "cloud-init") }
    public func guestAgent(_ view: GuestAgentView, of vm: VM) async throws -> JSONValue {
        try await get("vms", vm.namespace, vm.name, "guest-agent", view.rawValue)
    }

    public func saveCloudInit(userData: String, for vm: VM) async throws {
        try await put("vms", vm.namespace, vm.name, "cloud-init", body: CloudInitUpdate(userData: userData))
    }

    public func pause(_ vm: VM) async throws { try await post("vms", vm.namespace, vm.name, "pause") }
    public func unpause(_ vm: VM) async throws { try await post("vms", vm.namespace, vm.name, "unpause") }
    public func deleteVM(_ vm: VM) async throws { try await delete("vms", vm.namespace, vm.name) }

    public func clone(_ vm: VM, as newName: String, cloneDisks: Bool = true, start: Bool = false) async throws {
        try await post("vms", vm.namespace, vm.name, "clone",
                       body: CloneRequest(newName: newName, newNamespace: nil, cloneDisks: cloneDisks, startAfterClone: start))
    }

    public func cloneFromSnapshot(_ vm: VM, snapshot: String, as newName: String, start: Bool = false) async throws {
        try await post("vms", vm.namespace, vm.name, "clone-from-snapshot",
                       body: CloneFromSnapshotRequest(snapshotName: snapshot, newName: newName, newNamespace: nil, startAfterClone: start))
    }
}
