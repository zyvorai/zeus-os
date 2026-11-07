import Foundation

// Write actions for automation, delivery, storage and backups. Request shapes come from the server's
// OpenAPI document. Nothing here has been sent to a live server; the tests inspect the built requests.

/// A VolumeSnapshot (`GET /volumesnapshots`).
public struct VolumeSnapshot: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String
    public let sourcePVC: String?, snapshotClass: String?, restoreSize: String?, createdAt: String?, error: String?
    public let readyToUse: Bool?
    public var id: String { "\(namespace)/\(name)" }
    enum CodingKeys: String, CodingKey {
        case name, namespace, error
        case sourcePVC = "source_pvc", snapshotClass = "snapshot_class", restoreSize = "restore_size"
        case createdAt = "created_at", readyToUse = "ready_to_use"
    }
}

struct TriggerWorkflowBody: Encodable { let input: [String: String] }

struct ResolveApprovalBody: Encodable { let status: String; let comment: String? }

struct CreatePVCBody: Encodable {
    let name: String, namespace: String
    let storageGi: Double
    let accessModes: [String]
    let storageClass: String?
    enum CodingKeys: String, CodingKey {
        case name, namespace
        case storageGi = "storage_gi", accessModes = "access_modes", storageClass = "storage_class"
    }
}

struct ResizePVCBody: Encodable {
    let newSize: String
    enum CodingKeys: String, CodingKey { case newSize = "new_size" }
}

public struct VeleroScheduleBody: Encodable, Sendable {
    public var name: String
    public var schedule: String
    public var includedNamespaces: [String]
    public var excludedNamespaces: [String] = []
    public var ttlHours: Int?
    public var snapshotVolumes: Bool?

    public init(name: String, schedule: String, includedNamespaces: [String], excludedNamespaces: [String] = [],
                ttlHours: Int? = nil, snapshotVolumes: Bool? = nil) {
        self.name = name; self.schedule = schedule; self.includedNamespaces = includedNamespaces
        self.excludedNamespaces = excludedNamespaces; self.ttlHours = ttlHours; self.snapshotVolumes = snapshotVolumes
    }

    enum CodingKeys: String, CodingKey {
        case name, schedule
        case includedNamespaces = "included_namespaces", excludedNamespaces = "excluded_namespaces"
        case ttlHours = "ttl_hours", snapshotVolumes = "snapshot_volumes"
    }
}

public enum ApprovalDecision: String, Sendable { case approved, rejected }

extension ZeusClient {
    public func volumeSnapshots() async throws -> [VolumeSnapshot] { try await list("volumesnapshots") }

    /// Starts a run of a workflow with no input. Workflows are addressed by `workflow_id`; execution ids
    /// (which contain a slash) are never used as path segments here.
    public func triggerWorkflow(_ w: Workflow) async throws {
        try await post("workflows", w.id, "trigger", body: TriggerWorkflowBody(input: [:]))
    }

    public func cancelTask(_ t: OpsTask) async throws { try await post("tasks", t.id, "cancel") }

    public func deleteScheduledOperation(_ o: ScheduledOperation) async throws {
        try await delete("labs", "scheduled-ops", o.id)
    }

    /// `PATCH /labs/change-approvals/{id}`. The status words are the ones the app already colours
    /// ("approved" / "rejected"); the spec types the field as a plain string.
    public func resolveChangeApproval(_ a: ChangeApproval, _ decision: ApprovalDecision, comment: String?) async throws {
        let c = comment?.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = ResolveApprovalBody(status: decision.rawValue, comment: (c?.isEmpty == false) ? c : nil)
        _ = try await raw(try request(Self.path(["labs", "change-approvals", a.id]), method: "PATCH", body: body))
    }

    public func createClaim(name: String, namespace: String, sizeGi: Double, accessMode: String = "ReadWriteOnce",
                            storageClass: String?) async throws {
        let sc = storageClass?.isEmpty == false ? storageClass : nil
        try await post("storage", "claims", body: CreatePVCBody(name: name, namespace: namespace, storageGi: sizeGi,
                                                                accessModes: [accessMode], storageClass: sc))
    }

    /// Grow-only: the server accepts a Kubernetes quantity string, so we send whole Gi.
    public func resizeClaim(_ c: StorageClaim, toGi: Int) async throws {
        try await post("namespaces", c.namespace, "pvcs", c.name, "resize", body: ResizePVCBody(newSize: "\(toGi)Gi"))
    }

    /// True when `newGi` is a whole number strictly larger than the claim's current request.
    public static func isGrowth(of c: StorageClaim, toGi newGi: Int) -> Bool {
        guard newGi > 0 else { return false }
        return Double(newGi) > (c.requestedGi ?? 0)
    }

    public func deleteVolumeSnapshot(_ s: VolumeSnapshot) async throws {
        try await delete("volumesnapshots", s.namespace, s.name)
    }

    public func createVeleroSchedule(_ body: VeleroScheduleBody) async throws { try await post("velero", "schedules", body: body) }
}
