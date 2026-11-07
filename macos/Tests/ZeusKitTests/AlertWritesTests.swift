import Testing
import Foundation
@testable import ZeusKit

// Write requests: request shape only. Never sent to a live server.
private let c = ZeusClient(baseURL: URL(string: "https://zeus.test")!, token: "t")
private func body(_ r: URLRequest) throws -> [String: Any] {
    try #require(try JSONSerialization.jsonObject(with: r.httpBody ?? Data()) as? [String: Any])
}
private func dec<T: Decodable & Sendable>(_ t: T.Type, _ s: String) throws -> T {
    try JSONDecoder().decode(t, from: Data(s.utf8))
}

@Test func resolveUsesAlertIDSegmentAndNoBody() throws {
    let a = try dec(FiredAlert.self, #"{"id":"a b/1","rule_name":"r","resource_name":"v","namespace":"n","severity":"warning","current_value":1,"threshold_value":2,"fired_at":"2026-11-07T10:00:00Z","last_seen":"2026-11-07T10:00:00Z","acknowledged":false,"count":1}"#)
    let r = try c.request(ZeusClient.resolvePath(a), method: "POST")
    #expect(r.httpMethod == "POST" && r.url?.absoluteString == "https://zeus.test/api/v1/alerts/a%20b%2F1/resolve" && r.httpBody == nil)
}

@Test func createRuleBodyMatchesSchema() throws {
    let rule = AlertRuleInput(name: "cpu", description: "hot", severity: "critical",
                              condition: .init(metric: "cpu", operator: ">", threshold: 90, durationMinutes: 5),
                              notificationChannels: ["c1"])
    let r = try c.request("alerting/rules", method: "POST", body: rule)
    #expect(r.url?.path == "/api/v1/alerting/rules")
    let o = try body(r)
    #expect(Set(o.keys) == ["name", "description", "severity", "condition", "notification_channels"])
    let cond = try #require(o["condition"] as? [String: Any])
    #expect(Set(cond.keys) == ["metric", "operator", "threshold", "duration_minutes", "filters"])
}

@Test func editRuleCarriesFiltersAndEscalationOver() throws {
    let existing = try dec(AlertingRule.self, #"{"rule_id":"r 1","name":"cpu","description":"d","severity":"warning","enabled":true,"condition":{"metric":"cpu","operator":">","threshold":90,"duration_minutes":5,"filters":{"namespace":"prod"}},"notification_channels":["c1"],"escalation_policy_id":"p1"}"#)
    var input = AlertRuleInput(editing: existing)
    input.severity = "critical"
    let r = try c.request(ZeusClient.path(["alerting", "rules", existing.ruleId]), method: "PUT", body: input)
    #expect(r.httpMethod == "PUT" && r.url?.absoluteString == "https://zeus.test/api/v1/alerting/rules/r%201")
    let o = try body(r)
    #expect(o["escalation_policy_id"] as? String == "p1" && o["severity"] as? String == "critical")
    #expect(((o["condition"] as? [String: Any])?["filters"] as? [String: String]) == ["namespace": "prod"])
}

@Test func deleteRuleAndChannelPaths() throws {
    let a = try c.request(ZeusClient.path(["alerting", "rules", "x/y"]), method: "DELETE")
    let b = try c.request(ZeusClient.path(["notifications", "channels", "n1"]), method: "DELETE")
    #expect(a.url?.absoluteString == "https://zeus.test/api/v1/alerting/rules/x%2Fy" && b.httpMethod == "DELETE")
}

@Test func emailChannelBodyAndRedaction() throws {
    let cfg = EmailChannelConfig(host: "smtp.example.com", port: 587, username: "alerts", password: "hunter2-secret",
                                 from: "zeus@example.com", to: ["ops@example.com"])
    let input = NotificationChannelInput.email(name: "ops", cfg)
    let r = try c.request("notifications/channels", method: "POST", body: input)
    let o = try body(r)
    #expect(Set(o.keys) == ["name", "channel_type", "config"] && o["channel_type"] as? String == "email")
    let conf = try #require(o["config"] as? [String: Any])
    #expect(conf["password"] as? String == "hunter2-secret" && conf["host"] as? String == "smtp.example.com")
    for text in [String(describing: input), String(reflecting: input), String(describing: cfg), "\(cfg)"] {
        #expect(!text.contains("hunter2"))
    }
}

@Test func emailChannelOmitsEmptyCredentials() {
    let cfg = EmailChannelConfig(host: "h", security: "none", from: "a@b.c", to: ["x@y.z"])
    #expect(cfg.json["password"] == nil && cfg.json["username"] == nil && cfg.json["port"] == nil)
}

@Test func channelToggleSendsOnlyEnabled() throws {
    let r = try c.request("notifications/channels/n1", method: "PUT", body: ChannelEnabledUpdate(enabled: false))
    let o = try body(r)
    #expect(o.count == 1 && o["enabled"] as? Bool == false)
}

@Test func createSLOBodyMatchesSchema() throws {
    let s = SLOInput(name: "api", namespace: "prod", service: "web", sloType: "Availability", targetPercentage: 99.9, timeWindowDays: 30)
    let r = try c.request("slo/slos", method: "POST", body: s)
    let o = try body(r)
    #expect(Set(o.keys) == ["name", "namespace", "service", "slo_type", "target_percentage", "time_window_days"])
    #expect(o["target_percentage"] as? Double == 99.9 && o["time_window_days"] as? Int == 30)
}
