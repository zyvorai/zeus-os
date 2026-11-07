import Foundation

/// `GET /storage/classes` (the richer variant; `/storage-classes` is the short one).
public struct StorageClass: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let provisioner: String?
    public let reclaimPolicy: String?
    public let volumeBindingMode: String?
    public let allowVolumeExpansion: Bool?
    public let isDefault: Bool?

    public var id: String { name }

    enum CodingKeys: String, CodingKey {
        case name, provisioner
        case reclaimPolicy = "reclaim_policy", volumeBindingMode = "volume_binding_mode"
        case allowVolumeExpansion = "allow_volume_expansion", isDefault = "is_default"
    }
}

/// A PersistentVolumeClaim (`GET /storage/claims`).
public struct StorageClaim: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String
    public let status: String?
    public let volumeName: String?
    public let storageClass: String?
    public let requestedGi: Double?
    public let accessModes: [String]?
    public let createdAt: String?

    public var id: String { "\(namespace)/\(name)" }

    enum CodingKeys: String, CodingKey {
        case name, namespace, status
        case volumeName = "volume_name", storageClass = "storage_class"
        case requestedGi = "requested_storage_gi", accessModes = "access_modes", createdAt = "created_at"
    }
}

/// Cluster storage capacity (`GET /storage/overview`).
public struct StorageOverview: Decodable, Sendable, Hashable {
    public let totalGi: Double?
    public let usedGi: Double?
    public let availableGi: Double?
    public let utilizationPercent: Double?
    public let totalVolumes: Int?
    public let boundVolumes: Int?
    public let totalPVCs: Int?
    public let pendingPVCs: Int?
    public let storageClasses: Int?

    enum CodingKeys: String, CodingKey {
        case totalGi = "total_capacity_gi", usedGi = "used_capacity_gi", availableGi = "available_capacity_gi"
        case utilizationPercent = "utilization_percent", totalVolumes = "total_volumes", boundVolumes = "bound_volumes"
        case totalPVCs = "total_pvcs", pendingPVCs = "pending_pvcs", storageClasses = "storage_classes"
    }
}

/// A PersistentVolume (`GET /storage/volumes`).
public struct StorageVolume: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let capacityGi: Double?
    public let storageClass: String?
    public let status: String?
    public let claim: String?
    public let reclaimPolicy: String?

    public var id: String { name }

    enum CodingKeys: String, CodingKey {
        case name, status, claim
        case capacityGi = "capacity_gi", storageClass = "storage_class", reclaimPolicy = "reclaim_policy"
    }
}

/// A disaster-recovery plan row (`GET /dr/plans`). Shape taken from the OpenAPI spec: the live server had no plans.
public struct DRPlan: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let description: String?
    public let planType: String?
    public let enabled: Bool?
    public let primarySite: String?
    public let secondarySite: String?
    public let targetRPOMinutes: Int?
    public let targetRTOMinutes: Int?
    public let currentRPOMinutes: Int?
    public let healthStatus: String?
    public let lastTested: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, enabled
        case planType = "plan_type", primarySite = "primary_site", secondarySite = "secondary_site"
        case targetRPOMinutes = "target_rpo_minutes", targetRTOMinutes = "target_rto_minutes"
        case currentRPOMinutes = "current_rpo_minutes", healthStatus = "health_status", lastTested = "last_tested"
    }
}

/// `GET /velero/backups` (spec shape; live server had Velero uninstalled).
public struct VeleroBackup: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String?
    public let phase: String?
    public let createdAt: String?
    public let completedAt: String?
    public let expiration: String?
    public let includedNamespaces: [String]?
    public let totalItems: Int?
    public let sizeBytes: Int64?

    public var id: String { "\(namespace ?? "")/\(name)" }

    enum CodingKeys: String, CodingKey {
        case name, namespace, phase, expiration
        case createdAt = "created_at", completedAt = "completed_at"
        case includedNamespaces = "included_namespaces", totalItems = "total_items", sizeBytes = "size_bytes"
    }
}

