import Foundation

public struct LoginResponse: Codable, Sendable {
    public let token: String
    public let username: String
    public let role: String
    public let tenantIds: [String]
    public let expiresIn: Int

    public init(token: String, username: String, role: String, tenantIds: [String], expiresIn: Int) {
        self.token = token; self.username = username; self.role = role
        self.tenantIds = tenantIds; self.expiresIn = expiresIn
    }

    enum CodingKeys: String, CodingKey {
        case token, username, role
        case tenantIds = "tenant_ids"
        case expiresIn = "expires_in"
    }
}

public struct Page<T: Codable & Sendable>: Codable, Sendable {
    public let items: [T]
}

public struct VM: Codable, Sendable, Identifiable, Hashable {
    public var id: String { "\(namespace)/\(name)" }
    public let name: String
    public let namespace: String
    public let status: String
    public let node: String?
    public let age: String?
    public let tags: [String]?
    public let ipAddress: String?
    public let diskCount: Int?
    public let networkCount: Int?
    public let memoryGi: Double?
    public let securityScore: Int?
    public let backupHealth: String?
    public let lastActivity: String?

    enum CodingKeys: String, CodingKey {
        case name, namespace, status, node, age, tags
        case ipAddress = "ip_address"
        case diskCount = "disk_count"
        case networkCount = "network_count"
        case memoryGi = "memory_gi"
        case securityScore = "security_score"
        case backupHealth = "backup_health"
        case lastActivity = "last_activity"
    }
}

public struct AlertStats: Codable, Sendable {
    public let totalActive: Int
    public let critical: Int
    public let warning: Int
    public let info: Int
    public let acknowledged: Int

    enum CodingKeys: String, CodingKey {
        case totalActive = "total_active"
        case critical, warning, info, acknowledged
    }
}

public enum VMAction: String, Sendable, CaseIterable {
    case start, stop, restart

    public var title: String { rawValue.capitalized }

    /// Which states the action makes sense in. Unknown states disable everything.
    public func isAvailable(for status: String) -> Bool {
        switch self {
        case .start: status == "Stopped"
        case .stop, .restart: status == "Running"
        }
    }
}
