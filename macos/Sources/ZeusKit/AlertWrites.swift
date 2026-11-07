import Foundation

// Write models for alerting, notification channels and SLOs. Request shapes come from the server's OpenAPI
// document (CreateAlertRuleRequest_alerting, CreateChannelRequest, UpdateChannelRequest, CreateSLORequest) and are
// verified by unit tests only; none of these calls has been exercised against a live server.

/// Condition inside an alert-rule body. `filters` is required by the schema, so it is always sent.
public struct AlertConditionInput: Encodable, Sendable, Equatable {
    public var metric: String
    public var `operator`: String
    public var threshold: Double
    public var durationMinutes: Int
    public var filters: [String: String]

    public init(metric: String, operator op: String, threshold: Double, durationMinutes: Int, filters: [String: String] = [:]) {
        self.metric = metric; self.operator = op; self.threshold = threshold
        self.durationMinutes = durationMinutes; self.filters = filters
    }

    enum CodingKeys: String, CodingKey { case metric, `operator`, threshold, filters, durationMinutes = "duration_minutes" }
}

/// Body of `POST /alerting/rules` and `PUT /alerting/rules/{id}` (a full replacement, so editing must carry
/// over everything the server returned: filters and the escalation policy included).
public struct AlertRuleInput: Encodable, Sendable, Equatable {
    public var name: String
    public var description: String
    public var severity: String
    public var condition: AlertConditionInput
    public var notificationChannels: [String]
    public var escalationPolicyId: String?

    public init(name: String, description: String, severity: String, condition: AlertConditionInput,
                notificationChannels: [String], escalationPolicyId: String? = nil) {
        self.name = name; self.description = description; self.severity = severity; self.condition = condition
        self.notificationChannels = notificationChannels; self.escalationPolicyId = escalationPolicyId
    }

    /// Pre-fills an edit from what the server returned.
    public init(editing r: AlertingRule) {
        self.init(name: r.name ?? "", description: r.description ?? "", severity: r.severity ?? "warning",
                  condition: AlertConditionInput(metric: r.condition?.metric ?? "", operator: r.condition?.operator ?? ">",
                                                 threshold: r.condition?.threshold ?? 0,
                                                 durationMinutes: r.condition?.durationMinutes ?? 5,
                                                 filters: r.condition?.filters ?? [:]),
                  notificationChannels: r.notificationChannels ?? [], escalationPolicyId: r.escalationPolicyId)
    }

    enum CodingKeys: String, CodingKey {
        case name, description, severity, condition
        case notificationChannels = "notification_channels", escalationPolicyId = "escalation_policy_id"
    }
}

/// SMTP channel config, the one channel type whose `config` is documented (docs/EMAIL_NOTIFICATIONS.md).
/// The password is write-only: it is encoded into the single create request and never printed or stored.
public struct EmailChannelConfig: Sendable, Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    public var host: String
    public var port: Int?
    public var security: String          // starttls | tls | none
    public var username: String
    public var password: String
    public var from: String
    public var to: [String]

    public init(host: String, port: Int? = nil, security: String = "starttls", username: String = "",
                password: String = "", from: String, to: [String]) {
        self.host = host; self.port = port; self.security = security; self.username = username
        self.password = password; self.from = from; self.to = to
    }

    public var json: JSONValue {
        var o: [String: JSONValue] = ["host": .string(host), "security": .string(security),
                                      "from": .string(from), "to": .array(to.map(JSONValue.string))]
        if let port { o["port"] = .number(Double(port)) }
        if !username.isEmpty { o["username"] = .string(username) }
        if !password.isEmpty { o["password"] = .string(password) }
        return .object(o)
    }

    public var description: String { "EmailChannelConfig(host: \(host), from: \(from), password: <redacted>)" }
    public var debugDescription: String { description }
}

/// Body of `POST /notifications/channels`. `config` may hold secrets; printing redacts it.
public struct NotificationChannelInput: Encodable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public var name: String
    public var channelType: String
    public var config: JSONValue

    public init(name: String, channelType: String, config: JSONValue) {
        self.name = name; self.channelType = channelType; self.config = config
    }

    public static func email(name: String, _ c: EmailChannelConfig) -> Self {
        .init(name: name, channelType: "email", config: c.json)
    }

    enum CodingKeys: String, CodingKey { case name, config, channelType = "channel_type" }

    public var description: String { "NotificationChannelInput(name: \(name), type: \(channelType), config: <redacted>)" }
    public var debugDescription: String { description }
}

/// Body of `PUT /notifications/channels/{id}`: partial; only `enabled` is ever sent from the app, so the stored
/// (masked) config is left alone.
struct ChannelEnabledUpdate: Encodable { let enabled: Bool }

/// Body of `POST /slo/slos`.
public struct SLOInput: Encodable, Sendable, Equatable {
    public var name: String
    public var namespace: String
    public var service: String
    public var sloType: String
    public var targetPercentage: Double
    public var timeWindowDays: Int

    public init(name: String, namespace: String, service: String, sloType: String, targetPercentage: Double, timeWindowDays: Int) {
        self.name = name; self.namespace = namespace; self.service = service; self.sloType = sloType
        self.targetPercentage = targetPercentage; self.timeWindowDays = timeWindowDays
    }

    enum CodingKeys: String, CodingKey {
        case name, namespace, service
        case sloType = "slo_type", targetPercentage = "target_percentage", timeWindowDays = "time_window_days"
    }
}

extension ZeusClient {
    /// Resolves an alert. Same `/alerts/{id}` family (and ids) as `acknowledge`; the endpoint takes no body.
    public func resolve(_ alert: FiredAlert) async throws {
        _ = try await raw(try request(Self.resolvePath(alert), method: "POST"))
    }
    static func resolvePath(_ alert: FiredAlert) -> String { "alerts/\(segment(alert.id))/resolve" }

    public func createAlertRule(_ r: AlertRuleInput) async throws { try await post("alerting", "rules", body: r) }
    public func updateAlertRule(id: String, _ r: AlertRuleInput) async throws { try await put("alerting", "rules", id, body: r) }
    public func deleteAlertRule(id: String) async throws { try await delete("alerting", "rules", id) }

    public func createNotificationChannel(_ c: NotificationChannelInput) async throws { try await post("notifications", "channels", body: c) }
    public func deleteNotificationChannel(id: String) async throws { try await delete("notifications", "channels", id) }
    public func setNotificationChannel(id: String, enabled: Bool) async throws {
        try await put("notifications", "channels", id, body: ChannelEnabledUpdate(enabled: enabled))
    }
    public func deleteAlertingChannel(id: String) async throws { try await delete("alerting", "channels", id) }

    public func createSLO(_ s: SLOInput) async throws { try await post("slo", "slos", body: s) }
}
