import SwiftUI
import ZeusKit

// Detail screens. Everything here is read-only except the node uncordon button (gated on `canWrite` and confirmed).

private func dash(_ s: String?) -> String { s?.isEmpty == false ? s! : "—" }

private func bytes(_ v: Double?) -> String {
    v.map { Measurement(value: $0, unit: UnitInformationStorage.bytes).formatted(.byteCount(style: .binary)) } ?? "—"
}

private func pct(_ v: Double?) -> String { v.map { String(format: "%.2f%%", $0) } ?? "—" }

private func when(_ s: String?) -> String {
    zeusDate(s).map { $0.formatted(.dateTime.month().day().hour().minute()) } ?? dash(s)
}

/// Standard chrome: reload button and polling for a Loader-backed screen.
struct DetailScreen<T: Sendable, Content: View>: View {
    let title: String
    @State var loader: Loader<T>
    @ViewBuilder var content: (T) -> Content
    var body: some View {
        LoadStateView(loader: loader, content: content)
            .navigationTitle(title)
            .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
            .task { loader.start() }
            .onDisappear { loader.stop() }
    }
}

// MARK: Node inspector

struct NodeInspectorData: Sendable {
    let node: NodeDetail
    let drain: NodeDrainStatus?
    let problems: [NodeProblem]
    let pods: [NodePod]
}

struct NodeInspector: View {
    @Environment(AppModel.self) private var model
    let client: ZeusClient
    let name: String
    var onChanged: () -> Void = {}

    @State private var data: NodeInspectorData?
    @State private var failure: String?
    @State private var confirming = false
    @State private var busy = false
    @State private var actionError: String?

    private func load() async {
        do {
            async let n = client.nodeDetail(name)
            async let d = try? client.nodeDrainStatus(name)
            async let p = try? client.nodeProblems(name)
            async let pods = try? client.nodePods(name)
            data = try await NodeInspectorData(node: n, drain: await d, problems: await p ?? [], pods: await pods ?? [])
            failure = nil
        } catch is CancellationError {
        } catch {
            failure = "Couldn't load this node."
        }
    }

    private func uncordon() async {
        busy = true; actionError = nil
        defer { busy = false }
        do { try await client.uncordonNode(name); await load(); onChanged() }
        catch ZeusError.server(_, let message) { actionError = message.isEmpty ? "The server rejected the request." : message }
        catch { actionError = "Couldn't reach the server." }
    }

