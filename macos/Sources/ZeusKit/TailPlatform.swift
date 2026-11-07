import Foundation

// Read-only platform, admin, licensing, ACL, search and integration models. Free-form responses are decoded to
// `JSONValue` and passed through `scrubbed()`, which drops secret-looking keys and values at decode time.

extension JSONValue {
    /// True for object keys that look like secrets (keys, tokens, passwords, client secrets, webhook URLs, credentials).
    static func isSecretKey(_ key: String) -> Bool {
        let k = key.lowercased().filter { $0 != "_" && $0 != "-" && $0 != " " }
        if k.hasSuffix("key") || k.hasSuffix("keys") { return true }
        return ["secret", "token", "password", "passwd", "passphrase", "webhook", "credential", "authorization",
                "bearer", "cookie"].contains { k.contains($0) }
    }

    /// True for string values that carry credentials on their own (userinfo in a URL, a webhook endpoint).
    static func isSecretValue(_ s: String) -> Bool {
        let l = s.lowercased()
        if l.contains("hooks.slack.com") || l.contains("/webhook") || l.contains("discord.com/api/webhooks") { return true }
        if let r = l.range(of: "://") {
            let rest = l[r.upperBound...].prefix { $0 != "/" }
            if rest.contains("@") { return true }
        }
        return l.hasPrefix("bearer ") || l.hasPrefix("eyj")
    }

    /// A copy with every secret-looking key and value removed, at any depth.
    public func scrubbed() -> JSONValue {
        switch self {
        case .object(let o):
            var out: [String: JSONValue] = [:]
            for (k, v) in o where !Self.isSecretKey(k) {
                if case .string(let s) = v, Self.isSecretValue(s) { continue }
                out[k] = v.scrubbed()
            }
            return .object(out)
        case .array(let a):
            return .array(a.compactMap { if case .string(let s) = $0, Self.isSecretValue(s) { nil } else { $0.scrubbed() } })
        default: return self
        }
    }
}

/// Decodes as `JSONValue` and scrubs, so secrets never reach a view model. Use for every free-form response here.
public struct ScrubbedJSON: Decodable, Sendable {
    public let value: JSONValue
    public init(from decoder: Decoder) throws { value = try JSONValue(from: decoder).scrubbed() }
}

public struct ServerStats: Decodable, Sendable {
    public let requestsTotal: Int?
    public let errorsTotal: Int?
    public let avgLatencyMs: Double?
    public let activeWs: Int?
    public let uptimeSecs: Int?
    public let requestsPerSec: Double?
    public let activeSessions: Int?
    enum CodingKeys: String, CodingKey {
        case requestsTotal = "requests_total", errorsTotal = "errors_total", avgLatencyMs = "avg_latency_ms"
        case activeWs = "active_ws", uptimeSecs = "uptime_secs", requestsPerSec = "requests_per_sec"
        case activeSessions = "active_sessions"
    }
}   // client IPs are deliberately not modelled

public struct PlatformPreflight: Decodable, Sendable {
    public let veleroInstalled: Bool?
    public let volumeSnapshotClassCount: Int?
    public let csiSnapshotCrdPresent: Bool?
    public let hints: [String]
    public let warnings: [String]
    public let defaultStorageClass: String?
    public let defaultVolumeSnapshotClass: String?
    public let metallbApiPresent: Bool?
    public let metallbAddressPoolCount: Int?
    public let snapshotControllerReady: Bool?
    public let stuckVolumeSnapshots: Int?

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        veleroInstalled = try? c.decode(Bool.self, forKey: .veleroInstalled)
        volumeSnapshotClassCount = try? c.decode(Int.self, forKey: .volumeSnapshotClassCount)
        csiSnapshotCrdPresent = try? c.decode(Bool.self, forKey: .csiSnapshotCrdPresent)
        hints = (try? c.decode([String].self, forKey: .hints)) ?? []
        warnings = (try? c.decode([String].self, forKey: .warnings)) ?? []
        defaultStorageClass = try? c.decode(String.self, forKey: .defaultStorageClass)
        defaultVolumeSnapshotClass = try? c.decode(String.self, forKey: .defaultVolumeSnapshotClass)
        metallbApiPresent = try? c.decode(Bool.self, forKey: .metallbApiPresent)
        metallbAddressPoolCount = try? c.decode(Int.self, forKey: .metallbAddressPoolCount)
        snapshotControllerReady = try? c.decode(Bool.self, forKey: .snapshotControllerReady)
        stuckVolumeSnapshots = try? c.decode(Int.self, forKey: .stuckVolumeSnapshots)
    }
    enum CodingKeys: String, CodingKey {
        case veleroInstalled, volumeSnapshotClassCount, csiSnapshotCrdPresent, hints, warnings, defaultStorageClass
        case defaultVolumeSnapshotClass, metallbApiPresent, metallbAddressPoolCount, snapshotControllerReady, stuckVolumeSnapshots
    }
}

