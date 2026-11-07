import Testing
import Foundation
@testable import ZeusKit

private func decode<T: Decodable>(_ t: T.Type, _ json: String) throws -> T {
    try JSONDecoder().decode(T.self, from: Data(json.utf8))
}

@Test func decodesLiveHelmReleasesAndHistory() throws {
    let r = try decode([HelmRelease].self, #"[{"name":"merion","namespace":"merion-lab","chart":"zyvor-merion","chart_version":"0.1.0","app_version":"0.4.0","revision":2,"status":"deployed","updated":"2026-10-26T16:49:27+00:00","description":"Upgrade complete"}]"#)
    #expect(r[0].id == "merion-lab/merion" && r[0].revision == 2)
    let h = try decode([HelmRevision].self, #"[{"revision":2,"updated":"2026-10-26T16:49:27+00:00","status":"deployed","chart":"zyvor-merion-0.1.0","app_version":"0.4.0","description":"Upgrade complete"},{"revision":1,"updated":"x","status":"superseded","chart":"c","app_version":"0.4.0","description":"Install complete"}]"#)
    #expect(h.count == 2 && h[1].status == "superseded")
}

@Test func decodesLiveWorkflowExecutionsAndPlaybooks() throws {
    let e = try decode([WorkflowExecution].self, #"[{"id":"rook-ceph/job-1","workflow_id":"job-1","status":"completed","started_at":"2026-11-05T15:09:05+00:00","finished_at":"2026-11-05T15:10:24+00:00","current_step":null,"steps_completed":1,"steps_total":1}]"#)
    #expect(e[0].stepsTotal == 1 && e[0].currentStep == nil)
    let p = try decode([Playbook].self, #"[{"id":"node-evacuate","title":"Cordon","trigger":"node_not_ready","risk":"medium"}]"#)
    #expect(p[0].risk == "medium")
}

@Test func decodesLiveCICDAndEnvironments() throws {
    let d = try decode([CICDDeployment].self, #"[{"id":"cdi/cdi-apiserver","application":"cdi-apiserver","environment":"cdi","version":"1","status":"healthy","deployed_at":"2026-11-03T00:56:35+00:00","deployed_by":"kubernetes","commit_sha":""}]"#)
    #expect(d[0].environment == "cdi")
    let e = try decode([CICDEnvironment].self, #"[{"name":"cdi","environment_type":"development","cluster":"local","namespace":"cdi","deployment_count":4,"status":"active"}]"#)
    #expect(e[0].deploymentCount == 4)
    let m = try decode([ManagedEnvironment].self, #"[{"env_id":"env-other","name":"other","environment_type":"other","description":"d","cluster_id":"local","namespaces":["a","b"],"promotion_order":0,"requires_approval":false,"configuration":{},"status":"active"}]"#)
    #expect(m[0].namespaces?.count == 2 && m[0].requiresApproval == false)
}

@Test func decodesLiveTasksAndStatsEmpty() throws {
    let t = try decode(TaskListResponse.self, #"{"tasks":[]}"#)
    #expect(t.tasks.isEmpty)
    let s = try decode(GitOpsStats.self, #"{"total_git_repos":0,"total_kustomizations":0,"total_helm_releases":0,"total_argo_apps":0,"ready_resources":0,"failed_resources":0,"suspended_resources":0,"by_namespace":{}}"#)
    #expect(s.failedResources == 0)
}

// Live lists were empty for these; rows below follow the OpenAPI schemas.
@Test func decodesSchemaOnlyAutomationRows() throws {
    let t = try decode([OpsTask].self, #"[{"id":"t1","task_type":"migrate","status":"running","object":"vm1","namespace":"d","message":"m","started_by":"a","progress_pct":40}]"#)
    #expect(t[0].progressPct == 40)
    let s = try decode([ScheduledOperation].self, #"[{"id":"s1","name":"n","action":"stop","cron":"0 2 * * *","enabled":true,"vm_name":"v","namespace":"d","last_run":"2026-11-01T00:00:00Z"}]"#)
    #expect(s[0].cron == "0 2 * * *" && s[0].vmName == "v")
    let w = try decode([Workflow].self, #"[{"id":"w","name":"n","enabled":true,"trigger_type":"cron","schedule":"* * * * *","execution_count":3}]"#)
    #expect(w[0].executionCount == 3)
    let k = try decode([FluxKustomization].self, #"[{"name":"apps","namespace":"flux-system","path":"./","interval":"5m","ready":true,"suspended":false,"source_kind":"GitRepository","source_name":"r","last_applied_revision":"main@sha1:abc"}]"#)
    #expect(k[0].id == "flux-system/apps" && k[0].ready == true)
    let a = try decode([ArgoApplication].self, #"[{"name":"a","namespace":"argocd","sync_status":"Synced","health_status":"Healthy","auto_sync":true,"project":"default"}]"#)
    #expect(a[0].syncStatus == "Synced")
    let p = try decode([PipelineRun].self, #"[{"id":"r1","pipeline_id":"p","status":"success","duration_seconds":42,"commit_sha":"abc"}]"#)
    #expect(p[0].durationSeconds == 42)
    let c = try decode([ChangeApproval].self, #"[{"id":"c1","action":"delete","status":"pending","requester":"u","target_vm":"v","target_namespace":"d","auto_approved":false}]"#)
    #expect(c[0].targetVm == "v")
}
