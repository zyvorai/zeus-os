import Testing
import Foundation
@testable import ZeusKit

private func dec<T: Decodable>(_ t: T.Type, _ s: String) throws -> T { try JSONDecoder().decode(t, from: Data(s.utf8)) }

// Live shapes (trimmed, scrubbed).
@Test func decodesLiveDeploymentsAndDaemonSets() throws {
    let d = try dec(Listing<JSONValue>.self, #"[{"name":"zyvor-axiom","namespace":"axiom-system","replicas":1,"ready_replicas":1,"strategy":"RollingUpdate","images":["x:1"]}]"#).items
    #expect(d[0]["name"]?.string == "zyvor-axiom" && d[0]["replicas"]?.string == "1")
    let s = try dec(Listing<JSONValue>.self, #"[{"name":"cilium","namespace":"kube-system","desired_nodes":1,"ready_nodes":1,"update_strategy":"RollingUpdate"}]"#).items
    #expect(s[0]["ready_nodes"]?.string == "1")
}

@Test func decodesLiveJobsConfigMapsVMIs() throws {
    let j = try dec(Listing<JSONValue>.self, #"[{"name":"prep","namespace":"rook-ceph","status":"Complete","completions":1,"succeeded":1,"duration_seconds":31}]"#).items
    #expect(j[0]["status"]?.string == "Complete")
    let c = try dec(Listing<JSONValue>.self, #"[{"name":"kube-root-ca.crt","namespace":"axiom-system","data_keys":["ca.crt"],"data_size_bytes":566,"immutable":false}]"#).items
    #expect(c[0]["data_size_bytes"]?.string == "566")
    let v = try dec(Listing<JSONValue>.self, #"[{"name":"demo-alpine","namespace":"default","status":"Running","node":"n1","age":"4d 5h","ip":"10.42.0.11"}]"#).items
    #expect(v[0]["ip"]?.string == "10.42.0.11")
}

@Test func decodesLiveClusterResources() throws {
    let t = try dec(Listing<JSONValue>.self, #"[{"name":"cx1.2xlarge","namespace":"","source":"kubevirt","cpu_cores":8,"memory":"16Gi"}]"#).items
    #expect(t[0]["memory"]?.string == "16Gi")
    let sc = try dec(Listing<JSONValue>.self, #"[{"name":"local-path","provisioner":"rancher.io/local-path","reclaim_policy":"Delete","is_default":false}]"#).items
    #expect(sc[0]["provisioner"]?.string == "rancher.io/local-path")
    let vs = try dec(Listing<JSONValue>.self, #"[{"name":"snap","driver":"rook-ceph.cephfs.csi.ceph.com","deletion_policy":"Delete"}]"#).items
    #expect(vs[0]["driver"]?.string?.hasPrefix("rook") == true)
}

@Test func decodesLiveTLSSecrets() throws {
    let t = try dec([TLSSecretSummary].self, #"[{"name":"zyvor-axiom-tls","namespace":"axiom-system","cert_type":"kubernetes.io/tls","common_name":null,"dns_names":[],"issuer":null,"not_before":null,"not_after":null,"days_until_expiry":null,"is_expired":false}]"#)
    #expect(t[0].id == "axiom-system/zyvor-axiom-tls" && t[0].isExpired == false)
}

@Test func decodesLiveServiceAccountsWithoutTokens() throws {
    let a = try dec([ServiceAccountSummary].self, #"[{"name":"default","namespace":"axiom-system","created_at":"2026-11-02T10:58:32+00:00","automount_service_account_token":true,"secrets":["tok-1"],"token":"SENTINEL"}]"#)
    #expect(a[0].automountToken == true)
    #expect(!String(describing: a[0].row).contains("SENTINEL") && !String(describing: a[0].row).contains("tok-1"))
}

@Test func secretsDropAllValues() throws {
    let s = try dec([SecretSummary].self, #"[{"name":"db-auth","namespace":"app","secret_type":"Opaque","created_at":"2026-11-02T10:58:35+00:00","data_keys":["password"],"data":{"password":"SENTINEL-VALUE"},"stringData":{"p":"SENTINEL-VALUE"},"token":"SENTINEL-VALUE"}]"#)
    #expect(s[0].secretType == "Opaque")
    #expect(!String(describing: s).contains("SENTINEL") && !String(describing: s[0].row).contains("SENTINEL"))
    #expect(s[0].row.object?.keys.sorted() == ["created_at", "name", "namespace", "type"])
}

// Spec-shaped: statefulsets, cronjobs, vmirs, exports, ingress classes, port forwards and external secrets
// were empty on the live server; the envelope form is checked here.
@Test func emptyAndEnvelopeListsDecode() throws {
    #expect(try dec(Listing<JSONValue>.self, "[]").items.isEmpty)
    let w = try dec(Listing<JSONValue>.self, #"{"items":[{"name":"db","namespace":"app","replicas":3}]}"#).items
    #expect(w[0]["replicas"]?.string == "3")
}
