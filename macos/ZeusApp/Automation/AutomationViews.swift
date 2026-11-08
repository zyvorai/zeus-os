import SwiftUI
import ZeusKit

// Automation and delivery screens. Read-only except the row actions in OpsActions.swift (editor and admin roles).

func autoWhen(_ s: String?) -> Text {
    if let d = zeusDate(s) { Text(d, format: .dateTime.month().day().hour().minute()) } else { Text(s?.isEmpty == false ? s! : "—") }
}

private func dash(_ s: String?) -> Text { Text(s?.isEmpty == false ? s! : "—") }

private func yesNo(_ b: Bool?) -> Text { Text(b == nil ? "—" : (b! ? "Yes" : "No")) }

/// Colours a status word without hiding the word itself.
private func statusText(_ s: String?) -> some View {
    let v = (s ?? "").lowercased()
    let bad = ["failed", "failure", "error", "degraded", "rejected", "outofsync", "unhealthy"].contains(v)
    let good = ["completed", "success", "succeeded", "healthy", "deployed", "synced", "approved", "active", "running"].contains(v)
    return Text(s?.isEmpty == false ? s! : "—").foregroundStyle(bad ? Color.red : (good ? Color.primary : Color.secondary))
}

/// One table backed by its own loader, with the standard empty state and reload button.
struct AutoTable<Row: Identifiable & Sendable, Columns: TableColumnContent>: View where Columns.TableRowValue == Row, Columns.TableColumnSortComparator == Never {
    let title: String
    let emptyTitle: String
    let emptyDetail: String
    let symbol: String
    @State var loader: Loader<[Row]>
    /// Write actions for a row (empty for none). Only offered when the signed-in role can write.
    var rowActions: ((Row) -> [OpsAction])? = nil
    @TableColumnBuilder<Row, Never> var columns: () -> Columns
    @Environment(AppModel.self) private var model
    @State private var selection: Row.ID?
    @State private var pending: OpsAction?
    @State private var failure: String?

    private func actions(_ id: Row.ID?, in rows: [Row]) -> [OpsAction] {
        guard model.canWrite, let rowActions, let id, let row = rows.first(where: { $0.id == id }) else { return [] }
        return rowActions(row)
    }

    var body: some View {
        LoadStateView(loader: loader) { rows in
            if rows.isEmpty {
                ContentUnavailableView(emptyTitle, systemImage: symbol, description: Text(emptyDetail))
            } else {
                Table(rows, selection: $selection) { columns() }
                    .contextMenu(forSelectionType: Row.ID.self) { ids in
                        if ids.count == 1 {
                            ForEach(actions(ids.first, in: rows)) { a in
                                Button(a.title, systemImage: a.symbol) { pending = a }
                            }
                        }
                    }
            }
        }
        .toolbar {
            ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } }
            if model.canWrite, rowActions != nil {
                ToolbarItem {
                    Menu("Actions", systemImage: "ellipsis.circle") {
                        let list = actions(selection, in: loader.value ?? [])
                        if list.isEmpty { Text("Select a row") }
                        ForEach(list) { a in Button(a.title, systemImage: a.symbol) { pending = a } }
                    }
                }
            }
        }
        .opsActions(pending: $pending, failure: $failure) { await loader.reload() }
        .task { loader.start() }
        .onDisappear { loader.stop() }
        .accessibilityLabel(title)
    }
}

// MARK: Tasks and scheduled operations

struct TasksView: View {
    let client: ZeusClient
    enum Section: String, CaseIterable, Identifiable { case tasks = "Tasks", scheduled = "Scheduled"; var id: Self { self } }
    @State private var section = Section.tasks

