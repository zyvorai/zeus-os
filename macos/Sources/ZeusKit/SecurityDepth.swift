import Foundation

// Read-only security models. Fields the live server was seen to omit or null are optional.

public struct ComplianceControl: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let title: String?
    public let description: String?
    public let severity: String?
    public let status: String?
    public let evidence: [String]?
    public let remediation: String?
    public let resourcesAffected: [String]?
    public var isFailing: Bool { ["fail", "failed", "non_compliant", "noncompliant"].contains((status ?? "").lowercased()) }

    enum CodingKeys: String, CodingKey {
        case id, title, description, severity, status, evidence, remediation
        case resourcesAffected = "resources_affected"
    }
}

public struct ComplianceSection: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let title: String?
    public let description: String?
    public let compliancePercentage: Double?
    public let controls: [ComplianceControl]

    enum CodingKeys: String, CodingKey { case id, title, description, controls, compliancePercentage = "compliance_percentage" }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        title = try c.decodeIfPresent(String.self, forKey: .title)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        compliancePercentage = try c.decodeIfPresent(Double.self, forKey: .compliancePercentage)
        controls = try c.decodeIfPresent([ComplianceControl].self, forKey: .controls) ?? []
    }
}

public struct ComplianceFrameworkDetail: Decodable, Sendable {
    public let name: String
    public let description: String?
    public let sections: [ComplianceSection]
    public let autoRemediable: Int?
    public let manualRemediation: Int?
    public let totalIssues: Int?

    enum CodingKeys: String, CodingKey { case name, description, sections, remediationSummary = "remediation_summary" }
    struct Remediation: Decodable {
        let totalIssues: Int?, autoRemediable: Int?, manualRemediationRequired: Int?
        enum CodingKeys: String, CodingKey {
            case totalIssues = "total_issues", autoRemediable = "auto_remediable", manualRemediationRequired = "manual_remediation_required"
        }
    }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        sections = try c.decodeIfPresent([ComplianceSection].self, forKey: .sections) ?? []
        let r = try c.decodeIfPresent(Remediation.self, forKey: .remediationSummary)
        totalIssues = r?.totalIssues; autoRemediable = r?.autoRemediable; manualRemediation = r?.manualRemediationRequired
    }
}

public struct CISCheck: Decodable, Sendable, Identifiable, Hashable {
    public let checkId: String
    public let description: String?
    public let result: String?
    public let remediation: String?
    public let scored: Bool?
    public var id: String { checkId }
    enum CodingKeys: String, CodingKey { case checkId = "check_id", description, result, remediation, scored }
}

public struct CISSection: Decodable, Sendable, Identifiable, Hashable {
    public let sectionId: String
    public let title: String?
    public let checks: [CISCheck]
    public var id: String { sectionId }
    enum CodingKeys: String, CodingKey { case sectionId = "section_id", title, checks }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        sectionId = try c.decode(String.self, forKey: .sectionId)
        title = try c.decodeIfPresent(String.self, forKey: .title)
        checks = try c.decodeIfPresent([CISCheck].self, forKey: .checks) ?? []
    }
}

public struct CISReport: Decodable, Sendable {
    public struct Summary: Decodable, Sendable {
        public let totalChecks: Int?, passed: Int?, failed: Int?, warnings: Int?, score: Double?
        enum CodingKeys: String, CodingKey { case totalChecks = "total_checks", passed, failed, warnings, score }
    }
    public let benchmarkVersion: String?
    public let summary: Summary?
    public let sections: [CISSection]
    public let recommendations: [String]

    enum CodingKeys: String, CodingKey { case benchmarkVersion = "benchmark_version", summary, sections, recommendations }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        benchmarkVersion = try c.decodeIfPresent(String.self, forKey: .benchmarkVersion)
        summary = try c.decodeIfPresent(Summary.self, forKey: .summary)
        sections = try c.decodeIfPresent([CISSection].self, forKey: .sections) ?? []
        recommendations = try c.decodeIfPresent([String].self, forKey: .recommendations) ?? []
    }
}

public struct RBACRole: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String?
    public let isClusterRole: Bool
    public let rulesCount: Int?
    public let createdAt: String?
    public var id: String { "\(namespace ?? "_cluster")/\(name)" }
    enum CodingKeys: String, CodingKey { case name, namespace, isClusterRole = "is_cluster_role", rulesCount = "rules_count", createdAt = "created_at" }
}

public struct RBACBinding: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String?
    public let isClusterBinding: Bool
    public let roleName: String?
    public let roleKind: String?
    public let subjectsCount: Int?
    public var id: String { "\(namespace ?? "_cluster")/\(name)" }
    enum CodingKeys: String, CodingKey {
        case name, namespace, isClusterBinding = "is_cluster_binding", roleName = "role_name", roleKind = "role_kind", subjectsCount = "subjects_count"
    }
}

public struct RBACServiceAccount: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String
    public let secretsCount: Int?
    public let createdAt: String?
    public var id: String { "\(namespace)/\(name)" }
    enum CodingKeys: String, CodingKey { case name, namespace, secretsCount = "secrets_count", createdAt = "created_at" }
}

