import Foundation

// Write actions the OpenAPI document leaves undefined. The wire formats below were read from the server's own
// web dashboard bundle (static assets served at the server root), which necessarily sends them. Nothing here has
// been sent to a live server; the tests inspect the built requests.

/// What a budget covers. Dashboard bundle: `scope = {kind:"cluster"}` or `{kind:"namespace"|"tenant", name}`.
public enum BudgetScope: Sendable, Equatable, Hashable, Encodable {
    case cluster
    case tenant(String)
    case namespace(String)

    public var kind: String {
        switch self { case .cluster: "cluster"; case .tenant: "tenant"; case .namespace: "namespace" }
    }
    public var name: String? {
        switch self { case .cluster: nil; case .tenant(let n), .namespace(let n): n }
    }

    /// Reads a row's `scope` object as returned by `GET /finops/budgets`.
    public init?(json: JSONValue?) {
        guard let kind = json?["kind"]?.string else { return nil }
        switch kind {
        case "cluster": self = .cluster
        case "tenant": guard let n = json?["name"]?.string else { return nil }; self = .tenant(n)
        case "namespace": guard let n = json?["name"]?.string else { return nil }; self = .namespace(n)
        default: return nil
        }
    }

    enum CodingKeys: String, CodingKey { case kind, name }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(kind, forKey: .kind)
        try c.encodeIfPresent(name, forKey: .name)
    }
}

/// Body of `POST /finops/budgets` and `PUT /finops/budgets/{id}` (same body for both).
/// Dashboard bundle: `{name, scope, monthly_limit, thresholds, channel_ids, enabled}`.
public struct BudgetInput: Encodable, Sendable, Equatable {
    public var name: String
    public var scope: BudgetScope
    public var monthlyLimit: Double
    public var thresholds: [Int]
    public var channelIds: [String]
    public var enabled: Bool

    public static let defaultThresholds = [50, 80, 100]
    public static let maxLimit = 1_000_000_000.0

    public init(name: String, scope: BudgetScope, monthlyLimit: Double, thresholds: [Int] = BudgetInput.defaultThresholds,
                channelIds: [String] = [], enabled: Bool = true) {
        self.name = name; self.scope = scope; self.monthlyLimit = monthlyLimit
        self.thresholds = thresholds; self.channelIds = channelIds; self.enabled = enabled
    }

    enum CodingKeys: String, CodingKey {
        case name, scope, thresholds, enabled
        case monthlyLimit = "monthly_limit", channelIds = "channel_ids"
    }

    /// The dashboard's threshold rules: whole percentages 1...1000, de-duplicated, sorted, at most five.
    public static func parseThresholds(_ text: String) -> Result<[Int], BudgetValidationError> {
        let parts = text.split(whereSeparator: { $0 == "," || $0.isWhitespace }).map(String.init)
        if parts.isEmpty { return .failure(.init("Enter at least one threshold percentage.")) }
        var values: [Int] = []
        for p in parts {
            let s = p.hasSuffix("%") ? String(p.dropLast()) : p
            guard let v = Int(s), (1...1000).contains(v) else {
                return .failure(.init("Thresholds are whole percentages between 1 and 1000."))
            }
            values.append(v)
        }
        let unique = Array(Set(values)).sorted()
        return unique.count > 5 ? .failure(.init("At most 5 thresholds are allowed.")) : .success(unique)
    }

    /// First problem with the draft, or nil. Mirrors the dashboard's own checks.
    public var validationMessage: String? {
        if name.trimmingCharacters(in: .whitespaces).isEmpty { return "Give the budget a name." }
        if let n = scope.name, n.trimmingCharacters(in: .whitespaces).isEmpty {
            return scope.kind == "namespace" ? "Choose a namespace." : "Enter the tenant id."
        }
        if !monthlyLimit.isFinite || monthlyLimit <= 0 { return "Enter a monthly limit greater than 0." }
        if monthlyLimit > Self.maxLimit { return "The limit cannot exceed 1,000,000,000." }
        return nil
    }
}

public struct BudgetValidationError: Error, Sendable, Equatable {
    public let message: String
    init(_ m: String) { message = m }
}

struct HelmRollbackBody: Encodable { let revision: Int }

extension ZeusClient {
    public func createBudget(_ b: BudgetInput) async throws { try await post("finops", "budgets", body: b) }
    public func updateBudget(id: String, _ b: BudgetInput) async throws { try await put("finops", "budgets", id, body: b) }

    /// `POST /helm/releases/{namespace}/{name}/rollback` with `{revision}` (dashboard `rollbackRelease(ns, name, revision)`).
    public func helmRollback(_ r: HelmRelease, toRevision revision: Int) async throws {
        try await post("helm", "releases", r.namespace ?? "default", r.name, "rollback", body: HelmRollbackBody(revision: revision))
    }
}
