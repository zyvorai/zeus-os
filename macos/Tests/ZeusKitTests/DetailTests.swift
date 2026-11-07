import Testing
import Foundation
@testable import ZeusKit

private func decode<T: Decodable>(_ t: T.Type, _ json: String) throws -> T {
    try JSONDecoder().decode(T.self, from: Data(json.utf8))
}

@Test func decodesLiveNodeDetailConditionsAndAllocatable() throws {
    let n = try decode(NodeDetail.self, #"{"name":"node-1","status":"Ready","roles":["control-plane"],"age":"11d","version":"v1.35.5+k3s1","cpu_capacity_millicores":12000,"mem_capacity_bytes":32950419456,"pod_capacity":250,"raw":{"spec":{"podCIDR":"10.42.0.0/24","taints":[{"key":"k","effect":"NoSchedule"}]},"status":{"conditions":[{"type":"Ready","status":"True","reason":"KubeletReady","message":"ok","lastTransitionTime":"2026-10-27T01:23:23Z"},{"type":"MemoryPressure","status":"False"},{"type":"DiskPressure","status":"True"}],"allocatable":{"cpu":"12","pods":"250"},"capacity":{"cpu":"12"},"addresses":[{"type":"InternalIP","address":"10.0.0.1"}],"nodeInfo":{"osImage":"Ubuntu","kernelVersion":"7.0","kubeletVersion":"v1.35.5","containerRuntimeVersion":"containerd://2"}}}}"#)
    #expect(n.podCapacity == 250 && n.allocatable["pods"] == "250" && n.conditions.count == 3)
    #expect(n.conditions[0].isHealthy && n.conditions[1].isHealthy && !n.conditions[2].isHealthy)
    #expect(!n.unschedulable && n.taints == ["k:NoSchedule"] && n.addresses == ["InternalIP 10.0.0.1"])
    let bare = try decode(NodeDetail.self, #"{"name":"x"}"#)
    #expect(bare.conditions.isEmpty)
}

@Test func decodesLiveDrainStatusAndProblems() throws {
    let d = try decode(NodeDrainStatus.self, #"{"node":"n","cordoned":false,"total_pods":55,"evicting_pods":0,"completed_pods":1,"vms_on_node":["default/a"],"migrations_in_progress":[]}"#)
    #expect(d.totalPods == 55 && d.vmsOnNode == ["default/a"] && d.cordoned == false)
    let p = try decode([NodeProblem].self, #"[{"condition_type":"KaironMemoryPressure","status":"False","message":"m","last_transition":"2026-11-07T09:09:01+00:00"}]"#)
    #expect(p[0].id == "KaironMemoryPressure")
}

@Test func decodesLiveHostPCIInterfacesServices() throws {
    let p = try decode([HostPCIDevice].self, #"[{"slot":"00:00.0","class":"Host bridge [0600]","vendor":"Intel [8086]","device":"Device [4c53]","iommu_group":"0"}]"#)
    #expect(p[0].deviceClass == "Host bridge [0600]" && p[0].iommuGroup == "0")
    let i = try decode([HostInterface].self, #"[{"name":"eth0","mac_address":"aa:bb","ip_addresses":["10.0.0.1/32"],"mtu":1500,"state":"up","speed_mbps":10000,"rx_bytes":13451092952,"tx_bytes":152865315}]"#)
    #expect(i[0].ipAddresses.count == 1 && i[0].rxBytes == 13451092952)
    let s = try decode([HostService].self, #"[{"name":"cilium","state":"active","sub_state":"running","description":"d"}]"#)
    #expect(s[0].subState == "running")
}

// Execution ids look like "namespace/name". The live server 404s on that id raw and as %2F, and answers by the bare workflow name.
@Test func workflowExecutionIsAddressedByWorkflowName() throws {
    let e = try decode([WorkflowExecution].self, #"[{"id":"rook-ceph/job-1","workflow_id":"job-1","status":"completed","started_at":"2026-11-05T15:09:05+00:00","finished_at":null,"current_step":null,"steps_completed":1,"steps_total":1}]"#)[0]
    #expect(e.pathKey == "job-1")
    #expect(WorkflowExecution.pathKey(forId: "ns/other", workflowId: nil) == "other")
    #expect(WorkflowExecution.pathKey(forId: "plain", workflowId: "") == "plain")
    let d = try decode(WorkflowExecutionDetail.self, #"{"execution":{"id":"rook-ceph/job-1","workflow_id":"job-1","status":"completed"},"step_results":[{"step_name":"Complete","status":"True","output":{"message":"m"},"error":null}],"output":{"succeeded":"1"}}"#)
    #expect(d.stepResults[0].output?["message"]?.string == "m" && d.output?["succeeded"]?.string == "1")
}

@Test func decodesLiveSLODetailWithBudgetHistory() throws {
    let l = try decode([SLO].self, #"[{"name":"vm-avail","namespace":"default","service":"VirtualMachines","slo_type":"Availability","target":99.9,"current":100.0,"status":"Meeting","time_window":"current","budget_remaining":100.0}]"#)
    #expect(l[0].id == "default/vm-avail" && l[0].budgetRemaining == 100)
    let d = try decode(SLODetail.self, #"{"name":"vm-avail","namespace":"default","service":"VirtualMachines","description":"d","slo_config":{"slo_type":"Availability","target_percentage":99.9,"measurement_method":"ResourceBased"},"current_performance":{"current_percentage":100.0,"total_requests":0,"good_requests":0,"bad_requests":0,"status":"Meeting"},"error_budget":{"total_budget":0.1,"consumed":0.0,"remaining":0.1,"remaining_percentage":100.0,"burn_rate":0.0,"estimated_depletion":null},"alerts":[],"historical_data":[{"timestamp":"2026-11-07T14:03:41+00:00","value":100.0,"budget_remaining":100.0}]}"#)
    #expect(d.historicalData.count == 1 && d.errorBudget?.remainingPercentage == 100 && d.sloConfig?.targetPercentage == 99.9)
}

@Test func decodesLiveRolesBindingsAndPermissions() throws {
    let r = try decode([RoleSummary].self, #"[{"name":"admin","namespace":null,"is_cluster_role":true,"rules_count":79,"created_at":"x","labels":{}}]"#)
    #expect(r[0].isClusterRole && r[0].rulesCount == 79)
    let d = try decode(RoleDetail.self, #"{"name":"x","namespace":"kube-system","is_cluster_role":false,"rules":[{"api_groups":[""],"resources":["configmaps"],"verbs":["get"],"resource_names":["a"]},{"api_groups":["*"],"resources":["*"],"verbs":["*"],"resource_names":[]}],"created_at":"x","labels":{},"annotations":{}}"#)
    #expect(d.rules.count == 2 && !d.rules[0].isWildcard && d.rules[1].isWildcard)
    let b = try decode([RoleBindingSummary].self, #"[{"name":"b","namespace":null,"is_cluster_binding":true,"role_name":"admin","role_kind":"ClusterRole","subjects_count":1}]"#)
    #expect(b[0].roleName == "admin")
    let p = try decode(MyPermissions.self, #"{"can_create_vms":true,"can_migrate":false,"namespace_access":[{"namespace":"default","can_manage_vms":true}]}"#)
    #expect(p.flags["can_create_vms"] == true && p.flags["can_migrate"] == false && p.namespaceAccess[0].namespace == "default")
}

// Request shape only. Never sent to the live shared server.
@Test func uncordonIsAPostToTheNodeUncordonPath() throws {
    let c = ZeusClient(baseURL: URL(string: "https://zeus.test")!, token: "t")
    let r = try c.request(ZeusClient.uncordonPath("node/1"), method: "POST")
    #expect(r.httpMethod == "POST" && r.httpBody == nil)
    #expect(r.url?.absoluteString == "https://zeus.test/api/v1/nodes/node%2F1/uncordon")
}