public struct RBACAnalysis: Decodable, Sendable {
    public struct Permissive: Decodable, Sendable, Identifiable, Hashable {
        public let roleName: String
        public let namespace: String?
        public let reason: String?
        public let severity: String?
        public var id: String { "\(namespace ?? "_")/\(roleName)/\(reason ?? "")" }
        enum CodingKeys: String, CodingKey { case roleName = "role_name", namespace, reason, severity }
    }
    public struct Privileged: Decodable, Sendable, Identifiable, Hashable {
        public let bindingName: String
        public let namespace: String?
        public let roleName: String?
        public let subjects: [String]?
        public let riskLevel: String?
        public var id: String { "\(namespace ?? "_")/\(bindingName)" }
        enum CodingKeys: String, CodingKey { case bindingName = "binding_name", namespace, roleName = "role_name", subjects, riskLevel = "risk_level" }
    }
    public let totalRoles: Int?, totalClusterRoles: Int?, totalRoleBindings: Int?, totalClusterRoleBindings: Int?, totalServiceAccounts: Int?
    public let overlyPermissiveRoles: [Permissive]
    public let privilegedBindings: [Privileged]
    public let unusedServiceAccounts: [String]

    enum CodingKeys: String, CodingKey {
        case totalRoles = "total_roles", totalClusterRoles = "total_cluster_roles", totalRoleBindings = "total_role_bindings"
        case totalClusterRoleBindings = "total_cluster_role_bindings", totalServiceAccounts = "total_service_accounts"
        case overlyPermissiveRoles = "overly_permissive_roles", privilegedBindings = "privileged_bindings", unusedServiceAccounts = "unused_service_accounts"
    }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        totalRoles = try c.decodeIfPresent(Int.self, forKey: .totalRoles)
        totalClusterRoles = try c.decodeIfPresent(Int.self, forKey: .totalClusterRoles)
        totalRoleBindings = try c.decodeIfPresent(Int.self, forKey: .totalRoleBindings)
        totalClusterRoleBindings = try c.decodeIfPresent(Int.self, forKey: .totalClusterRoleBindings)
        totalServiceAccounts = try c.decodeIfPresent(Int.self, forKey: .totalServiceAccounts)
        overlyPermissiveRoles = try c.decodeIfPresent([Permissive].self, forKey: .overlyPermissiveRoles) ?? []
        privilegedBindings = try c.decodeIfPresent([Privileged].self, forKey: .privilegedBindings) ?? []
        unusedServiceAccounts = try c.decodeIfPresent([String].self, forKey: .unusedServiceAccounts) ?? []
    }
}

public struct SeverityCounts: Decodable, Sendable, Hashable {
    public let critical: Int, high: Int, medium: Int, low: Int, negligible: Int
    public var total: Int { critical + high + medium + low + negligible }
    enum CodingKeys: String, CodingKey { case critical, high, medium, low, negligible }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        critical = try c.decodeIfPresent(Int.self, forKey: .critical) ?? 0
        high = try c.decodeIfPresent(Int.self, forKey: .high) ?? 0
        medium = try c.decodeIfPresent(Int.self, forKey: .medium) ?? 0
        low = try c.decodeIfPresent(Int.self, forKey: .low) ?? 0
        negligible = try c.decodeIfPresent(Int.self, forKey: .negligible) ?? 0
    }
}

public struct ImageScanReport: Decodable, Sendable {
    public struct Vulnerable: Decodable, Sendable, Identifiable, Hashable {
        public let image: String
        public let critical: Int?, high: Int?, total: Int?
        public var id: String { image }
    }
    public let totalImages: Int?, scannedImages: Int?, vulnerableImages: Int?, totalVulnerabilities: Int?
    public let severityDistribution: SeverityCounts?
    public let topVulnerableImages: [Vulnerable]

    enum CodingKeys: String, CodingKey {
        case totalImages = "total_images", scannedImages = "scanned_images", vulnerableImages = "vulnerable_images"
        case totalVulnerabilities = "total_vulnerabilities", severityDistribution = "severity_distribution", topVulnerableImages = "top_vulnerable_images"
    }
    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        totalImages = try c.decodeIfPresent(Int.self, forKey: .totalImages)
        scannedImages = try c.decodeIfPresent(Int.self, forKey: .scannedImages)
        vulnerableImages = try c.decodeIfPresent(Int.self, forKey: .vulnerableImages)
        totalVulnerabilities = try c.decodeIfPresent(Int.self, forKey: .totalVulnerabilities)
        severityDistribution = try c.decodeIfPresent(SeverityCounts.self, forKey: .severityDistribution)
        topVulnerableImages = try c.decodeIfPresent([Vulnerable].self, forKey: .topVulnerableImages) ?? []
    }
}

/// Image scan result row. Vulnerability detail is left out; only the counts are shown.
/// The live collection was empty, so this follows the schema, not a captured response.
public struct ImageScanResult: Decodable, Sendable, Identifiable, Hashable {
    public let scanId: String
    public let image: String
    public let tag: String?
    public let scannedAt: String?
    public let scanner: String?
    public let severityCounts: SeverityCounts?
    public let complianceStatus: String?
    public var id: String { scanId }
    enum CodingKeys: String, CodingKey {
        case scanId = "scan_id", image, tag, scannedAt = "scanned_at", scanner, severityCounts = "severity_counts", complianceStatus = "compliance_status"
    }
}