    var body: some View {
        VStack(spacing: 0) {
            Picker("Section", selection: $section) { ForEach(Section.allCases) { Text($0.rawValue).tag($0) } }
                .pickerStyle(.segmented).labelsHidden().padding()
            switch section {
            case .tasks:
                AutoTable(title: "Tasks", emptyTitle: "No tasks", emptyDetail: "No tasks are running or recorded.",
                          symbol: "checklist", loader: Loader { try await client.opsTasks() },
                          rowActions: { OpsActions.task($0, client: client) }) {
                    TableColumn("Type") { dash($0.taskType) }
                    TableColumn("Object") { Text([$0.namespace, $0.object].compactMap { $0 }.joined(separator: "/")) }
                    TableColumn("Status") { statusText($0.status) }.width(90)
                    TableColumn("Progress") { Text($0.progressPct.map { "\($0)%" } ?? "—") }.width(70)
                    TableColumn("By") { dash($0.startedBy) }
                    TableColumn("Message") { Text($0.message ?? "").lineLimit(1) }
                }
            case .scheduled:
                AutoTable(title: "Scheduled", emptyTitle: "No scheduled operations",
                          emptyDetail: "No scheduled VM operations are defined.",
                          symbol: "calendar.badge.clock", loader: Loader { try await client.scheduledOperations() },
                          rowActions: { OpsActions.scheduled($0, client: client) }) {
                    TableColumn("Name") { dash($0.name ?? $0.id) }
                    TableColumn("Action") { dash($0.action) }
                    TableColumn("VM") { Text([$0.namespace, $0.vmName].compactMap { $0 }.joined(separator: "/")) }
                    TableColumn("Cron") { dash($0.cron) }
                    TableColumn("Enabled") { yesNo($0.enabled) }.width(70)
                    TableColumn("Last run") { autoWhen($0.lastRun) }
                }
            }
        }
        .navigationTitle("Tasks")
    }
}

// MARK: Workflows and playbooks

struct WorkflowsView: View {
    let client: ZeusClient
    enum Section: String, CaseIterable, Identifiable { case workflows = "Workflows", executions = "Executions", playbooks = "Playbooks"; var id: Self { self } }
    @State private var section = Section.executions

    var body: some View {
        VStack(spacing: 0) {
            Picker("Section", selection: $section) { ForEach(Section.allCases) { Text($0.rawValue).tag($0) } }
                .pickerStyle(.segmented).labelsHidden().padding()
            switch section {
            case .workflows:
                AutoTable(title: "Workflows", emptyTitle: "No workflows", emptyDetail: "No workflows are defined on this server.",
                          symbol: "point.3.connected.trianglepath.dotted", loader: Loader { try await client.workflows() },
                          rowActions: { OpsActions.workflow($0, client: client) }) {
                    TableColumn("Name") { dash($0.name ?? $0.id) }
                    TableColumn("Trigger") { dash($0.triggerType) }
                    TableColumn("Schedule") { dash($0.schedule) }
                    TableColumn("Enabled") { yesNo($0.enabled) }.width(70)
                    TableColumn("Runs") { Text($0.executionCount.map(String.init) ?? "—") }.width(50)
                    TableColumn("Last") { autoWhen($0.lastExecution) }
                    TableColumn("Next") { autoWhen($0.nextRun) }
                }
            case .executions:
                AutoTable(title: "Executions", emptyTitle: "No executions", emptyDetail: "No workflow runs are recorded.",
                          symbol: "play.rectangle", loader: Loader { try await client.workflowExecutions() }) {
                    TableColumn("Workflow") { dash($0.workflowId ?? $0.id) }
                    TableColumn("Status") { statusText($0.status) }.width(90)
                    TableColumn("Steps") { e in
                        Text(e.stepsTotal.map { "\(e.stepsCompleted ?? 0)/\($0)" } ?? "—")
                    }.width(60)
                    TableColumn("Current step") { dash($0.currentStep) }
                    TableColumn("Started") { autoWhen($0.startedAt) }
                    TableColumn("Finished") { autoWhen($0.finishedAt) }
                }
            case .playbooks:
                AutoTable(title: "Playbooks", emptyTitle: "No playbooks", emptyDetail: "No remediation playbooks are available.",
                          symbol: "book.closed", loader: Loader { try await client.playbooks() }) {
                    TableColumn("Playbook") { dash($0.title ?? $0.id) }
                    TableColumn("Trigger") { dash($0.trigger) }
                    TableColumn("Risk") { dash($0.risk?.capitalized) }.width(80)
                    TableColumn("Id") { Text($0.id).foregroundStyle(.secondary) }
                }
            }
        }
        .navigationTitle("Workflows")
    }
}

