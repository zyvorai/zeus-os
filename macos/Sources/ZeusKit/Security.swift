import Foundation

/// One row of `GET /audit`. On a stock install these are Kubernetes events recorded by components such as kubelet.
public struct AuditEvent: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let timestamp: String
    public let user: String?
    public let action: String
    public let resourceType: String?
    public let resourceName: String?
    public let namespace: String?
    public let details: String?
    public let result: String?
    public let count: Int?

    public var date: Date? { ZeusDate.parse(timestamp) }
    public var isWarning: Bool { result == "Warning" || result == "Failure" || result == "Error" }

    enum CodingKeys: String, CodingKey {
        case id, timestamp, user, action, namespace, details, result, count
        case resourceType = "resource_type", resourceName = "resource_name"
    }
}

public struct AuditStats: Decodable, Sendable {
    public let totalEvents: Int
    public let last24h: Int
    public let last7d: Int

    enum CodingKeys: String, CodingKey { case totalEvents = "total_events", last24h = "last_24h", last7d = "last_7d" }
}

/// One compliance framework from `GET /compliance/frameworks`.
public struct ComplianceFramework: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let frameworkType: String?
    public let version: String?
    public let totalControls: Int
    public let passedControls: Int
    public let failedControls: Int
    public let complianceScore: Double
    public let lastScan: String?

    public var id: String { name }
    public var lastScanDate: Date? { lastScan.flatMap(ZeusDate.parse) }

    enum CodingKeys: String, CodingKey {
        case name, version
        case frameworkType = "framework_type", totalControls = "total_controls", passedControls = "passed_controls"
        case failedControls = "failed_controls", complianceScore = "compliance_score", lastScan = "last_scan"
    }
}

extension ZeusClient {
    public func auditEvents() async throws -> [AuditEvent] { try await list("audit") }
    public func auditStats() async throws -> AuditStats { try await get("audit", "stats") }
    public func complianceFrameworks() async throws -> [ComplianceFramework] { try await list("compliance", "frameworks") }
}
