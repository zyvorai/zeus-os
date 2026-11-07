import Foundation

// Read-only automation and delivery models. Every field except the identity is optional so a
// server that omits or nulls a field never blanks a whole list.

public struct OpsTask: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let taskType: String?, status: String?, object: String?, namespace: String?
    public let message: String?, startedBy: String?
    public let progressPct: Int?
    enum CodingKeys: String, CodingKey {
        case id, status, object, namespace, message
        case taskType = "task_type", startedBy = "started_by", progressPct = "progress_pct"
    }
}

struct TaskListResponse: Decodable, Sendable { let tasks: [OpsTask] }

public struct ScheduledOperation: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String?, action: String?, cron: String?, namespace: String?, vmName: String?, lastRun: String?
    public let enabled: Bool?
    enum CodingKeys: String, CodingKey { case id, name, action, cron, namespace, enabled, vmName = "vm_name", lastRun = "last_run" }
}

public struct Workflow: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String?, description: String?, triggerType: String?, schedule: String?
    public let lastExecution: String?, nextRun: String?
    public let enabled: Bool?
    public let executionCount: Int?
    enum CodingKeys: String, CodingKey {
        case id, name, description, schedule, enabled
        case triggerType = "trigger_type", lastExecution = "last_execution", nextRun = "next_run", executionCount = "execution_count"
    }
}

public struct WorkflowExecution: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let workflowId: String?, status: String?, startedAt: String?, finishedAt: String?, currentStep: String?
    public let stepsCompleted: Int?, stepsTotal: Int?
    enum CodingKeys: String, CodingKey {
        case id, status
        case workflowId = "workflow_id", startedAt = "started_at", finishedAt = "finished_at"
        case currentStep = "current_step", stepsCompleted = "steps_completed", stepsTotal = "steps_total"
    }
}

public struct Playbook: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let title: String?, trigger: String?, risk: String?
}

public struct HelmRelease: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String?, chart: String?, chartVersion: String?, appVersion: String?
    public let status: String?, updated: String?, description: String?
    public let revision: Int?
    public var id: String { "\(namespace ?? "")/\(name)" }
    enum CodingKeys: String, CodingKey {
        case name, namespace, chart, status, updated, description, revision
        case chartVersion = "chart_version", appVersion = "app_version"
    }
}

public struct HelmRevision: Decodable, Sendable, Identifiable, Hashable {
    public let revision: Int
    public let updated: String?, status: String?, chart: String?, appVersion: String?, description: String?
    public var id: Int { revision }
    enum CodingKeys: String, CodingKey { case revision, updated, status, chart, description, appVersion = "app_version" }
}

public struct FluxKustomization: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String?, path: String?, interval: String?, sourceKind: String?, sourceName: String?
    public let lastAppliedRevision: String?
    public let ready: Bool?, suspended: Bool?
    public var id: String { "\(namespace ?? "")/\(name)" }
    enum CodingKeys: String, CodingKey {
        case name, namespace, path, interval, ready, suspended
        case sourceKind = "source_kind", sourceName = "source_name", lastAppliedRevision = "last_applied_revision"
    }
}

public struct FluxHelmRelease: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String?, chart: String?, chartVersion: String?, interval: String?, lastAppliedRevision: String?
    public let ready: Bool?, suspended: Bool?
    public let failures: Int?
    public var id: String { "\(namespace ?? "")/\(name)" }
    enum CodingKeys: String, CodingKey {
        case name, namespace, chart, interval, ready, suspended, failures
        case chartVersion = "chart_version", lastAppliedRevision = "last_applied_revision"
    }
}

public struct FluxGitRepository: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String?, url: String?, branch: String?, interval: String?, lastUpdate: String?
    public let ready: Bool?
    public var id: String { "\(namespace ?? "")/\(name)" }
    enum CodingKeys: String, CodingKey { case name, namespace, url, branch, interval, ready, lastUpdate = "last_update" }
}

public struct ArgoApplication: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String?, project: String?, syncStatus: String?, healthStatus: String?
    public let sourceRepo: String?, sourcePath: String?, destinationNamespace: String?
    public let autoSync: Bool?
    public var id: String { "\(namespace ?? "")/\(name)" }
    enum CodingKeys: String, CodingKey {
        case name, namespace, project
        case syncStatus = "sync_status", healthStatus = "health_status", sourceRepo = "source_repo"
        case sourcePath = "source_path", destinationNamespace = "destination_namespace", autoSync = "auto_sync"
    }
}

public struct GitOpsStats: Decodable, Sendable {
    public let totalGitRepos: Int?, totalKustomizations: Int?, totalHelmReleases: Int?, totalArgoApps: Int?
    public let readyResources: Int?, failedResources: Int?, suspendedResources: Int?
    enum CodingKeys: String, CodingKey {
        case totalGitRepos = "total_git_repos", totalKustomizations = "total_kustomizations"
        case totalHelmReleases = "total_helm_releases", totalArgoApps = "total_argo_apps"
        case readyResources = "ready_resources", failedResources = "failed_resources", suspendedResources = "suspended_resources"
    }
}