// MARK: Helm

struct HelmView: View {
    @Environment(AppModel.self) private var model
    let client: ZeusClient
    @State private var rollbackTarget: HelmRevision?
    @State private var rollbackFailure: String?
    @State private var uninstalling: HelmRelease?
    @State private var installing = false
    @State private var upgrading: HelmRelease?
    @State private var loader: Loader<[HelmRelease]>
    @State private var selection: HelmRelease.ID?
    @State private var history: [HelmRevision] = []
    @State private var historyFailed = false

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader { try await client.helmReleases() })
    }

    var body: some View {
        LoadStateView(loader: loader) { releases in
            if releases.isEmpty {
                ContentUnavailableView("No Helm releases", systemImage: "helm", description: Text("No releases are installed."))
            } else {
                VSplitView {
                    Table(releases, selection: $selection) {
                        TableColumn("Release") { Text($0.name) }
                        TableColumn("Namespace") { dash($0.namespace) }
                        TableColumn("Chart") { dash($0.chart) }
                        TableColumn("Chart version") { dash($0.chartVersion) }
                        TableColumn("App version") { dash($0.appVersion) }
                        TableColumn("Rev") { Text($0.revision.map(String.init) ?? "—") }.width(40)
                        TableColumn("Status") { statusText($0.status) }.width(90)
                        TableColumn("Updated") { autoWhen($0.updated) }
                    }
                    .frame(minHeight: 160)
                    .contextMenu(forSelectionType: HelmRelease.ID.self) { ids in
                        if model.canWrite, let r = releases.first(where: { ids.contains($0.id) }) {
                            Button("Upgrade…", systemImage: "arrow.up.circle") { upgrading = r }
                            Button("Uninstall…", systemImage: "trash", role: .destructive) { uninstalling = r }
                        }
                    }
                    historyPane(releases)
                }
            }
        }
        .navigationTitle("Helm")
        .toolbar {
            if model.canWrite { ToolbarItem { Button("Install…", systemImage: "plus") { installing = true } } }
            ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } }
        }
        .sheet(isPresented: $installing) {
            HelmJSONSheet(title: "Install a Helm release",
                          message: "The server accepts a free-form JSON object here. Enter exactly what your Zeus OS expects.") { body in
                do { try await client.helmInstall(body); await loader.reload(); return nil }
                catch { return describe(error, "install the release") }
            }
        }
        .sheet(item: $upgrading) { r in
            HelmJSONSheet(title: "Upgrade \(r.name)",
                          message: "Sends a free-form JSON object to the upgrade endpoint.") { body in
                do { try await client.helmUpgrade(r, body); await loader.reload(); return nil }
                catch { return describe(error, "upgrade the release") }
            }
        }
        .task { loader.start() }
        .onDisappear { loader.stop() }
        .task(id: selection) { await loadHistory() }
        .confirmationDialog(uninstalling.map { "Uninstall \($0.name)?" } ?? "",
                            isPresented: Binding(get: { uninstalling != nil }, set: { if !$0 { uninstalling = nil } }),
                            titleVisibility: .visible) {
            Button("Uninstall", role: .destructive) { if let r = uninstalling { Task { await uninstall(r) } } }
        } message: { Text("The release and the resources it created are removed from the cluster. This can't be undone.") }
        .safeAreaInset(edge: .bottom) { if let rollbackFailure { InlineError(message: rollbackFailure) { self.rollbackFailure = nil } } }
    }

    private func uninstall(_ r: HelmRelease) async {
        do { try await client.helmUninstall(r); rollbackFailure = nil; if selection == r.id { selection = nil } }
        catch { rollbackFailure = describe(error, "uninstall the release") }
        await loader.reload()
    }

    @ViewBuilder private func historyPane(_ releases: [HelmRelease]) -> some View {
        if selection == nil {
            ContentUnavailableView("Select a release", systemImage: "clock.arrow.circlepath",
                                   description: Text("Its revision history appears here."))
        } else if historyFailed {
            ContentUnavailableView("Couldn't load history", systemImage: "exclamationmark.triangle")
        } else {
            Table(history) {
                TableColumn("Revision") { Text(String($0.revision)) }.width(70)
                TableColumn("Status") { statusText($0.status) }.width(90)
                TableColumn("Chart") { dash($0.chart) }
                TableColumn("App version") { dash($0.appVersion) }
                TableColumn("Updated") { autoWhen($0.updated) }
                TableColumn("Description") { dash($0.description) }
                TableColumn("") { rev in
                    if model.canWrite, rev.revision != currentRevision(releases) {
                        Button("Roll back…") { rollbackTarget = rev }.buttonStyle(.borderless)
                    }
                }.width(90)
            }
            .frame(minHeight: 120)
            .confirmationDialog(rollbackTarget.map { "Roll back to revision \($0.revision)?" } ?? "",
                                isPresented: Binding(get: { rollbackTarget != nil }, set: { if !$0 { rollbackTarget = nil } }),
                                titleVisibility: .visible) {
                Button("Roll Back", role: .destructive) { if let t = rollbackTarget { Task { await rollback(releases, t) } } }
            } message: { Text("The release is redeployed with that revision's chart and values.") }
        }
    }

    private func currentRevision(_ releases: [HelmRelease]) -> Int? {
        releases.first(where: { $0.id == selection })?.revision
    }

    private func rollback(_ releases: [HelmRelease], _ rev: HelmRevision) async {
        guard let r = releases.first(where: { $0.id == selection }) else { return }
        do { try await client.helmRollback(r, toRevision: rev.revision); rollbackFailure = nil }
        catch { rollbackFailure = describe(error, "roll back the release") }
        await loader.reload()
        await loadHistory()
    }

    private func loadHistory() async {
        history = []; historyFailed = false
        guard let id = selection, let release = loader.value?.first(where: { $0.id == id }) else { return }
        do { history = try await client.helmHistory(release) } catch is CancellationError {} catch { historyFailed = true }
    }
}

