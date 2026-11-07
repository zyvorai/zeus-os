import Foundation

/// An active alert from `GET /alerts`.
public struct FiredAlert: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let ruleName: String
    public let resourceName: String
    public let namespace: String
    public let severity: String
    public let currentValue: Double
    public let thresholdValue: Double
    public let firedAt: Date
    public let lastSeen: Date
    public let acknowledged: Bool
    public let count: Int

    /// Most urgent first; unknown severities sort last rather than being hidden.
    public var severityRank: Int {
        switch severity.lowercased() { case "critical": 0; case "warning": 1; case "info": 2; default: 3 }
    }

    enum CodingKeys: String, CodingKey {
        case id, namespace, severity, acknowledged, count
        case ruleName = "rule_name"
        case resourceName = "resource_name"
        case currentValue = "current_value"
        case thresholdValue = "threshold_value"
        case firedAt = "fired_at"
        case lastSeen = "last_seen"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        ruleName = try c.decode(String.self, forKey: .ruleName)
        resourceName = try c.decode(String.self, forKey: .resourceName)
        namespace = try c.decode(String.self, forKey: .namespace)
        severity = try c.decode(String.self, forKey: .severity)
        currentValue = try c.decode(Double.self, forKey: .currentValue)
        thresholdValue = try c.decode(Double.self, forKey: .thresholdValue)
        acknowledged = try c.decode(Bool.self, forKey: .acknowledged)
        count = try c.decode(Int.self, forKey: .count)
        firedAt = try Self.date(c, .firedAt)
        lastSeen = try Self.date(c, .lastSeen)
    }

    private static func date(_ c: KeyedDecodingContainer<CodingKeys>, _ key: CodingKeys) throws -> Date {
        let raw = try c.decode(String.self, forKey: key)
        guard let d = ZeusDate.parse(raw) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: c, debugDescription: "Unrecognised timestamp \(raw)")
        }
        return d
    }
}
