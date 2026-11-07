import Foundation

// Read-only networking models. Shapes marked "schema" had empty lists on the live server and follow the OpenAPI spec.

public struct NetworkOverview: Decodable, Sendable, Hashable {
    public let totalPolicies: Int?, totalServices: Int?, isolatedNamespaces: Int?, exposedServices: Int?, internalServices: Int?
    enum CodingKeys: String, CodingKey {
        case totalPolicies = "total_policies", totalServices = "total_services", isolatedNamespaces = "isolated_namespaces"
        case exposedServices = "exposed_services", internalServices = "internal_services"
    }
}

/// schema: `GET /network-attachments` (Multus NetworkAttachmentDefinition).
public struct NetworkAttachment: Decodable, Sendable, Identifiable, Hashable {
    public let name: String, namespace: String
    public let cniType: String?, age: String?, bridgeName: String?, master: String?, resourceName: String?
    public let vlan: Int?
    public let staticAddresses: [String]?
    public var id: String { "\(namespace)/\(name)" }
    enum CodingKeys: String, CodingKey {
        case name, namespace, age, master, vlan
        case cniType = "cni_type", bridgeName = "bridge_name", resourceName = "resource_name", staticAddresses = "static_addresses"
    }
}

/// `GET /network/service-map` services.
public struct MappedService: Decodable, Sendable, Identifiable, Hashable {
    public let name: String, namespace: String
    public let serviceType: String?, healthStatus: String?
    public let endpoints: [String]?
    public var id: String { "\(namespace)/\(name)" }
    public var isExposed: Bool { ["NodePort", "LoadBalancer"].contains(serviceType ?? "") }
    enum CodingKeys: String, CodingKey { case name, namespace, endpoints, serviceType = "service_type", healthStatus = "health_status" }
}

public struct ServiceMap: Decodable, Sendable {
    public let services: [MappedService]
    enum CodingKeys: String, CodingKey { case services }
    public init(from d: Decoder) throws {
        services = try d.container(keyedBy: CodingKeys.self).decodeIfPresent([MappedService].self, forKey: .services) ?? []
    }
}

/// schema: `GET /ingresses`.
public struct IngressInfo: Decodable, Sendable, Identifiable, Hashable {
    public let name: String, namespace: String
    public let hosts: [String]?, ingressClass: String?, rulesCount: Int?, tlsEnabled: Bool?, createdAt: String?
    public var id: String { "\(namespace)/\(name)" }
    enum CodingKeys: String, CodingKey {
        case name, namespace, hosts, ingressClass = "ingress_class", rulesCount = "rules_count", tlsEnabled = "tls_enabled", createdAt = "created_at"
    }
}

/// schema: `GET /metallb/pools`.
public struct IPAddressPool: Decodable, Sendable, Identifiable, Hashable {
    public let name: String, namespace: String?
    public let addresses: [String]?, autoAssign: Bool?, createdAt: String?
    public var id: String { "\(namespace ?? "")/\(name)" }
    enum CodingKeys: String, CodingKey { case name, namespace, addresses, autoAssign = "auto_assign", createdAt = "created_at" }
}

public struct CiliumStatus: Decodable, Sendable, Hashable {
    public let installed: Bool?, version: String?, enforcementMode: String?
    public let policyCount: Int?, endpointCount: Int?, hubbleAvailable: Bool?
    enum CodingKeys: String, CodingKey {
        case installed, version, enforcementMode = "enforcement_mode", policyCount = "policy_count"
        case endpointCount = "endpoint_count", hubbleAvailable = "hubble_available"
    }
}

public struct CiliumEncryption: Decodable, Sendable, Hashable {
    public let ciliumInstalled: Bool?, wireguardEnabled: Bool?, daemonsetDesired: Int?, daemonsetReady: Int?
    public let rolloutComplete: Bool?, nodesWithWireguardKey: Int?, nodeCount: Int?
    enum CodingKeys: String, CodingKey {
        case ciliumInstalled = "cilium_installed", wireguardEnabled = "wireguard_enabled", daemonsetDesired = "daemonset_desired"
        case daemonsetReady = "daemonset_ready", rolloutComplete = "rollout_complete"
        case nodesWithWireguardKey = "nodes_with_wireguard_key", nodeCount = "node_count"
    }
}