// MARK: GitOps

struct GitOpsView: View {
    let client: ZeusClient
    enum Section: String, CaseIterable, Identifiable {
        case kustomizations = "Kustomizations", helm = "Flux Helm", sources = "Sources", argo = "Argo CD"
        var id: Self { self }
    }
    @State private var section = Section.kustomizations
    @State private var stats: GitOpsStats?

    var body: some View {
        VStack(spacing: 0) {
            Picker("Section", selection: $section) { ForEach(Section.allCases) { Text($0.rawValue).tag($0) } }
                .pickerStyle(.segmented).labelsHidden().padding([.horizontal, .top])
            if let s = stats {
                Text("\(s.totalKustomizations ?? 0) kustomizations · \(s.totalHelmReleases ?? 0) Helm releases · \(s.totalGitRepos ?? 0) sources · \(s.totalArgoApps ?? 0) Argo apps · \(s.readyResources ?? 0) ready, \(s.failedResources ?? 0) failed, \(s.suspendedResources ?? 0) suspended")
                    .font(.callout).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading).padding([.horizontal, .top])
            }
            Group {
                switch section {
                case .kustomizations:
                    AutoTable(title: "Kustomizations", emptyTitle: "No Flux kustomizations",
                              emptyDetail: "Flux isn't managing any kustomizations here.",
                              symbol: "arrow.triangle.branch", loader: Loader { try await client.fluxKustomizations() }) {
                        TableColumn("Name") { Text($0.name) }
                        TableColumn("Namespace") { dash($0.namespace) }
                        TableColumn("Path") { dash($0.path) }
                        TableColumn("Source") { Text([$0.sourceKind, $0.sourceName].compactMap { $0 }.joined(separator: "/")) }
                        TableColumn("Ready") { yesNo($0.ready) }.width(60)
                        TableColumn("Suspended") { yesNo($0.suspended) }.width(80)
                        TableColumn("Revision") { dash($0.lastAppliedRevision) }
                    }
                case .helm:
                    AutoTable(title: "Flux Helm", emptyTitle: "No Flux Helm releases",
                              emptyDetail: "Flux isn't managing any Helm releases here.",
                              symbol: "helm", loader: Loader { try await client.fluxHelmReleases() }) {
                        TableColumn("Name") { Text($0.name) }
                        TableColumn("Namespace") { dash($0.namespace) }
                        TableColumn("Chart") { Text([$0.chart, $0.chartVersion].compactMap { $0 }.joined(separator: " ")) }
                        TableColumn("Ready") { yesNo($0.ready) }.width(60)
                        TableColumn("Suspended") { yesNo($0.suspended) }.width(80)
                        TableColumn("Failures") { Text($0.failures.map(String.init) ?? "—") }.width(70)
                        TableColumn("Revision") { dash($0.lastAppliedRevision) }
                    }
                case .sources:
                    AutoTable(title: "Sources", emptyTitle: "No Git sources", emptyDetail: "No Flux Git repositories are configured.",
                              symbol: "externaldrive.connected.to.line.below", loader: Loader { try await client.fluxGitRepositories() }) {
                        TableColumn("Name") { Text($0.name) }
                        TableColumn("Namespace") { dash($0.namespace) }
                        TableColumn("URL") { dash($0.url) }
                        TableColumn("Branch") { dash($0.branch) }
                        TableColumn("Ready") { yesNo($0.ready) }.width(60)
                        TableColumn("Updated") { autoWhen($0.lastUpdate) }
                    }
                case .argo:
                    AutoTable(title: "Argo CD", emptyTitle: "No Argo CD applications", emptyDetail: "Argo CD isn't managing any applications here.",
                              symbol: "arrow.triangle.2.circlepath", loader: Loader { try await client.argoApplications() }) {
                        TableColumn("Name") { Text($0.name) }
                        TableColumn("Project") { dash($0.project) }
                        TableColumn("Sync") { statusText($0.syncStatus) }.width(90)
                        TableColumn("Health") { statusText($0.healthStatus) }.width(90)
                        TableColumn("Auto-sync") { yesNo($0.autoSync) }.width(80)
                        TableColumn("Repo") { dash($0.sourceRepo) }
                        TableColumn("Destination") { dash($0.destinationNamespace) }
                    }
                }
            }
            .id(section)
        }
        .navigationTitle("GitOps")
        .task { stats = try? await client.gitOpsStats() }
    }
}