/// The signed-in user's onboarding progress (`GET /onboarding/state`; read only, never advanced from the app).
public struct OnboardingState: Decodable, Sendable {
    public let completedTaskIds: [String]
    public let tourCompleted: Bool
    public let bannerDismissed: Bool
    enum CodingKeys: String, CodingKey {
        case completedTaskIds = "completed_task_ids", tourCompleted = "tour_completed", bannerDismissed = "banner_dismissed"
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        completedTaskIds = (try? c.decode([String].self, forKey: .completedTaskIds)) ?? []
        tourCompleted = (try? c.decode(Bool.self, forKey: .tourCompleted)) ?? false
        bannerDismissed = (try? c.decode(Bool.self, forKey: .bannerDismissed)) ?? false
    }
}

/// Windows licensing inventory. Counts are typed; per-VM rows are free-form and scrubbed (they may hold product keys).
public struct LicensingInventory: Decodable, Sendable {
    public let totalWindowsVMs: Int
    public let agentConnected: Int
    public let activated: Int
    public let kmsClients: Int
    public let vms: [JSONValue]
    enum CodingKeys: String, CodingKey {
        case totalWindowsVMs = "total_windows_vms", agentConnected = "agent_connected", activated, kmsClients = "kms_clients", vms
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        totalWindowsVMs = (try? c.decode(Int.self, forKey: .totalWindowsVMs)) ?? 0
        agentConnected = (try? c.decode(Int.self, forKey: .agentConnected)) ?? 0
        activated = (try? c.decode(Int.self, forKey: .activated)) ?? 0
        kmsClients = (try? c.decode(Int.self, forKey: .kmsClients)) ?? 0
        vms = ((try? c.decode([JSONValue].self, forKey: .vms)) ?? []).map { $0.scrubbed() }
    }
}

/// Capabilities read from the GraphQL schema text (`GET /graphql/schema`): query fields and type names only.
public struct GraphQLCapabilities: Sendable, Equatable {
    public struct Field: Sendable, Equatable, Identifiable {
        public let name: String, type: String, summary: String?
        public var id: String { name }
    }
    public let queryFields: [Field]
    public let typeNames: [String]

    public init(schema: String) {
        var fields: [Field] = [], types: [String] = []
        var current: String?, doc: String?
        for raw in schema.split(separator: "\n", omittingEmptySubsequences: true) {
            let line = raw.trimmingCharacters(in: .whitespaces)
            if line.hasPrefix("type ") || line.hasPrefix("input ") || line.hasPrefix("enum ") {
                let name = line.split(separator: " ").dropFirst().first.map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "{")) } ?? ""
                current = name; types.append(name); doc = nil
            } else if line == "}" {
                current = nil
            } else if line.hasPrefix("\"\"\"") {
                doc = line.replacing("\"\"\"", with: "")
            } else if current == "Query", let colon = line.firstIndex(of: ":") {
                fields.append(Field(name: String(line[..<colon]), type: line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces), summary: doc))
                doc = nil
            }
        }
        queryFields = fields; typeNames = types
    }
}

public extension ZeusClient {
    /// Any GET under `/api/v1`, scrubbed of secret-looking keys and values.
    func tailJSON(_ segments: [String], query: [URLQueryItem] = []) async throws -> JSONValue {
        let s: ScrubbedJSON = try await send(Self.path(segments), query: query)
        return s.value
    }
    func serverStats() async throws -> ServerStats { try await get("admin", "server-stats") }
    func platformPreflight() async throws -> PlatformPreflight { try await get("platform", "preflight") }
    func onboardingState() async throws -> OnboardingState { try await get("onboarding", "state") }
    func licensingInventory() async throws -> LicensingInventory { try await get("licensing", "inventory") }
    /// Universal search. A GET with a query string; it does not trigger indexing.
    func universalSearch(_ text: String) async throws -> [JSONValue] {
        try await tailJSON(["search", "universal"], query: [URLQueryItem(name: "q", value: text)]).array ?? []
    }
    func graphQLCapabilities() async throws -> GraphQLCapabilities {
        let data = try await raw(try request("graphql/schema"))
        return GraphQLCapabilities(schema: String(decoding: data, as: UTF8.self))
    }
}
