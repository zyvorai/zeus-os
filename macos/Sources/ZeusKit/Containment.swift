import Foundation

// Workload containments (`/containments`). The server can create, read, patch, release and roll back a containment
// by id but has no list endpoint, so the app tracks ids it created or was given. Shapes come from the OpenAPI
// document; nothing here has been sent to a live server.

public enum ContainmentProfile: String, CaseIterable, Sendable, Identifiable {
    case internetLock = "internet-lock", fullIsolation = "full-isolation", lateralLock = "lateral-lock"
    case investigationMode = "investigation-mode", exfiltrationLock = "exfiltration-lock", custom
    public var id: String { rawValue }
}

public enum ConnectionBehavior: String, CaseIterable, Sendable, Identifiable {
    case blockNew = "block-new", preserveExisting = "preserve-existing"
    case terminateExisting = "terminate-existing", bestEffortTerminate = "best-effort-terminate"
    public var id: String { rawValue }
}

public struct ContainmentEvent: Decodable, Sendable, Hashable {
    public let at: String?, kind: String?, detail: String?
}

public struct Containment: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let workloadID: String?, profile: String?, backend: String?
    public let desiredState: String?, actualState: String?, reason: String?, customMode: String?
    public let connectionBehavior: String?, createdAt: String?, updatedAt: String?, expiresAt: String?
    public let durationSeconds: Int?
    public let preserve: [String]?, events: [ContainmentEvent]?

    enum CodingKeys: String, CodingKey {
        case id, profile, backend, reason, preserve, events
        case workloadID = "workload_id", desiredState = "desired_state", actualState = "actual_state"
        case customMode = "custom_mode", connectionBehavior = "connection_behavior"
        case createdAt = "created_at", updatedAt = "updated_at", expiresAt = "expires_at"
        case durationSeconds = "duration_seconds"
    }

    /// Active, or on its way to being active.
    public var isLive: Bool {
        !["released", "expired", "failed"].contains((actualState ?? "").lowercased())
    }
}

public struct ContainmentRequest: Encodable, Sendable {
    struct Target: Encodable, Sendable { let id: String }
    let target: Target
    public let profile: String
    public var reason: String?
    public var durationSeconds: Int?
    public var customMode: String?
    public var connectionBehavior: String?
    public var preserve: [String]

    public init(targetID: String, profile: ContainmentProfile, reason: String? = nil, durationSeconds: Int? = nil,
                customMode: String? = nil, connectionBehavior: ConnectionBehavior? = nil, preserve: [String] = []) {
        target = Target(id: targetID); self.profile = profile.rawValue
        self.reason = reason; self.durationSeconds = durationSeconds; self.customMode = customMode
        self.connectionBehavior = connectionBehavior?.rawValue; self.preserve = preserve
    }

    enum CodingKeys: String, CodingKey {
        case target, profile, reason, preserve
        case durationSeconds = "duration_seconds", customMode = "custom_mode", connectionBehavior = "connection_behavior"
    }

    /// A message to show the user, or nil when the request is acceptable to send.
    public func problem() -> String? {
        if target.id.trimmingCharacters(in: .whitespaces).isEmpty { return "Enter the workload to contain, such as vm:default/web-01." }
        if profile == ContainmentProfile.custom.rawValue, (customMode ?? "").trimmingCharacters(in: .whitespaces).isEmpty {
            return "A custom containment needs a mode."
        }
        if let d = durationSeconds, d <= 0 { return "The duration must be more than zero seconds." }
        return nil
    }
}

struct PatchContainmentBody: Encodable {
    let durationSeconds: Int?, reason: String?
    enum CodingKeys: String, CodingKey { case durationSeconds = "duration_seconds", reason }
}

extension ZeusClient {
    public func createContainment(_ r: ContainmentRequest) async throws -> Containment { try await post("containments", body: r) }
    public func containment(id: String) async throws -> Containment { try await get("containments", id) }
    public func releaseContainment(id: String) async throws -> Containment { try await post("containments", id, "release") }
    public func rollBackContainment(id: String) async throws -> Containment { try await post("containments", id, "rollback") }
    /// Extends or shortens the auto-release window, counted from now.
    public func updateContainment(id: String, durationSeconds: Int?, reason: String? = nil) async throws -> Containment {
        try await send(Self.path(["containments", id]), method: "PATCH",
                       body: PatchContainmentBody(durationSeconds: durationSeconds, reason: reason))
    }
}