    var body: some View {
        Group {
            if let data {
                content(data)
            } else if let failure {
                ContentUnavailableView(failure, systemImage: "exclamationmark.triangle")
            } else {
                ProgressView().controlSize(.large).frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task(id: name) { data = nil; await load() }
    }

    @ViewBuilder private func content(_ d: NodeInspectorData) -> some View {
        let n = d.node
        let cordoned = n.unschedulable || d.drain?.cordoned == true
        Form {
            Section(n.name) {
                LabeledContent("Status", value: dash(n.status))
                LabeledContent("Scheduling", value: cordoned ? "Cordoned" : "Schedulable")
                LabeledContent("Roles", value: n.roles.joined(separator: ", "))
                LabeledContent("Kubelet", value: dash(n.kubeletVersion ?? n.version))
                LabeledContent("OS", value: dash(n.osImage))
                LabeledContent("Kernel", value: dash(n.kernelVersion))
                LabeledContent("Runtime", value: dash(n.containerRuntime))
                if !n.addresses.isEmpty { LabeledContent("Addresses", value: n.addresses.joined(separator: ", ")) }
                if !n.taints.isEmpty { LabeledContent("Taints", value: n.taints.joined(separator: ", ")) }
            }
            if cordoned {
                Section("Maintenance") {
                    Button("Uncordon…", systemImage: "arrow.uturn.backward") { confirming = true }
                        .disabled(!model.canWrite || busy)
                        .help(model.canWrite ? "Return this node to scheduling" : "Your role is read-only")
                    if let actionError { Text(actionError).foregroundStyle(.red).font(.callout) }
                }
            }
            Section("Conditions") {
                ForEach(n.conditions) { c in
                    LabeledContent {
                        Text(c.status ?? "—").foregroundStyle(c.isHealthy ? Color.primary : Color.orange)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(c.type)
                            if let m = c.message, !m.isEmpty { Text(m).font(.caption).foregroundStyle(.secondary) }
                        }
                    }
                }
                if n.conditions.isEmpty { Text("No conditions reported").foregroundStyle(.secondary) }
            }
            Section("Capacity and allocatable") {
                ForEach(n.capacity.keys.sorted(), id: \.self) { k in
                    LabeledContent(k, value: "\(n.allocatable[k] ?? "—") of \(n.capacity[k] ?? "—")")
                }
                if let p = n.podCapacity { LabeledContent("Pod capacity", value: String(p)) }
                if n.capacity.isEmpty { LabeledContent("Memory", value: bytes(n.memCapacityBytes)) }
            }
            Section("Drain status") {
                if let s = d.drain {
                    LabeledContent("Pods", value: "\(s.totalPods ?? 0) total · \(s.evictingPods ?? 0) evicting · \(s.completedPods ?? 0) completed")
                    LabeledContent("Migrations in progress", value: String(s.migrationsInProgress.count))
                    LabeledContent("VMs on node", value: s.vmsOnNode.isEmpty ? "None" : s.vmsOnNode.joined(separator: ", "))
                } else {
                    Text("Drain status unavailable").foregroundStyle(.secondary)
                }
            }
            Section("Problems") {
                if d.problems.isEmpty { Text("None reported").foregroundStyle(.secondary) }
                ForEach(d.problems) { p in
                    LabeledContent(p.conditionType) {
                        VStack(alignment: .trailing) {
                            Text(p.status ?? "—")
                            if let m = p.message { Text(m).font(.caption).foregroundStyle(.secondary) }
                        }
                    }
                }
            }
            Section("Pods (\(d.pods.count))") {
                ForEach(d.pods) { p in
                    LabeledContent("\(p.namespace)/\(p.name)") {
                        Text("\(p.status ?? "—") · \(p.restartCount ?? 0) restarts")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .confirmationDialog("Uncordon \(name)?", isPresented: $confirming, titleVisibility: .visible) {
            Button("Uncordon") { Task { await uncordon() } }
        } message: {
            Text("The node will accept new workloads again.")
        }
    }
}

// MARK: Host detail

struct HostDetailData: Sendable { let pci: [HostPCIDevice]; let interfaces: [HostInterface]; let services: [HostService] }

struct HostDetailView: View {
    enum Tab: String, CaseIterable, Identifiable { case interfaces = "Interfaces", pci = "PCI devices", services = "Services"; var id: Self { self } }
    let client: ZeusClient
    @State private var tab = Tab.interfaces

    var body: some View {
        DetailScreen(title: "Host Detail", loader: Loader {
            async let p = try? client.hostPCI()
            async let i = try? client.hostInterfaces()
            async let s = try? client.hostServices()
            return await HostDetailData(pci: p ?? [], interfaces: i ?? [], services: s ?? [])
        }) { d in
            VStack(spacing: 0) {
                Picker("Section", selection: $tab) { ForEach(Tab.allCases) { Text($0.rawValue).tag($0) } }
                    .pickerStyle(.segmented).labelsHidden().padding()
                switch tab {
                case .interfaces:
                    Table(d.interfaces) {
                        TableColumn("Name", value: \.name)
                        TableColumn("State") { Text(dash($0.state)) }
                        TableColumn("Addresses") { Text($0.ipAddresses.joined(separator: ", ")) }
                        TableColumn("MAC") { Text(dash($0.macAddress)) }
                        TableColumn("MTU") { Text($0.mtu.map(String.init) ?? "—") }
                        TableColumn("Speed") { Text($0.speedMbps.map { "\(Int($0)) Mbps" } ?? "—") }
                        TableColumn("Received") { Text(bytes($0.rxBytes)) }
                        TableColumn("Sent") { Text(bytes($0.txBytes)) }
                    }
                case .pci:
                    Table(d.pci) {
                        TableColumn("Slot", value: \.slot)
                        TableColumn("Class") { Text(dash($0.deviceClass)) }
                        TableColumn("Vendor") { Text(dash($0.vendor)) }
                        TableColumn("Device") { Text(dash($0.device)) }
                        TableColumn("IOMMU group") { Text(dash($0.iommuGroup)) }
                    }
                case .services:
                    Table(d.services) {
                        TableColumn("Service", value: \.name)
                        TableColumn("State") { Text(dash($0.state)) }
                        TableColumn("Sub-state") { Text(dash($0.subState)) }
                        TableColumn("Description") { Text(dash($0.description)) }
                    }
                }
            }
        }
    }
}

// MARK: Workflow executions

struct WorkflowRunsView: View {
    let client: ZeusClient
    @State private var selection: WorkflowExecution.ID?

    var body: some View {
        DetailScreen(title: "Workflow Runs", loader: Loader { try await client.workflowExecutions() }) { rows in
            if rows.isEmpty {
                ContentUnavailableView("No workflow executions", systemImage: "play.circle",
                                       description: Text("Nothing has run yet."))
            } else {
                HSplitView {
                    Table(rows, selection: $selection) {
                        TableColumn("Execution", value: \.id)
                        TableColumn("Status") { Text(dash($0.status)) }
                        TableColumn("Started") { Text(when($0.startedAt)) }
                        TableColumn("Steps") { Text("\($0.stepsCompleted ?? 0)/\($0.stepsTotal ?? 0)") }
                    }
                    .frame(minWidth: 360)
                    Group {
                        if let e = rows.first(where: { $0.id == selection }) {
                            ExecutionDetail(client: client, execution: e)
                        } else {
                            ContentUnavailableView("Select an execution", systemImage: "list.bullet.rectangle")
                        }
                    }
                    .frame(minWidth: 320)
                }
            }
        }
    }
}

private struct ExecutionDetail: View {
    let client: ZeusClient
    let execution: WorkflowExecution
    @State private var detail: WorkflowExecutionDetail?
    @State private var logs: [String] = []
    @State private var failed = false

    var body: some View {
        Form {
            Section(execution.id) {
                LabeledContent("Status", value: dash(execution.status))
                LabeledContent("Started", value: when(execution.startedAt))
                LabeledContent("Finished", value: when(execution.finishedAt))
            }
            if failed { Text("Couldn't load the execution detail.").foregroundStyle(.secondary) }
            Section("Steps") {
                ForEach(detail?.stepResults ?? []) { s in
                    LabeledContent(s.stepName) {
                        VStack(alignment: .trailing) {
                            Text(dash(s.status))
                            if let m = s.output?["message"]?.string { Text(m).font(.caption).foregroundStyle(.secondary) }
                            if let e = s.error, !e.isEmpty { Text(e).font(.caption).foregroundStyle(.red) }
                        }
                    }
                }
            }
            Section("Logs") {
                if logs.isEmpty { Text("No log lines").foregroundStyle(.secondary) }
                ForEach(Array(logs.enumerated()), id: \.offset) { Text($1).font(.system(.caption, design: .monospaced)).textSelection(.enabled) }
            }
        }
        .formStyle(.grouped)
        .task(id: execution.id) {
            detail = nil; logs = []; failed = false
            async let d = try? client.workflowExecution(execution)
            async let l = try? client.workflowExecutionLogs(execution)
            let (dd, ll) = await (d, l)
            detail = dd; logs = ll ?? []; failed = dd == nil
        }
    }
}

// MARK: SLO detail

struct SLOBudgetsView: View {
    let client: ZeusClient
    @State private var selection: SLO.ID?

    var body: some View {
        DetailScreen(title: "SLO Budgets", loader: Loader { try await client.slos() }) { rows in
            if rows.isEmpty {
                ContentUnavailableView("No SLOs", systemImage: "target")
            } else {
                HSplitView {
                    Table(rows, selection: $selection) {
                        TableColumn("SLO", value: \.name)
                        TableColumn("Service") { Text(dash($0.service)) }
                        TableColumn("Target") { Text(pct($0.target)) }
                        TableColumn("Current") { Text(pct($0.current)) }
                        TableColumn("Budget left") { Text(pct($0.budgetRemaining)) }
                        TableColumn("Status") { Text(dash($0.status)) }
                    }
                    .frame(minWidth: 420)
                    Group {
                        if let s = rows.first(where: { $0.id == selection }) {
                            SLODetailPane(client: client, slo: s)
                        } else {
                            ContentUnavailableView("Select an SLO", systemImage: "chart.line.downtrend.xyaxis")
                        }
                    }
                    .frame(minWidth: 320)
                }
            }
        }
    }
}

private struct SLODetailPane: View {
    let client: ZeusClient
    let slo: SLO
    @State private var detail: SLODetail?
    @State private var failed = false

    var body: some View {
        Form {
            if let d = detail {
                Section(d.name) {
                    if let t = d.description { Text(t).foregroundStyle(.secondary) }
                    LabeledContent("Type", value: dash(d.sloConfig?.sloType))
                    LabeledContent("Target", value: pct(d.sloConfig?.targetPercentage))
                    LabeledContent("Current", value: pct(d.currentPerformance?.currentPercentage))
                    LabeledContent("Requests", value: "\(Int(d.currentPerformance?.totalRequests ?? 0)) total · \(Int(d.currentPerformance?.badRequests ?? 0)) bad")
                    LabeledContent("Active alerts", value: String(d.alertCount))
                }
                Section("Error budget") {
                    LabeledContent("Remaining", value: pct(d.errorBudget?.remainingPercentage))
                    LabeledContent("Consumed", value: d.errorBudget?.consumed.map { String(format: "%.4f", $0) } ?? "—")
                    LabeledContent("Burn rate", value: d.errorBudget?.burnRate.map { String(format: "%.2f", $0) } ?? "—")
                    LabeledContent("Estimated depletion", value: dash(d.errorBudget?.estimatedDepletion))
                }
                Section("Budget history") {
                    if d.historicalData.isEmpty { Text("No history recorded").foregroundStyle(.secondary) }
                    ForEach(d.historicalData) { p in
                        LabeledContent(when(p.timestamp), value: "\(pct(p.value)) · \(pct(p.budgetRemaining)) budget left")
                    }
                }
            } else if failed {
                Text("Couldn't load this SLO.").foregroundStyle(.secondary)
            } else {
                ProgressView()
            }
        }
        .formStyle(.grouped)
        .task(id: slo.id) {
            detail = nil; failed = false
            do { detail = try await client.sloDetail(slo) } catch { failed = true }
        }
    }
}

// MARK: RBAC

struct RBACData: Sendable {
    let roles: [RoleSummary]; let bindings: [RoleBindingSummary]; let permissions: MyPermissions?
}

struct RBACView: View {
    let client: ZeusClient
    @State private var selection: RoleSummary.ID?
    @State private var search = ""

    var body: some View {
        DetailScreen(title: "RBAC", loader: Loader {
            async let b = try? client.roleBindings()
            let p = try? await client.myPermissions()
            let all = await client.allRoles(namespaces: p?.namespaceAccess.map(\.namespace) ?? [])
            return await RBACData(roles: all, bindings: b ?? [], permissions: p)
        }) { d in
            let roles = d.roles.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }
            HSplitView {
                VStack(spacing: 0) {
                    if let p = d.permissions {
                        DisclosureGroup("Your permissions") {
                            ForEach(p.flags.keys.sorted(), id: \.self) { k in
                                LabeledContent(k.replacingOccurrences(of: "_", with: " "), value: p.flags[k] == true ? "Yes" : "No")
                            }
                            LabeledContent("Namespaces", value: "\(p.namespaceAccess.filter { $0.canManageVMs == true }.count) of \(p.namespaceAccess.count) manageable")
                        }.padding([.horizontal, .top])
                    }
                    Table(roles, selection: $selection) {
                        TableColumn("Role", value: \.name)
                        TableColumn("Scope") { Text($0.namespace ?? "Cluster") }
                        TableColumn("Rules") { Text($0.rulesCount.map(String.init) ?? "—") }
                    }
                }
                .frame(minWidth: 360)
                Group {
                    if let r = d.roles.first(where: { $0.id == selection }) {
                        RoleDetailPane(client: client, role: r, bindings: d.bindings.filter { $0.roleName == r.name })
                    } else {
                        ContentUnavailableView("Select a role", systemImage: "person.badge.key")
                    }
                }
                .frame(minWidth: 320)
            }
        }
        .searchable(text: $search)
    }
}

private struct RoleDetailPane: View {
    let client: ZeusClient
    let role: RoleSummary
    let bindings: [RoleBindingSummary]
    @State private var detail: RoleDetail?
    @State private var failed = false

    var body: some View {
        Form {
            Section("Bindings (\(bindings.count))") {
                if bindings.isEmpty { Text("Not bound to any subject").foregroundStyle(.secondary) }
                ForEach(bindings) { b in
                    LabeledContent(b.name, value: "\(b.namespace ?? "Cluster") · \(b.subjectsCount ?? 0) subjects")
                }
            }
            Section("Rules") {
                if role.isClusterRole {
                    // The server has no detail route for cluster roles (live lookups all 404).
                    Text("The server doesn't expose rules for cluster roles (\(role.rulesCount ?? 0) rules).").foregroundStyle(.secondary)
                } else if let d = detail {
                    ForEach(d.rules) { r in
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(r.verbs.joined(separator: ", ")) on \(r.resources.joined(separator: ", "))")
                                .foregroundStyle(r.isWildcard ? Color.orange : Color.primary)
                            Text("API groups: \(r.apiGroups.map { $0.isEmpty ? "core" : $0 }.joined(separator: ", "))" +
                                 (r.resourceNames.isEmpty ? "" : " · names: \(r.resourceNames.joined(separator: ", "))"))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                } else if failed {
                    Text("Couldn't load this role.").foregroundStyle(.secondary)
                } else {
                    ProgressView()
                }
            }
        }
        .formStyle(.grouped)
        .navigationSubtitle(role.name)
        .task(id: role.id) {
            detail = nil; failed = false
            guard let ns = role.namespace else { return }
            do { detail = try await client.roleDetail(namespace: ns, name: role.name) } catch { failed = true }
        }
    }
}

// MARK: Read-only lists (scanning, compliance, gatekeeper, mesh, registry, dependencies, observability)

struct RowList: Identifiable {
    let id: String
    let label: String
    let path: [String]
}

/// A picker over several untyped list endpoints. Rows show their name and up to six scalar fields,
/// because most of these collections are empty on a typical server and their schemas are loose.
struct RowListsView: View {
    let title: String
    let client: ZeusClient
    let lists: [RowList]
    @State private var selected: String
    @State private var rows: [JSONValue]?
    @State private var failure: String?

    init(title: String, client: ZeusClient, lists: [RowList]) {
        self.title = title; self.client = client; self.lists = lists
        _selected = State(initialValue: lists[0].id)
    }

    private var current: RowList { lists.first { $0.id == selected } ?? lists[0] }

    private func load() async {
        rows = nil; failure = nil
        let path = current.path
        do {
            rows = try await client.rows(path)
        } catch ZeusError.server(let status, let message) {
            failure = status == 403 ? "Your role can't view this." : (message.isEmpty ? "The server returned \(status)." : message)
        } catch {
            failure = "Couldn't load. Check the connection and try again."
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("List", selection: $selected) { ForEach(lists) { Text($0.label).tag($0.id) } }
                .pickerStyle(.menu).labelsHidden().padding()
            Group {
                if let failure {
                    ContentUnavailableView("Couldn't load", systemImage: "exclamationmark.triangle", description: Text(failure))
                } else if let rows {
                    if rows.isEmpty {
                        ContentUnavailableView("Nothing here", systemImage: "tray",
                                               description: Text("The server returned no \(current.label.lowercased())."))
                    } else {
                        List(Array(rows.enumerated()), id: \.offset) { _, row in RowCell(row: row) }
                    }
                } else {
                    ProgressView().controlSize(.large)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle(title)
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await load() } } } }
        .task(id: selected) { await load() }
    }
}

private struct RowCell: View {
    let row: JSONValue
    private static let titleKeys = ["name", "title", "id", "service_id", "trace_id", "span_id", "report_id", "policy_id", "constraint"]

    var body: some View {
        let obj = row.object ?? [:]
        let titleKey = Self.titleKeys.first { obj[$0]?.string != nil }
        let fields = obj.keys.sorted().filter { $0 != titleKey && obj[$0]?.string != nil && obj[$0]?.string?.isEmpty == false }
        VStack(alignment: .leading, spacing: 2) {
            Text(titleKey.flatMap { obj[$0]?.string } ?? "—").font(.headline)
            Text(fields.prefix(6).map { "\($0): \(obj[$0]?.string ?? "")" }.joined(separator: " · "))
                .font(.caption).foregroundStyle(.secondary).lineLimit(3).textSelection(.enabled)
        }
    }
}
