import SwiftUI
import ZeusKit

struct MigrationsView: View {
    @Environment(AppModel.self) private var model
    let client: ZeusClient
    @State private var loader: Loader<[MigrationInfo]>
    @State private var vmID: VM.ID?
    @State private var preflight: MigrationPreflight?
    @State private var checking = false
    @State private var confirming = false
    @State private var failure: String?

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader { try await client.migrations() })
    }

    private var running: [VM] { model.vms.filter { $0.status == "Running" } }
    private var vm: VM? { running.first { $0.id == vmID } }

    var body: some View {
        VStack(spacing: 0) {
            if model.canWrite { migrateBar }
            LoadStateView(loader: loader) { all in
                if all.isEmpty {
                    ContentUnavailableView("No migrations", systemImage: "arrow.left.arrow.right",
                        description: Text("Live migrations appear here while they run and afterwards."))
                } else {
                    Table(all) {
                        TableColumn("Machine") { Text($0.vmiName ?? $0.name) }
                        TableColumn("Namespace", value: \.namespace)
                        TableColumn("Phase") { Text($0.phase ?? "—") }
                        TableColumn("From") { Text($0.sourceNode ?? "—") }
                        TableColumn("To") { Text($0.targetNode ?? "—") }
                        TableColumn("Started") { Text($0.created ?? "—") }
                    }
                }
            }
        }
        .navigationTitle("Migrations")
        .safeAreaInset(edge: .bottom) { if let failure { InlineError(message: failure) { self.failure = nil } } }
        .confirmationDialog("Live-migrate \(vm?.name ?? "")?", isPresented: $confirming, titleVisibility: .visible) {
            Button("Migrate") { Task { await migrate() } }
        } message: {
            Text("The machine keeps running and moves to another node chosen by the scheduler.")
        }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }

    private var migrateBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Picker("Running machine", selection: $vmID) {
                    Text("Choose…").tag(VM.ID?.none)
                    ForEach(running) { Text("\($0.name) (\($0.namespace))").tag(Optional($0.id)) }
                }
                .onChange(of: vmID) { preflight = nil }
                Button("Check") { Task { await check() } }.disabled(vm == nil || checking)
                Button("Migrate…") { confirming = true }
                    .disabled(vm == nil || preflight?.ready != true)
            }
            if let p = preflight {
                if p.ready {
                    Label("Preflight passed.", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                } else {
                    ForEach(p.blockers, id: \.self) { Label($0, systemImage: "xmark.octagon.fill").foregroundStyle(.red) }
                    if let r = p.remediation { Text(r).font(.caption).foregroundStyle(.secondary) }
                }
                ForEach(p.checks.filter { $0.status == "warn" }) {
                    Label($0.message ?? $0.check, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                }
            }
        }
        .padding(10).background(.bar)
    }

    private func check() async {
        guard let vm else { return }
        checking = true; defer { checking = false }
        do { preflight = try await client.migrationPreflight(vm); failure = nil }
        catch { failure = describe(error, "run the preflight check") }
    }

    private func migrate() async {
        guard model.canWrite, let vm else { return }
        do { try await client.liveMigrate(vm); failure = nil }
        catch { failure = describe(error, "start the migration") }
        await loader.reload()
    }
}

/// Read-only: creating a machine from a template is not offered because the instantiate endpoint
/// addresses templates by `{namespace}/{name}` while built-in templates have an empty namespace.
struct TemplatesView: View {
    let client: ZeusClient
    @State private var loader: Loader<[VMTemplateInfo]>
    @State private var types: Loader<[InstanceTypeInfo]>
    @State private var search = ""
    @State private var showTypes = false

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader { try await client.templates() })
        _types = State(initialValue: Loader { try await client.instanceTypes() })
    }

    var body: some View {
        Group {
            if showTypes {
                LoadStateView(loader: types) { all in
                    Table(all.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }) {
                        TableColumn("Name", value: \.name)
                        TableColumn("CPU") { Text($0.cpuCores.map(String.init) ?? "—") }
                        TableColumn("Memory") { Text($0.memory ?? "—") }
                        TableColumn("GPU") { Text($0.gpu ?? "—") }
                    }
                }
            } else {
                LoadStateView(loader: loader) { all in
                    Table(all.filter { search.isEmpty || [$0.title, $0.category ?? "", $0.osType ?? ""]
                        .contains { $0.localizedCaseInsensitiveContains(search) } }) {
                        TableColumn("Template") { Text($0.title) }
                        TableColumn("Category") { Text($0.category ?? "—") }
                        TableColumn("OS") { Text($0.osType ?? "—") }
                        TableColumn("CPU") { Text($0.cpuCores.map(String.init) ?? "—") }
                        TableColumn("Memory") { Text($0.memoryGi.map { "\($0.formatted()) GiB" } ?? "—") }
                        TableColumn("Disk") { Text($0.diskSizeGi.map { "\($0.formatted()) GiB" } ?? "—") }
                        TableColumn("Source") { Text($0.isBuiltIn ? "Built-in" : ($0.namespace ?? "")) }
                    }
                }
            }
        }
        .navigationTitle(showTypes ? "Instance Types" : "Templates")
        .searchable(text: $search)
        .toolbar {
            Picker("Catalog", selection: $showTypes) {
                Text("Templates").tag(false); Text("Instance Types").tag(true)
            }.pickerStyle(.segmented)
        }
        .task { loader.start(polling: false); types.start(polling: false) }
        .onDisappear { loader.stop(); types.stop() }
    }
}

struct VMGroupsView: View {
    @Environment(AppModel.self) private var model
    let client: ZeusClient
    @State private var loader: Loader<[VMGroup]>
    @State private var selection: VMGroup.ID?
    @State private var pending: String?
    @State private var note: String?
    @State private var failure: String?

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader { try await client.vmGroups() })
    }

    private var group: VMGroup? { loader.value?.first { $0.id == selection } }

    var body: some View {
        LoadStateView(loader: loader) { all in
            if all.isEmpty {
                ContentUnavailableView("No groups", systemImage: "square.stack.3d.up",
                    description: Text("Groups select machines by label and run power actions on all of them."))
            } else {
                Table(all, selection: $selection) {
                    TableColumn("Name", value: \.name)
                    TableColumn("Selector") { Text(($0.selector ?? [:]).map { "\($0.key)=\($0.value)" }.sorted().joined(separator: ", ")) }
                    TableColumn("Namespace") { Text($0.namespace ?? "All") }
                }
            }
        }
        .navigationTitle("VM Groups")
        .toolbar {
            if model.canWrite {
                ToolbarItem {
                    Menu("Group Action", systemImage: "power") {
                        Button("Start") { pending = "start" }
                        Button("Stop") { pending = "stop" }
                        Button("Restart") { pending = "restart" }
                    }.disabled(group == nil)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if let failure { InlineError(message: failure) { self.failure = nil } }
            else if let note { Text(note).padding(10) }
        }
        .confirmationDialog("\(pending?.capitalized ?? "") every machine in \(group?.name ?? "")?",
                            isPresented: Binding(get: { pending != nil }, set: { if !$0 { pending = nil } }),
                            titleVisibility: .visible) {
            Button(pending?.capitalized ?? "Run") { if let p = pending { Task { await run(p) } } }
        }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }

    private func run(_ action: String) async {
        guard model.canWrite, let group else { return }
        do {
            let r = try await client.groupAction(group, action: action)
            note = "\(action.capitalized): \(r.succeeded ?? 0) succeeded, \(r.failed ?? 0) failed."; failure = nil
        } catch { failure = describe(error, "run the group action"); note = nil }
    }
}
