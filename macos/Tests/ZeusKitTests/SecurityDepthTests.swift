import Testing
import Foundation
@testable import ZeusKit

private func decode<T: Decodable>(_ t: T.Type, _ json: String) throws -> T {
    try JSONDecoder().decode(T.self, from: Data(json.utf8))
}

@Test func decodesLiveFrameworkDetailWithNoSections() throws {
    let d = try decode(ComplianceFrameworkDetail.self, #"{"name":"pci-dss","framework_type":"PCI-DSS","version":"3.2.1","description":"derived","sections":[],"scan_config":{"enabled":true,"schedule":"on-demand","scope":["*"],"excluded_namespaces":[],"auto_remediate":false},"overall_status":{"overall_score":40.0,"total_controls":15,"passed":6,"failed":9,"warnings":0,"not_applicable":0,"trend":null},"remediation_summary":{"total_issues":9,"auto_remediable":0,"manual_remediation_required":9,"estimated_effort_hours":null},"created_at":"2026-11-07T13:23:57+00:00"}"#)
    #expect(d.sections.isEmpty && d.totalIssues == 9 && d.manualRemediation == 9)
}

@Test func decodesFrameworkSectionsPerSchema() throws {
    let d = try decode(ComplianceFrameworkDetail.self, #"{"name":"x","sections":[{"id":"1","title":"T","description":"","compliance_percentage":50,"controls":[{"id":"1.1","title":"c","description":"d","severity":"high","status":"failed","evidence":[],"remediation":"fix","resources_affected":["a"]}]}]}"#)
    #expect(d.sections[0].controls[0].isFailing && d.sections[0].controls[0].resourcesAffected == ["a"])
}

@Test func decodesLiveCISReport() throws {
    let r = try decode(CISReport.self, #"{"benchmark_version":"1.8.0","scan_date":"2026-11-07T13:23:47+00:00","cluster_name":"current-cluster","summary":{"total_checks":20,"passed":0,"failed":20,"warnings":0,"info":0,"score":0.0},"sections":[],"recommendations":["Add resource limits","Add resource limits"]}"#)
    #expect(r.summary?.failed == 20 && r.sections.isEmpty && r.recommendations.count == 2)
}

@Test func decodesLiveRBAC() throws {
    let roles = try decode([RBACRole].self, #"[{"name":"admin","namespace":null,"is_cluster_role":true,"rules_count":79,"created_at":"2026-10-26T16:35:30+00:00","labels":{"a":"b"}}]"#)
    #expect(roles[0].isClusterRole && roles[0].rulesCount == 79 && roles[0].namespace == nil)
    let b = try decode([RBACBinding].self, #"[{"name":"x","namespace":null,"is_cluster_binding":true,"role_name":"r","role_kind":"ClusterRole","subjects_count":1,"created_at":"2026-10-29T01:43:30+00:00"}]"#)
    #expect(b[0].roleName == "r" && b[0].subjectsCount == 1)
    let sa = try decode([RBACServiceAccount].self, #"[{"name":"default","namespace":"axiom-system","secrets_count":0,"created_at":"2026-11-02T10:58:32+00:00","labels":{}}]"#)
    #expect(sa[0].id == "axiom-system/default")
    let a = try decode(RBACAnalysis.self, #"{"total_roles":40,"total_cluster_roles":173,"total_role_bindings":45,"total_cluster_role_bindings":118,"total_service_accounts":100,"overly_permissive_roles":[{"role_name":"cdi","namespace":null,"reason":"Grants * verbs on * resources","severity":"high","recommendations":["x"]}],"unused_service_accounts":["a/b"],"privileged_bindings":[]}"#)
    #expect(a.overlyPermissiveRoles[0].severity == "high" && a.totalClusterRoles == 173 && a.unusedServiceAccounts == ["a/b"])
}

@Test func decodesLiveImageScanReportAndSchemaResults() throws {
    let r = try decode(ImageScanReport.self, #"{"report_id":"live","generated_at":"2026-11-07T13:24:20+00:00","total_images":0,"scanned_images":0,"vulnerable_images":0,"total_vulnerabilities":0,"severity_distribution":{"critical":0,"high":0,"medium":0,"low":0,"negligible":0},"top_vulnerable_images":[]}"#)
    #expect(r.severityDistribution?.total == 0 && r.topVulnerableImages.isEmpty)
    // Live results were empty; this row follows the OpenAPI schema.
    let s = try decode([ImageScanResult].self, #"[{"scan_id":"s1","image":"nginx","tag":"1","digest":"d","scanned_at":"2026-11-07T00:00:00Z","scanner":"trivy","severity_counts":{"critical":1,"high":2,"medium":0,"low":0,"negligible":0},"vulnerabilities":[],"compliance_status":"fail","sbom_available":false}]"#)
    #expect(s[0].severityCounts?.total == 3)
}

@Test func decodesLivePolicyLists() throws {
    let c = try decode([CiliumPolicy].self, #"[{"name":"veyron-net-demo-alpine","namespace":"default","endpoint_selector":"kubevirt.io/vm=demo-alpine","ingress_rules_count":0,"egress_rules_count":1,"age":"4d"}]"#)
    #expect(c[0].egressRulesCount == 1)
    let n = try decode([K8sNetworkPolicy].self, #"[{"name":"zeus-os","namespace":"zeus-os","pod_selector":"app=x","ingress_rules":0,"egress_rules":1,"policy_types":["Ingress","Egress"],"created_at":"2026-11-07T06:01:18+00:00"}]"#)
    #expect(n[0].policyTypes == ["Ingress", "Egress"])
    let v = try decode([AdmissionPolicy].self, #"[{"name":"cdi-api-validate","description":"","rules":[],"failure_policy":"Ignore","match_conditions":[],"enabled":true,"created_at":"2026-11-03T00:56:37+00:00"}]"#)
    #expect(v[0].failurePolicy == "Ignore")
}
