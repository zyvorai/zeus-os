import Foundation

// Read-only workload and Kubernetes resource lists.
// Secret-like resources are decoded into types that have no field for values, so `data`, `stringData`
// and token fields in a response are dropped at decode time and can never be stored, logged or shown.

/// `GET /secrets`: name, namespace, type and age only.
public struct SecretSummary: Decodable, Sendable, Identifiable, Hashable {
    public let name: String, namespace: String
    public let secretType: String?, createdAt: String?
    public var id: String { "\(namespace)/\(name)" }
    enum CodingKeys: String, CodingKey { case name, namespace, secretType = "secret_type", createdAt = "created_at" }
    public var row: JSONValue {
        .object(["name": .string(name), "namespace": .string(namespace),
                 "type": secretType.map(JSONValue.string) ?? .null, "created_at": createdAt.map(JSONValue.string) ?? .null])
    }
}

/// `GET /service-accounts`: identity only; token and secret references are not decoded.
public struct ServiceAccountSummary: Decodable, Sendable, Identifiable, Hashable {
    public let name: String, namespace: String
    public let createdAt: String?, automountToken: Bool?
    public var id: String { "\(namespace)/\(name)" }
    enum CodingKeys: String, CodingKey { case name, namespace, createdAt = "created_at", automountToken = "automount_service_account_token" }
    public var row: JSONValue {
        .object(["name": .string(name), "namespace": .string(namespace),
                 "created_at": createdAt.map(JSONValue.string) ?? .null, "automount_token": automountToken.map(JSONValue.bool) ?? .null])
    }
}

/// `GET /tls-secrets`: certificate metadata (no key material).
public struct TLSSecretSummary: Decodable, Sendable, Identifiable, Hashable {
    public let name: String, namespace: String
    public let certType: String?, commonName: String?, issuer: String?, notAfter: String?, createdAt: String?
    public let daysUntilExpiry: Int?, isExpired: Bool?
    public var id: String { "\(namespace)/\(name)" }
    enum CodingKeys: String, CodingKey {
        case name, namespace, issuer
        case certType = "cert_type", commonName = "common_name", notAfter = "not_after", createdAt = "created_at"
        case daysUntilExpiry = "days_until_expiry", isExpired = "is_expired"
    }
    public var row: JSONValue {
        var o: [String: JSONValue] = ["name": .string(name), "namespace": .string(namespace)]
        if let certType { o["type"] = .string(certType) }
        if let commonName { o["common_name"] = .string(commonName) }
        if let issuer { o["issuer"] = .string(issuer) }
        if let notAfter { o["not_after"] = .string(notAfter) }
        if let daysUntilExpiry { o["days_until_expiry"] = .number(Double(daysUntilExpiry)) }
        if let isExpired { o["expired"] = .bool(isExpired) }
        return .object(o)
    }
}

public extension ZeusClient {
    func tail_deployments() async throws -> [JSONValue] { try await list("workloads", "deployments") }
    func tail_statefulSets() async throws -> [JSONValue] { try await list("statefulsets") }
    func tail_daemonSets() async throws -> [JSONValue] { try await list("daemonsets") }
    func tail_jobs() async throws -> [JSONValue] { try await list("jobs") }
    func tail_cronJobs() async throws -> [JSONValue] { try await list("cronjobs") }
    func tail_configMaps() async throws -> [JSONValue] { try await list("configmaps") }
    func secretSummaries() async throws -> [SecretSummary] { try await list("secrets") }
    func tlsSecretSummaries() async throws -> [TLSSecretSummary] { try await list("tls-secrets") }
    func serviceAccountSummaries() async throws -> [ServiceAccountSummary] { try await list("service-accounts") }
    func tail_externalSecrets() async throws -> [JSONValue] { try await list("external-secrets") }
    func tail_certificates() async throws -> [JSONValue] { try await list("certificates") }
    func tail_vmis() async throws -> [JSONValue] { try await list("vmis") }
    func tail_vmReplicaSets() async throws -> [JSONValue] { try await list("vmirs") }
    func tail_vmExports() async throws -> [JSONValue] { try await list("virtualmachineexports") }
    func tail_vmTemplates() async throws -> [JSONValue] { try await list("vm-templates") }
    func tail_storageClasses() async throws -> [JSONValue] { try await list("storage-classes") }
    func tail_volumeSnapshotClasses() async throws -> [JSONValue] { try await list("volumesnapshotclasses") }
    func tail_ingressClasses() async throws -> [JSONValue] { try await list("ingressclasses") }
    func tail_crds() async throws -> [JSONValue] { try await list("crds") }
    func tail_portForwards() async throws -> [JSONValue] { try await list("port-forwards") }
}
