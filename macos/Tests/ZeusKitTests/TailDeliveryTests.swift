import Testing
import Foundation
@testable import ZeusKit

private func value(_ s: String) throws -> JSONValue {
    try JSONDecoder().decode(JSONValue.self, from: Data(s.utf8)).scrubbed()
}

// Live fixtures are trimmed from a real server; "spec-shaped" ones are labelled because the live list was empty.

@Test func operatorsLiveListDecodesAsRows() throws {
    let v = try value(#"[{"name":"cdi-operator","namespace":"cdi","display_name":"cdi-operator","version":"v1.66.0","provider":"","phase":"Succeeded","replaces":null,"install_modes":[],"created_at":"2026-11-03T00:56:06+00:00"}]"#)
    #expect(v.tailRows?.count == 1 && v.tailRows?[0]["phase"]?.string == "Succeeded")
}

@Test func operatorStatsIsASingleRecord() throws {
    let v = try value(#"{"total_operators":14,"total_subscriptions":0,"total_operator_groups":0}"#)
    #expect(v.tailRows == nil && v["total_operators"]?.number == 14)
}

@Test func emptyListFamiliesDecodeToNoRows() throws {
    // subscriptions, catalogsources, installplans, operatorgroups, catalog/*, blueprints, image-factory,
    // nmstate, gateway-api, customization-profiles, progressive-delivery, iac and kustomize were all empty live.
    #expect(try value("[]").tailRows == [])
    #expect(try value(#"{"drifts":[],"items":[]}"#).tailRows == [])
    #expect(try value(#"{"bases":[],"items":[]}"#).tailRows == [])
}

@Test func nmstateAndGatewaySpecShapedRowsKeepFields() throws {
    // Spec-shaped (live lists empty): free-form records.
    let v = try value(#"[{"name":"br0-policy","status":"Available"},{"name":"gw-1","namespace":"default","class":"cilium"}]"#)
    #expect(v.tailRows?.count == 2 && v.tailRows?[1]["class"]?.string == "cilium")
}

@Test func deploymentStrategiesLiveRowKeepsNestedConfiguration() throws {
    let v = try value(#"[{"strategy_id":"axiom-system/zyvor-axiom","name":"zyvor-axiom","strategy_type":"rolling","namespace":"axiom-system","configuration":{"max_surge":"25%","canary_weight":null},"status":"active"}]"#)
    #expect(v.tailRows?[0]["configuration"]?["max_surge"]?.string == "25%")
}

@Test func webhooksDropURLsSecretsAndCABundles() throws {
    let v = try value(#"[{"name":"cdi-api-datavolume-mutate","webhooks":[{"name":"dv.cdi.kubevirt.io","failure_policy":"Fail","rules":[{"operations":["CREATE"]}],"client_config":{"service":{"namespace":"cdi","name":"cdi-api","path":"/x"},"url":"https://hook.example/x","ca_bundle":"LS0tLS1C"}}]},{"name":"sub","events":["alert.fired"],"url":"https://hook.example/y","secret":"s3cret","headers":{"Authorization":"Bearer x"}}]"#)
    let hook = v.tailRows?[0]["webhooks"]?[0]
    #expect(hook?["name"]?.string == "dv.cdi.kubevirt.io" && hook?["client_config"]?["service"]?["name"]?.string == "cdi-api")
    #expect(hook?["client_config"]?["url"] == nil && hook?["client_config"]?["ca_bundle"] == nil)
    let sub = v.tailRows?[1]
    #expect(sub?["events"]?[0]?.string == "alert.fired" && sub?["url"] == nil && sub?["secret"] == nil && sub?["headers"] == nil)
}

@Test func kustomizeCapabilitiesAndPatchCenterAreSingleRecords() throws {
    #expect(try value(#"{"available":true,"message":"kustomize is available","default_allowed_kinds":["Deployment"]}"#)["available"]?.bool == true)
    let p = try value(#"{"summary":{"total_vms":2,"pending_patches":0},"vms":[{"namespace":"default","name":"demo-alpine","risk":"high","packages":[]}]}"#)
    #expect(p.tailRows == nil && p["summary"]?["total_vms"]?.number == 2 && p["vms"]?[0]?["risk"]?.string == "high")
}

@Test func lifecycleAndRegistryMetricsDecode() throws {
    let l = try value(#"{"desired_kubelet":"v1.35.5+k3s1","compliant":true,"nodes":[{"name":"n","needs_update":false}]}"#)
    #expect(l["compliant"]?.bool == true && l["nodes"]?[0]?["needs_update"]?.bool == false)
    let m = try value(#"{"total_services":30,"healthy_services":0,"avg_service_latency_ms":0.0}"#)
    #expect(m["total_services"]?.number == 30)
}

@Test func marketplaceAndDependencyGraphDecode() throws {
    let m = try value(#"[{"id":"kasm-ubuntu-desktop","name":"Kasm Ubuntu Desktop","category":"security","isolated_namespace":true}]"#)
    #expect(m.tailRows?[0]["isolated_namespace"]?.bool == true)
    let g = try value(#"{"nodes":[{"id":"axiom-system/zyvor-axiom","label":"zyvor-axiom","node_type":"ClusterIP"}],"edges":[]}"#)
    #expect(g.tailRows == nil && g["nodes"]?[0]?["label"]?.string == "zyvor-axiom")
}

@Test func krytonStatusDropsBaseURLButKeepsReason() throws {
    let v = try value(#"{"baseUrl":"http://kryton.kryton.svc:8080","configured":false,"hasApiKey":false,"reason":"unreachable"}"#)
    #expect(v["baseUrl"] == nil && v["configured"]?.bool == false && v["reason"]?.string == "unreachable")
}
