import SwiftUI
import ZeusKit

private extension VMSnapshot {
    var machine: String { vmName ?? "—" }
    var phaseLabel: String { phase ?? (ready == true ? "Ready" : "Pending") }
    var isFailed: Bool { error != nil || phase == "Failed" }
}

struct SnapshotsView: View {
    @Environment(AppModel.self) private var model
    let client: ZeusClient
    @State private var loader: Loader<[VMSnapshot]>
    @State private var search = ""
    @State private var selection = Set<VMSnapshot.ID>()
    @State private var sort = [KeyPathComparator(\VMSnapshot.name)]
    @State private var taking = false
    @State private var deleting: [VMSnapshot]?
    @State private var failure: String?

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader { try await client.snapshots() })
    }

    private func rows(_ all: [VMSnapshot]) -> [VMSnapshot] {
        all.filter { search.isEmpty || [$0.name, $0.machine, $0.namespace]
            .contains { $0.localizedCaseInsensitiveContains(search) } }
           .sorted(using: sort)
    }

    var body: some View {
        LoadStateView(loader: loader) { all in
            let shown = rows(all)
            if all.isEmpty {
                ContentUnavailableView("No snapshots", systemImage: "camera.on.rectangle",
                    description: Text(model.canWrite ? "Take one from the toolbar." : "Nothing to show for this account."))
            } else if shown.isEmpty {
                ContentUnavailableView.search(text: search)
            } else {
                Table(shown, selection: $selection, sortOrder: $sort) {
                    TableColumn("Name", value: \.name)
                    TableColumn("Machine", value: \.machine)
                    TableColumn("Status") { s in
                        Label(s.phaseLabel, systemImage: s.isFailed ? "xmark.octagon.fill"
                              : s.ready == true ? "checkmark.circle.fill" : "clock")
                            .foregroundStyle(s.isFailed ? .red : .primary)
                            .help(s.error ?? "")
                    }
                    TableColumn("Consistency") { Text(($0.consistencyType ?? "—").replacing("_", with: " ")) }
                    TableColumn("Age") { Text($0.age ?? "—") }
                }
                .contextMenu(forSelectionType: VMSnapshot.ID.self) { ids in
                    if model.canWrite, !ids.isEmpty {
                        Button("Delete…", role: .destructive) { deleting = pick(ids, from: all) }
                    }
                }
            }
        }
        .navigationTitle("Snapshots")
        .searchable(text: $search, prompt: "Search snapshots")
        .toolbar {
            if model.canWrite {
                ToolbarItem { Button("Take Snapshot", systemImage: "camera") { taking = true } }
                ToolbarItem {
                    Button("Delete", systemImage: "trash") { deleting = pick(selection, from: loader.value ?? []) }
                        .disabled(selection.isEmpty)
                }
            }
        }
        .safeAreaInset(edge: .bottom) { if let failure { InlineError(message: failure) { self.failure = nil } } }
        .sheet(isPresented: $taking) {
            TakeSnapshotSheet { vm, quiesce in await take(vm, quiesce: quiesce) }
        }
        .confirmationDialog(deleting.map { $0.count == 1 ? "Delete \($0[0].name)?" : "Delete \($0.count) snapshots?" } ?? "",
                            isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }),
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) { if let d = deleting { Task { await delete(d) } } }
        } message: { Text("This can't be undone.") }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }

    private func pick(_ ids: Set<VMSnapshot.ID>, from all: [VMSnapshot]) -> [VMSnapshot]? {
        let hit = all.filter { ids.contains($0.id) }
        return hit.isEmpty ? nil : hit
    }

    private func take(_ vm: VM, quiesce: Bool) async {
        do { try await client.createSnapshot(of: vm, quiesce: quiesce); failure = nil }
        catch { failure = describe(error, "take the snapshot") }
        await loader.reload()
    }

    private func delete(_ targets: [VMSnapshot]) async {
        var failed = 0
        for s in targets {
            do { try await client.deleteSnapshot(s) }
            catch ZeusError.server(let status, _) where status == 404 { }
            catch ZeusError.server(let status, let message) where status == 403 {
                failure = message.isEmpty ? "Your role can't delete snapshots." : message; failed = -1; break
            }
            catch { failed += 1 }
        }
        if failed > 0 { failure = "Couldn't delete \(failed) of \(targets.count) snapshots." }
        selection.subtract(targets.map(\.id))
        await loader.reload()
    }
}

struct TakeSnapshotSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let onTake: (VM, Bool) async -> Void
    @State private var vmID: VM.ID?
    @State private var quiesce = false
    @State private var working = false

    private var vm: VM? { model.vms.first { $0.id == vmID } }

    var body: some View {
        Form {
            Picker("Machine", selection: $vmID) {
                Text("Choose…").tag(VM.ID?.none)
                ForEach(model.vms) { Text("\($0.name) (\($0.namespace))").tag(Optional($0.id)) }
            }
            Toggle("Freeze guest filesystems first", isOn: $quiesce)
            Text("Needs the guest agent running. Without it the snapshot is crash-consistent.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .formStyle(.grouped).frame(width: 420).padding()
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                Button("Take Snapshot") {
                    guard let vm else { return }
                    working = true
                    Task { await onTake(vm, quiesce); dismiss() }
                }
                .keyboardShortcut(.defaultAction).disabled(vm == nil || working)
            }.padding([.horizontal, .bottom])
        }
    }
}

/// Dismissible one-line error used under tables.
struct InlineError: View {
    let message: String
    let dismiss: () -> Void
    var body: some View {
        HStack {
            Label(message, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
            Spacer()
            Button("Dismiss", action: dismiss).buttonStyle(.borderless)
        }
        .padding(10).background(.bar)
    }
}

func describe(_ error: Error, _ doing: String) -> String {
    if case ZeusError.server(let status, let message) = error, status == 403 {
        return message.isEmpty ? "Your role can't \(doing)." : message
    }
    if case ZeusError.server(_, let message) = error, !message.isEmpty { return "Couldn't \(doing): \(message)" }
    return "Couldn't \(doing)."
}