// MARK: CI/CD, environments, approvals

struct DeliveryView: View {
    let client: ZeusClient
    enum Section: String, CaseIterable, Identifiable {
        case deployments = "Deployments", environments = "Environments", pipelines = "Pipelines", runs = "Runs", approvals = "Approvals"
        var id: Self { self }
    }
    @State private var section = Section.deployments

    var body: some View {
        VStack(spacing: 0) {
            Picker("Section", selection: $section) { ForEach(Section.allCases) { Text($0.rawValue).tag($0) } }
                .pickerStyle(.segmented).labelsHidden().padding()
            Group {
                switch section {
                case .deployments:
                    AutoTable(title: "Deployments", emptyTitle: "No deployments", emptyDetail: "No deployments are recorded.",
                              symbol: "shippingbox", loader: Loader { try await client.cicdDeployments() }) {
                        TableColumn("Application") { dash($0.application) }
                        TableColumn("Environment") { dash($0.environment) }
                        TableColumn("Version") { dash($0.version) }.width(70)
                        TableColumn("Status") { statusText($0.status) }.width(90)
                        TableColumn("Deployed") { autoWhen($0.deployedAt) }
                        TableColumn("By") { dash($0.deployedBy) }
                        TableColumn("Commit") { Text(String(($0.commitSha ?? "").prefix(8))) }.width(80)
                    }
                case .environments:
                    EnvironmentsPane(client: client)
                case .pipelines:
                    AutoTable(title: "Pipelines", emptyTitle: "No pipelines", emptyDetail: "No CI/CD pipelines are configured.",
                              symbol: "gearshape.2", loader: Loader { try await client.pipelines() }) {
                        TableColumn("Name") { dash($0.name ?? $0.id) }
                        TableColumn("Repo") { dash($0.sourceRepo) }
                        TableColumn("Branch") { dash($0.branch) }
                        TableColumn("Trigger") { dash($0.triggerType) }
                        TableColumn("Enabled") { yesNo($0.enabled) }.width(70)
                        TableColumn("Success") { Text($0.successRate.map { $0.formatted(.number.precision(.fractionLength(0))) + "%" } ?? "—") }.width(70)
                        TableColumn("Last run") { autoWhen($0.lastRun) }
                    }
                case .runs:
                    AutoTable(title: "Runs", emptyTitle: "No pipeline runs", emptyDetail: "No pipeline runs are recorded.",
                              symbol: "play.circle", loader: Loader { try await client.pipelineRuns() }) {
                        TableColumn("Pipeline") { dash($0.pipelineId) }
                        TableColumn("Status") { statusText($0.status) }.width(90)
                        TableColumn("Commit") { Text(String(($0.commitSha ?? "").prefix(8))) }.width(80)
                        TableColumn("Message") { Text($0.commitMessage ?? "").lineLimit(1) }
                        TableColumn("Duration") { Text($0.durationSeconds.map { "\($0)s" } ?? "—") }.width(70)
                        TableColumn("Started") { autoWhen($0.startedAt) }
                        TableColumn("By") { dash($0.triggeredBy) }
                    }
                case .approvals:
                    AutoTable(title: "Approvals", emptyTitle: "No change approvals", emptyDetail: "No change requests are waiting or recorded.",
                              symbol: "checkmark.seal", loader: Loader { try await client.changeApprovals() },
                              rowActions: { OpsActions.approval($0, client: client) }) {
                        TableColumn("Action") { dash($0.action) }
                        TableColumn("Target") { Text([$0.targetNamespace, $0.targetVm].compactMap { $0 }.joined(separator: "/")) }
                        TableColumn("Status") { statusText($0.status) }.width(90)
                        TableColumn("Requester") { dash($0.requester) }
                        TableColumn("Reason") { Text($0.reason ?? "").lineLimit(1) }
                        TableColumn("Requested") { autoWhen($0.createdAt) }
                        TableColumn("Resolved by") { dash($0.resolvedBy) }
                    }
                }
            }
            .id(section)
        }
        .navigationTitle("Delivery")
    }
}