/// `GET /velero/restores` (spec shape).
public struct VeleroRestore: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String?
    public let backupName: String?
    public let phase: String?
    public let createdAt: String?
    public let completedAt: String?
    public let errors: Int?
    public let warnings: Int?

    public var id: String { "\(namespace ?? "")/\(name)" }

    enum CodingKeys: String, CodingKey {
        case name, namespace, phase, errors, warnings
        case backupName = "backup_name", createdAt = "created_at", completedAt = "completed_at"
    }
}

/// `GET /datavolumes` (spec shape; live server had none).
public struct DataVolume: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String
    public let sourceType: String?
    public let size: String?
    public let phase: String?
    public let progress: String?
    public let age: String?

    public var id: String { "\(namespace)/\(name)" }

    enum CodingKeys: String, CodingKey {
        case name, namespace, size, phase, progress, age
        case sourceType = "source_type"
    }
}

/// A cached container image (`GET /images`, camelCase keys).
public struct ContainerImage: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let repository: String?
    public let tag: String?
    public let sizeBytes: Int64?
    public let scanStatus: String?
    public let critical: Int?
    public let high: Int?
    public let pullCount: Int?

    enum CodingKeys: String, CodingKey { case id, repository, tag, sizeBytes, scanStatus, vulnerabilities, pullCount }
    enum VulnKeys: String, CodingKey { case critical, high }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        repository = try c.decodeIfPresent(String.self, forKey: .repository)
        tag = try c.decodeIfPresent(String.self, forKey: .tag)
        sizeBytes = try c.decodeIfPresent(Int64.self, forKey: .sizeBytes)
        scanStatus = try c.decodeIfPresent(String.self, forKey: .scanStatus)
        pullCount = try c.decodeIfPresent(Int.self, forKey: .pullCount)
        let v = try? c.nestedContainer(keyedBy: VulnKeys.self, forKey: .vulnerabilities)
        critical = try v?.decodeIfPresent(Int.self, forKey: .critical)
        high = try v?.decodeIfPresent(Int.self, forKey: .high)
    }
}

/// Body for `POST /backups/{namespace}/{name}/restore` (spec `RestoreRequest_backups`). Untested against a live server.
public struct RestoreBackupBody: Encodable, Sendable {
    public let backupID: String
    public let newVMName: String?
    public let targetNamespace: String?
    public let restoreDisks: [String]?

    public init(backupID: String, newVMName: String? = nil, targetNamespace: String? = nil, restoreDisks: [String]? = nil) {
        self.backupID = backupID; self.newVMName = newVMName
        self.targetNamespace = targetNamespace; self.restoreDisks = restoreDisks
    }

    enum CodingKeys: String, CodingKey {
        case backupID = "backup_id", newVMName = "new_vm_name"
        case targetNamespace = "target_namespace", restoreDisks = "restore_disks"
    }
}

extension ZeusClient {
    public func storageClasses() async throws -> [StorageClass] { try await list("storage", "classes") }
    public func storageClaims() async throws -> [StorageClaim] { try await list("storage", "claims") }
    public func storageVolumes() async throws -> [StorageVolume] { try await list("storage", "volumes") }
    public func storageOverview() async throws -> StorageOverview { try await get("storage", "overview") }
    public func drPlans() async throws -> [DRPlan] { try await list("dr", "plans") }
    public func veleroBackups() async throws -> [VeleroBackup] { try await list("velero", "backups") }
    public func veleroRestores() async throws -> [VeleroRestore] { try await list("velero", "restores") }
    public func dataVolumes() async throws -> [DataVolume] { try await list("datavolumes") }
    public func images() async throws -> [ContainerImage] { try await list("images") }

    /// Restores a VM backup in place per server defaults, or into `newVMName` when given.
    public func restore(_ b: VMBackup, newVMName: String? = nil) async throws {
        try await post("backups", b.namespace, b.backupName, "restore",
                       body: RestoreBackupBody(backupID: b.id, newVMName: newVMName))
    }
}
