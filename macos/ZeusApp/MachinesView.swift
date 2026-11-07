import SwiftUI
import ZeusKit

struct MachinesView: View {
    @Environment(AppModel.self) private var model
    @State private var selection: Set<VM.ID> = []
    @State private var search = ""
    @State private var sort = [KeyPathComparator(\VM.name)]
    @State private var pending: (action: VMAction, vm: VM)?

    private var rows: [VM] {
        model.vms.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }
            .sorted(using: sort)
    }

    private var selectedVMs: [VM] { model.vms.filter { selection.contains($0.id) } }
    /// The inspector and per-machine toolbar apply to exactly one selected machine.
    private var selected: VM? { selection.count == 1 ? selectedVMs.first : nil }

    /// Start is harmless so it runs at once; stop and restart ask first.
    private func request(_ action: VMAction, _ vm: VM) {
        if action == .start { Task { await model.perform(action, on: vm) } }
        else { pending = (action, vm) }
    }

    var body: some View {
        Table(rows, selection: $selection, sortOrder: $sort) {
            TableColumn("Name", value: \.name)
            TableColumn("Status", value: \.status) { vm in
                Label(vm.status, systemImage: "circle.fill")
                    .foregroundStyle(vm.status == "Running" ? .green : .secondary)
            }
            TableColumn("Namespace", value: \.namespace)
            TableColumn("Node") { Text($0.node ?? "—") }
            TableColumn("Age") { Text($0.age ?? "—") }
        }
        .contextMenu(forSelectionType: VM.ID.self) { ids in
            if let vm = model.vms.first(where: { ids.contains($0.id) }) {
                ActionButtons(vm: vm, request: request)
            }
        }
        .toolbar {
            ToolbarItemGroup {
                if let vm = selected { ActionButtons(vm: vm, request: request) }
            }
        }
        .confirmationDialog(pending.map { "\($0.action.title) \($0.vm.name)?" } ?? "",
                            isPresented: Binding(get: { pending != nil }, set: { if !$0 { pending = nil } }),
                            titleVisibility: .visible) {
            if let p = pending {
                Button(p.action.title, role: .destructive) {
                    Task { await model.perform(p.action, on: p.vm) }
                }
            }
        } message: {
            if let p = pending { Text(p.action == .stop ? "The machine shuts down and its workload stops." : "The machine restarts and is briefly unavailable.") }
        }
        .safeAreaInset(edge: .bottom) {
            if let e = model.error { Text(e).font(.callout).foregroundStyle(.red).padding(8) }
        }
        .overlay { if rows.isEmpty { ContentUnavailableView.search(text: search) } }
        .searchable(text: $search)
        .modifier(MachineWriteTools(selected: selectedVMs))
        .inspector(isPresented: .constant(selection.count == 1)) {
            if let vm = selected { VMInspector(vm: vm, request: request, onDeleted: { selection = [] }) }
        }
        .navigationTitle("Machines")
    }
}

struct VMInspector: View {
    let vm: VM
    let request: (VMAction, VM) -> Void
    var onDeleted: () -> Void = {}
    @Environment(AppModel.self) private var model

    var body: some View {
        Form {
            LabeledContent("Name", value: vm.name)
            LabeledContent("Namespace", value: vm.namespace)
            LabeledContent("Status", value: vm.status)
            LabeledContent("Node", value: vm.node ?? "—")
            LabeledContent("Memory", value: vm.memoryGi.map { "\($0) GiB" } ?? "—")
            LabeledContent("Security", value: vm.securityScore.map(String.init) ?? "—")
            Section {
                ActionButtons(vm: vm, request: request)
                if let client = model.client { VMManageButtons(vm: vm, client: client, onDeleted: onDeleted) }
            }
            if !model.canWrite {
                Text("Your role is read-only.").font(.footnote).foregroundStyle(.secondary)
            }
            VMLabelsSection(vm: vm)
            Section("Metrics") { VMMetricsView(vm: vm) }
            if let client = model.client { VMDetailSections(vm: vm, client: client).id(vm.id) }
        }
        .formStyle(.grouped)
        .inspectorColumnWidth(min: 280, ideal: 360)
    }
}

/// Start / Stop / Restart, enabled by role, current state, and whether an action is in flight.
struct ActionButtons: View {
    let vm: VM
    let request: (VMAction, VM) -> Void
    @Environment(AppModel.self) private var model

    var body: some View {
        ForEach(VMAction.allCases, id: \.self) { action in
            Button(action.title, systemImage: symbol(action)) { request(action, vm) }
                .disabled(!model.canWrite || model.busy.contains(vm.id) || !action.isAvailable(for: vm.status))
                .help(model.canWrite ? action.title : "Your role is read-only")
        }
    }

    private func symbol(_ a: VMAction) -> String {
        switch a { case .start: "play.fill"; case .stop: "stop.fill"; case .restart: "arrow.clockwise" }
    }
}