public struct CiliumEndpoint: Decodable, Sendable, Identifiable, Hashable {
    public let name: String, namespace: String
    public let identityId: Int?, identityLabels: [String]?, ip: String?, state: String?
    public var id: String { "\(namespace)/\(name)" }
    /// Labels worth showing: drops Cilium's own bookkeeping labels.
    public var appLabels: [String] {
        (identityLabels ?? []).filter { $0.hasPrefix("k8s:") && !$0.contains("io.cilium.") && !$0.contains("io.kubernetes.") }
            .map { String($0.dropFirst(4)) }
    }
    enum CodingKeys: String, CodingKey { case name, namespace, ip, state, identityId = "identity_id", identityLabels = "identity_labels" }
}

/// `GET /packetwolf/status`
public struct PacketWolfStatus: Decodable, Sendable, Hashable {
    public let configured: Bool?, reachable: Bool?, apiAuthorized: Bool?, baseUrl: String?, message: String?
}

public struct ShieldVM: Decodable, Sendable, Identifiable, Hashable {
    public let name: String, namespace: String
    public let nodeName: String?, guestIp: String?, podIp: String?, visibility: String?, enforcement: String?, riskLevel: String?
    public let totalFlows: Int?, droppedFlows: Int?
    public var id: String { "\(namespace)/\(name)" }
}

public struct ShieldVMs: Decodable, Sendable {
    public let vms: [ShieldVM]
    enum CodingKeys: String, CodingKey { case vms }
    public init(from d: Decoder) throws {
        vms = try d.container(keyedBy: CodingKeys.self).decodeIfPresent([ShieldVM].self, forKey: .vms) ?? []
    }
}

public struct IPAMPool: Decodable, Sendable, Identifiable {
    public let name: String, cidr: String?, gateway: String?, vlan: Int?
    public let assignments: [JSONValue]?
    public var id: String { name }
}

public struct IPAMStore: Decodable, Sendable {
    public let pools: [IPAMPool]
    enum CodingKeys: String, CodingKey { case pools }
    public init(from d: Decoder) throws {
        pools = try d.container(keyedBy: CodingKeys.self).decodeIfPresent([IPAMPool].self, forKey: .pools) ?? []
    }
}

/// `GET /network/dns/records` (CoreDNS override ConfigMap state).
public struct DNSOverrides: Decodable, Sendable {
    public let supported: Bool?, managed: Bool?, configmapExists: Bool?, maxRecords: Int?, note: String?
    public let records: [JSONValue]?
    enum CodingKeys: String, CodingKey { case supported, managed, note, records, configmapExists = "configmap_exists", maxRecords = "max_records" }
}

public extension ZeusClient {
    func networkOverview() async throws -> NetworkOverview { try await get("network", "stats") }
    func networkAttachments() async throws -> [NetworkAttachment] { try await list("network-attachments") }
    func serviceMap() async throws -> ServiceMap { try await get("network", "service-map") }
    func ingresses() async throws -> [IngressInfo] { try await list("ingresses") }
    func metallbPools() async throws -> [IPAddressPool] { try await list("metallb", "pools") }
    func ciliumStatus() async throws -> CiliumStatus { try await get("cilium", "status") }
    func ciliumEncryption() async throws -> CiliumEncryption { try await get("cilium", "encryption", "status") }
    func ciliumEndpoints() async throws -> [CiliumEndpoint] { try await list("cilium", "endpoints") }
    func packetWolfStatus() async throws -> PacketWolfStatus { try await get("packetwolf", "status") }
    func shieldVMs() async throws -> ShieldVMs { try await get("packetwolf", "guard", "vms") }
    func ipamPools() async throws -> IPAMStore { try await get("network", "ipam", "pools") }
    func dnsOverrides() async throws -> DNSOverrides { try await get("network", "dns", "records") }
}
