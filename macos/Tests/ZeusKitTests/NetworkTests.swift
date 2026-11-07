import Testing
import Foundation
@testable import ZeusKit

private func dec<T: Decodable>(_ t: T.Type, _ s: String) throws -> T { try JSONDecoder().decode(t, from: Data(s.utf8)) }

// Live shapes.
@Test func decodesLiveNetworkOverview() throws {
    let o = try dec(NetworkOverview.self, #"{"total_policies":5,"total_services":30,"isolated_namespaces":0,"exposed_services":6,"internal_services":24}"#)
    #expect(o.totalServices == 30 && o.exposedServices == 6)
}

@Test func decodesLiveServiceMap() throws {
    let m = try dec(ServiceMap.self, #"{"services":[{"name":"zyvor-axiom-nodeport","namespace":"axiom-system","service_type":"NodePort","endpoints":["a"],"health_status":"Unknown"}],"dependencies":[],"metrics":{}}"#)
    #expect(m.services[0].isExposed && m.services[0].id == "axiom-system/zyvor-axiom-nodeport")
}

@Test func decodesLiveCilium() throws {
    let s = try dec(CiliumStatus.self, #"{"installed":true,"version":"detected","enforcement_mode":"default","policy_count":4,"endpoint_count":47,"hubble_available":false}"#)
    #expect(s.endpointCount == 47 && s.hubbleAvailable == false)
    let e = try dec(CiliumEncryption.self, #"{"cilium_installed":true,"wireguard_enabled":false,"daemonset_desired":1,"daemonset_ready":1,"daemonset_updated":1,"rollout_complete":true,"nodes_with_wireguard_key":0,"node_count":1,"enable_command":"x"}"#)
    #expect(e.wireguardEnabled == false && e.nodeCount == 1)
    let ep = try dec([CiliumEndpoint].self, #"[{"name":"p","namespace":"cdi","identity_id":54411,"identity_labels":["k8s:app=x","k8s:io.cilium.k8s.policy.cluster=default","k8s:io.kubernetes.pod.namespace=cdi","gen:foo=bar"],"ip":"10.42.0.150","state":"ready"}]"#)
    #expect(ep[0].identityId == 54411 && ep[0].appLabels == ["app=x"])
}

@Test func decodesLivePacketWolf() throws {
    let s = try dec(PacketWolfStatus.self, #"{"configured":false,"reachable":false,"apiAuthorized":false,"baseUrl":null,"message":"not configured"}"#)
    #expect(s.configured == false && s.baseUrl == nil)
    let v = try dec(ShieldVMs.self, #"{"vms":[{"name":"demo-alpine","namespace":"default","nodeName":"n","launcherPod":"p","guestIp":"10.42.0.11","podIp":"10.42.0.11","ciliumEndpointId":null,"visibility":"full","enforcement":"supported","totalFlows":0,"droppedFlows":0,"riskLevel":"low"}],"total":1}"#)
    #expect(v.vms[0].riskLevel == "low" && v.vms[0].id == "default/demo-alpine")
}

@Test func decodesLiveDNSAndIPAM() throws {
    let d = try dec(DNSOverrides.self, #"{"configmap_exists":false,"managed":false,"max_records":100,"records":[],"supported":true,"note":"n"}"#)
    #expect(d.supported == true && d.records?.isEmpty == true)
    #expect(try dec(IPAMStore.self, #"{"pools":[]}"#).pools.isEmpty)
}

// Schema only: the live lists were empty.
@Test func decodesSchemaAttachmentsIngressPools() throws {
    let a = try dec([NetworkAttachment].self, #"[{"name":"br","namespace":"default","age":"1d","cni_type":"bridge","bridge_name":"br0","master":null,"vlan":100,"static_addresses":[]}]"#)
    #expect(a[0].vlan == 100 && a[0].bridgeName == "br0")
    let i = try dec([IngressInfo].self, #"[{"name":"i","namespace":"d","hosts":["a.b"],"ingress_class":null,"rules_count":1,"tls_enabled":true,"annotations":{},"created_at":"x"}]"#)
    #expect(i[0].tlsEnabled == true)
    let m = try dec([IPAddressPool].self, #"[{"name":"p","namespace":"metallb-system","addresses":["10.0.0.1-10.0.0.9"],"auto_assign":true,"created_at":"x"}]"#)
    #expect(m[0].autoAssign == true)
    let ip = try dec(IPAMStore.self, #"{"pools":[{"name":"p","cidr":"10.0.0.0/24","gateway":"10.0.0.1","vlan":null,"assignments":[]}]}"#)
    #expect(ip.pools[0].cidr == "10.0.0.0/24")
}