/// One row of the combined policy list; each source maps its own shape into this.
public struct PolicyRow: Sendable, Identifiable, Hashable {
    public let source: String
    public let name: String
    public let namespace: String?
    public let detail: String
    public var id: String { "\(source)/\(namespace ?? "_")/\(name)" }
}

public struct KyvernoPolicy: Decodable, Sendable {
    public let name: String
    public let namespace: String?
    public let ready: Bool?
    public let rules: Int?
    public let validationFailureAction: String?
    enum CodingKeys: String, CodingKey { case name, namespace, ready, rules, validationFailureAction = "validation_failure_action" }
}

public struct AdmissionPolicy: Decodable, Sendable {
    public let name: String
    public let enabled: Bool?
    public let failurePolicy: String?
    enum CodingKeys: String, CodingKey { case name, enabled, failurePolicy = "failure_policy" }
}

public struct GatekeeperConstraint: Decodable, Sendable {
    public struct Status: Decodable, Sendable {
        public let totalViolations: Int?
        enum CodingKeys: String, CodingKey { case totalViolations = "total_violations" }
    }
    public let name: String
    public let template: String?
    public let enforcementAction: String?
    public let status: Status?
    enum CodingKeys: String, CodingKey { case name, template, enforcementAction = "enforcement_action", status }
}

public struct CiliumPolicy: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String?
    public let endpointSelector: String?
    public let ingressRulesCount: Int?
    public let egressRulesCount: Int?
    public let age: String?
    public var id: String { "\(namespace ?? "_")/\(name)" }
    enum CodingKeys: String, CodingKey {
        case name, namespace, age, endpointSelector = "endpoint_selector", ingressRulesCount = "ingress_rules_count", egressRulesCount = "egress_rules_count"
    }
}

public struct K8sNetworkPolicy: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String?
    public let podSelector: String?
    public let ingressRules: Int?
    public let egressRules: Int?
    public let policyTypes: [String]?
    public var id: String { "\(namespace ?? "_")/\(name)" }
    enum CodingKeys: String, CodingKey {
        case name, namespace, podSelector = "pod_selector", ingressRules = "ingress_rules", egressRules = "egress_rules", policyTypes = "policy_types"
    }
}

extension ZeusClient {
    public func complianceFrameworkDetail(_ name: String) async throws -> ComplianceFrameworkDetail { try await get("compliance", "frameworks", name) }
    public func cisReport() async throws -> CISReport { try await get("compliance", "cis", "report") }
    public func rbacRoles() async throws -> [RBACRole] { try await list("rbac", "roles") }
    public func rbacBindings() async throws -> [RBACBinding] { try await list("rbac", "rolebindings") }
    public func rbacServiceAccounts() async throws -> [RBACServiceAccount] { try await list("rbac", "serviceaccounts") }
    public func rbacAnalysis() async throws -> RBACAnalysis { try await get("rbac", "analysis") }
    public func imageScanReport() async throws -> ImageScanReport { try await get("image-scanning", "reports") }
    public func imageScanResults() async throws -> [ImageScanResult] { try await list("image-scanning", "results") }
    public func ciliumPolicies() async throws -> [CiliumPolicy] { try await list("cilium", "policies") }
    public func networkPolicies() async throws -> [K8sNetworkPolicy] { try await list("networkpolicies") }

    /// Kyverno, admission validating policies and Gatekeeper constraints as one list.
    /// A source that fails is skipped and named in `failed`, so one broken engine doesn't hide the others.
    public func policyRows() async -> (rows: [PolicyRow], failed: [String]) {
        var rows: [PolicyRow] = [], failed: [String] = []
        do {
            let k: [KyvernoPolicy] = try await list("policy", "kyverno", "policies")
            rows += k.map { PolicyRow(source: "Kyverno", name: $0.name, namespace: $0.namespace,
                detail: "\($0.rules ?? 0) rules · \($0.validationFailureAction ?? "—") · \($0.ready == true ? "ready" : "not ready")") }
        } catch { failed.append("Kyverno") }
        do {
            let v: [AdmissionPolicy] = try await list("admission-control", "validating-policies")
            rows += v.map { PolicyRow(source: "Admission", name: $0.name, namespace: nil,
                detail: "failure policy \($0.failurePolicy ?? "—") · \($0.enabled == false ? "disabled" : "enabled")") }
        } catch { failed.append("Admission") }
        do {
            let g: [GatekeeperConstraint] = try await list("opa-gatekeeper", "constraints")
            rows += g.map { PolicyRow(source: "Gatekeeper", name: $0.name, namespace: nil,
                detail: "\($0.template ?? "—") · \($0.enforcementAction ?? "—") · \($0.status?.totalViolations ?? 0) violations") }
        } catch { failed.append("Gatekeeper") }
        return (rows, failed)
    }
}