public struct Pipeline: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String?, description: String?, sourceRepo: String?, branch: String?, triggerType: String?, lastRun: String?
    public let enabled: Bool?
    public let successRate: Double?
    enum CodingKeys: String, CodingKey {
        case id, name, description, branch, enabled
        case sourceRepo = "source_repo", triggerType = "trigger_type", lastRun = "last_run", successRate = "success_rate"
    }
}

public struct PipelineRun: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let pipelineId: String?, status: String?, startedAt: String?, finishedAt: String?, triggeredBy: String?
    public let commitSha: String?, commitMessage: String?
    public let durationSeconds: Int?
    enum CodingKeys: String, CodingKey {
        case id, status
        case pipelineId = "pipeline_id", startedAt = "started_at", finishedAt = "finished_at", triggeredBy = "triggered_by"
        case commitSha = "commit_sha", commitMessage = "commit_message", durationSeconds = "duration_seconds"
    }
}

public struct CICDEnvironment: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let environmentType: String?, cluster: String?, namespace: String?, status: String?
    public let deploymentCount: Int?
    public var id: String { name }
    enum CodingKeys: String, CodingKey {
        case name, cluster, namespace, status
        case environmentType = "environment_type", deploymentCount = "deployment_count"
    }
}

public struct CICDDeployment: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let application: String?, environment: String?, version: String?, status: String?
    public let deployedAt: String?, deployedBy: String?, commitSha: String?
    enum CodingKeys: String, CodingKey {
        case id, application, environment, version, status
        case deployedAt = "deployed_at", deployedBy = "deployed_by", commitSha = "commit_sha"
    }
}

public struct ChangeApproval: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let action: String?, status: String?, requester: String?, reason: String?, comment: String?
    public let targetNamespace: String?, targetVm: String?, createdAt: String?, resolvedAt: String?, resolvedBy: String?
    public let autoApproved: Bool?
    enum CodingKeys: String, CodingKey {
        case id, action, status, requester, reason, comment
        case targetNamespace = "target_namespace", targetVm = "target_vm", createdAt = "created_at"
        case resolvedAt = "resolved_at", resolvedBy = "resolved_by", autoApproved = "auto_approved"
    }
}

public struct ManagedEnvironment: Decodable, Sendable, Identifiable, Hashable {
    public let envId: String
    public let name: String?, environmentType: String?, description: String?, status: String?, clusterId: String?
    public let namespaces: [String]?
    public let requiresApproval: Bool?
    public let promotionOrder: Int?
    public var id: String { envId }
    enum CodingKeys: String, CodingKey {
        case name, description, status, namespaces
        case envId = "env_id", environmentType = "environment_type", clusterId = "cluster_id"
        case requiresApproval = "requires_approval", promotionOrder = "promotion_order"
    }
}

extension ZeusClient {
    public func opsTasks() async throws -> [OpsTask] {
        let r: TaskListResponse = try await get("tasks")
        return r.tasks
    }
    public func scheduledOperations() async throws -> [ScheduledOperation] { try await list("labs", "scheduled-ops") }
    public func workflows() async throws -> [Workflow] { try await list("workflows") }
    public func workflowExecutions() async throws -> [WorkflowExecution] { try await list("workflows", "executions") }
    public func playbooks() async throws -> [Playbook] { try await list("day2-ops", "playbooks") }
    public func helmReleases() async throws -> [HelmRelease] { try await list("helm", "releases") }
    public func helmHistory(_ r: HelmRelease) async throws -> [HelmRevision] {
        try await list("helm", "releases", r.namespace ?? "default", r.name, "history")
    }
    public func fluxKustomizations() async throws -> [FluxKustomization] { try await list("flux", "kustomizations") }
    public func fluxHelmReleases() async throws -> [FluxHelmRelease] { try await list("flux", "helmreleases") }
    public func fluxGitRepositories() async throws -> [FluxGitRepository] { try await list("flux", "gitrepositories") }
    public func argoApplications() async throws -> [ArgoApplication] { try await list("argocd", "applications") }
    public func gitOpsStats() async throws -> GitOpsStats { try await get("gitops", "stats") }
    public func pipelines() async throws -> [Pipeline] { try await list("cicd", "pipelines") }
    public func pipelineRuns() async throws -> [PipelineRun] { try await list("cicd", "runs") }
    public func cicdEnvironments() async throws -> [CICDEnvironment] { try await list("cicd", "environments") }
    public func cicdDeployments() async throws -> [CICDDeployment] { try await list("cicd", "deployments") }
    public func changeApprovals() async throws -> [ChangeApproval] { try await list("labs", "change-approvals") }
    public func managedEnvironments() async throws -> [ManagedEnvironment] { try await list("environment-management", "environments") }
}