/// Managed environments (promotion order, approval gate) with the deployment counts per namespace beside them.
private struct EnvironmentsPane: View {
    let client: ZeusClient
    var body: some View {
        VSplitView {
            AutoTable(title: "Managed environments", emptyTitle: "No managed environments", emptyDetail: "No environments are defined.",
                      symbol: "square.stack.3d.up", loader: Loader { try await client.managedEnvironments() }) {
                TableColumn("Name") { dash($0.name ?? $0.envId) }
                TableColumn("Type") { dash($0.environmentType) }
                TableColumn("Cluster") { dash($0.clusterId) }
                TableColumn("Namespaces") { Text(String($0.namespaces?.count ?? 0)) }.width(90)
                TableColumn("Needs approval") { yesNo($0.requiresApproval) }.width(110)
                TableColumn("Order") { Text($0.promotionOrder.map(String.init) ?? "—") }.width(50)
                TableColumn("Status") { statusText($0.status) }.width(80)
            }
            .frame(minHeight: 100)
            AutoTable(title: "Namespaces", emptyTitle: "No environments", emptyDetail: "No CI/CD environments were found.",
                      symbol: "square.stack.3d.up", loader: Loader { try await client.cicdEnvironments() }) {
                TableColumn("Namespace") { Text($0.name) }
                TableColumn("Type") { dash($0.environmentType) }
                TableColumn("Cluster") { dash($0.cluster) }
                TableColumn("Deployments") { Text($0.deploymentCount.map(String.init) ?? "—") }.width(100)
                TableColumn("Status") { statusText($0.status) }.width(80)
            }
            .frame(minHeight: 100)
        }
    }
}
