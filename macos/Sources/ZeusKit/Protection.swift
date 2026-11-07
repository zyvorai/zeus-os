import Foundation

/// A VM snapshot (`GET /snapshots`).
public struct VMSnapshot: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String
    public let vmName: String?
    public let age: String?
    public let ready: Bool?
    public let consistencyType: String?
    public let phase: String?
    public let error: String?

    public var id: String { "\(namespace)/\(name)" }

    enum CodingKeys: String, CodingKey {
        case name, namespace, age, ready, phase, error
        case vmName = "vm_name", consistencyType = "consistency_type"
    }
}

/// Velero schedule from `GET /backups/schedules`.
public struct BackupSchedule: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let schedule: String?
    public let includedNamespaces: [String]?
    public let ttl: String?
    public let lastBackup: String?
    public let phase: String?

    public var id: String { name }

    enum CodingKeys: String, CodingKey {
        case name, schedule, ttl, phase
        case includedNamespaces = "included_namespaces", lastBackup = "last_backup"
    }
}

/// A recent Velero backup run inside the schedules response.
public struct BackupRun: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let phase: String?
    public let startedAt: String?
    public let completedAt: String?
    public let totalItems: Int?
    public let sizeBytes: Int64?

    public var id: String { name }

    enum CodingKeys: String, CodingKey {
        case name, phase
        case startedAt = "started_at", completedAt = "completed_at"
        case totalItems = "total_items", sizeBytes = "size_bytes"
    }
}

public struct BackupOverview: Decodable, Sendable {
    public let schedules: [BackupSchedule]
    public let recentBackups: [BackupRun]
    public let veleroInstalled: Bool

    enum CodingKeys: String, CodingKey {
        case schedules, recentBackups = "recent_backups", veleroInstalled = "velero_installed"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        schedules = try c.decodeIfPresent([BackupSchedule].self, forKey: .schedules) ?? []
        recentBackups = try c.decodeIfPresent([BackupRun].self, forKey: .recentBackups) ?? []
        veleroInstalled = try c.decodeIfPresent(Bool.self, forKey: .veleroInstalled) ?? false
    }
}

/// A VM backup (`GET /backups`).
public struct VMBackup: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let backupName: String
    public let vmName: String
    public let namespace: String
    public let status: String?
    public let createdAt: String?
    public let sizeBytes: Int64?

    enum CodingKeys: String, CodingKey {
        case id, namespace, status
        case backupName = "backup_name", vmName = "vm_name", createdAt = "created_at", sizeBytes = "size_bytes"
    }
}

public struct BackupStats: Decodable, Sendable {
    public let totalBackups: Int
    public let totalSizeBytes: Int64

    enum CodingKeys: String, CodingKey { case totalBackups = "total_backups", totalSizeBytes = "total_size_bytes" }
}

struct CreateSnapshotBody: Encodable {
    let vmName: String
    let quiesce: Bool
    enum CodingKeys: String, CodingKey { case vmName = "vm_name", quiesce }
}

extension ZeusClient {
    public func snapshots() async throws -> [VMSnapshot] { try await list("snapshots") }

    /// Takes a snapshot of one VM. `quiesce` freezes guest filesystems first (needs the guest agent).
    public func createSnapshot(of vm: VM, quiesce: Bool) async throws {
        try await post("snapshots", vm.namespace, body: CreateSnapshotBody(vmName: vm.name, quiesce: quiesce))
    }

    public func deleteSnapshot(_ s: VMSnapshot) async throws { try await delete("snapshots", s.namespace, s.name) }

    public func backupOverview() async throws -> BackupOverview { try await get("backups", "schedules") }
    public func backups() async throws -> [VMBackup] { try await list("backups") }
    public func backupStats() async throws -> BackupStats { try await get("backups", "stats") }
}
