import SwiftUI
import ZeusKit

/// Pause, clone, delete, cloud-init and guest-agent entry points for one machine.
/// Everything that changes state is hidden from read-only roles and asks first.
struct VMManageButtons: View {
    let vm: VM
    let client: ZeusClient
    let onDeleted: () -> Void
    @Environment(AppModel.self) private var model
    @State private var confirming: Confirm?
    @State private var cloning = false
    @State private var cloningFromSnapshot = false
    @State private var cloudInit = false
    @State private var guestAgent = false
    @State private var working = false

    private enum Confirm: Identifiable {
        case pause, resume, delete
        var id: Self { self }
    }

    private var isPaused: Bool { vm.status == "Paused" }
    private var canPause: Bool { vm.status == "Running" || isPaused }

    var body: some View {
        Group {
            if model.canWrite {
                Button(isPaused ? "Resume" : "Pause", systemImage: isPaused ? "play.circle" : "pause.circle") {
                    confirming = isPaused ? .resume : .pause
                }
                .disabled(!canPause || working)
                Menu("Clone", systemImage: "square.on.square") {
                    Button("Clone Machine…") { cloning = true }
                    Button("Clone from Snapshot…") { cloningFromSnapshot = true }
                }
                Button("Delete…", systemImage: "trash", role: .destructive) { confirming = .delete }
                    .disabled(working)
            }
            Button("Cloud-Init…", systemImage: "doc.text") { cloudInit = true }
            Button("Guest Agent…", systemImage: "person.crop.rectangle") { guestAgent = true }
        }
        .confirmationDialog(title, isPresented: Binding(get: { confirming != nil }, set: { if !$0 { confirming = nil } }),
                            titleVisibility: .visible) {
            switch confirming {
            case .pause: Button("Pause") { run("pause the machine") { try await client.pause(vm) } }
            case .resume: Button("Resume") { run("resume the machine") { try await client.unpause(vm) } }
            case .delete: Button("Delete", role: .destructive) {
                run("delete the machine") { try await client.deleteVM(vm); onDeleted() }
            }
            case nil: EmptyView()
            }
        } message: {
            switch confirming {
            case .pause: Text("The guest freezes in memory until you resume it.")
            case .resume: Text("The guest continues where it left off.")
            case .delete: Text("\(vm.name) and its disks are removed. This can't be undone.")
            case nil: EmptyView()
            }
        }
        .sheet(isPresented: $cloning) { CloneSheet(vm: vm, client: client, snapshot: nil) }
        .sheet(isPresented: $cloningFromSnapshot) { CloneSheet(vm: vm, client: client, snapshot: "") }
        .sheet(isPresented: $cloudInit) { CloudInitSheet(vm: vm, client: client) }
        .sheet(isPresented: $guestAgent) { GuestAgentSheet(vm: vm, client: client) }
    }

    private var title: String {
        switch confirming {
        case .pause: "Pause \(vm.name)?"
        case .resume: "Resume \(vm.name)?"
        case .delete: "Delete \(vm.name)?"
        case nil: ""
        }
    }

    private func run(_ doing: String, _ op: @escaping @MainActor () async throws -> Void) {
        working = true
        Task {
            do { try await op(); model.error = nil }
            catch { model.error = describe(error, doing) }
            _ = await model.refresh(quiet: true)
            working = false
        }
    }
}

/// Clone a machine, or (when `snapshot` is non-nil) create one from a snapshot of it.
struct CloneSheet: View {
    let vm: VM
    let client: ZeusClient
    let snapshot: String?
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var newName = ""
    @State private var cloneDisks = true
    @State private var start = false
    @State private var chosen = ""
    @State private var snapshots: [VMSnapshot]?
    @State private var working = false
    @State private var failure: String?

    private var fromSnapshot: Bool { snapshot != nil }

    /// Kubernetes names: lowercase letters, digits, '-' and '.', starting and ending alphanumeric.
    private var nameOK: Bool { newName.wholeMatch(of: /[a-z0-9]([-a-z0-9.]{0,251}[a-z0-9])?/) != nil && newName != vm.name }

    var body: some View {
        Form {
            Text(fromSnapshot ? "New machine from a snapshot of \(vm.name)" : "Clone \(vm.name)").font(.headline)
            TextField("New name", text: $newName, prompt: Text("\(vm.name)-copy"))
            if !newName.isEmpty && !nameOK {
                Text("Use lowercase letters, digits, '-' and '.', and a name different from the source.")
                    .font(.caption).foregroundStyle(.red)
            }
            if fromSnapshot {
                if let snapshots {
                    if snapshots.isEmpty { Text("This machine has no snapshots.").foregroundStyle(.secondary) }
                    else {
                        Picker("Snapshot", selection: $chosen) {
                            Text("Choose…").tag("")
                            ForEach(snapshots) { Text($0.name).tag($0.name) }
                        }
                    }
                } else { ProgressView().controlSize(.small) }
            } else {
                Toggle("Copy disks", isOn: $cloneDisks)
            }
            Toggle("Start after creating", isOn: $start)
            if let failure { Text(failure).foregroundStyle(.red).font(.callout) }
        }
        .formStyle(.grouped).frame(width: 440).padding()
        .task {
            guard fromSnapshot else { return }
            let all = (try? await client.snapshots()) ?? []
            snapshots = all.filter { $0.vmName == vm.name && $0.namespace == vm.namespace }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                Button(fromSnapshot ? "Create" : "Clone") { go() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!nameOK || working || (fromSnapshot && chosen.isEmpty))
            }.padding([.horizontal, .bottom])
        }
    }

    private func go() {
        working = true; failure = nil
        Task {
            do {
                if fromSnapshot { try await client.cloneFromSnapshot(vm, snapshot: chosen, as: newName, start: start) }
                else { try await client.clone(vm, as: newName, cloneDisks: cloneDisks, start: start) }
                _ = await model.refresh(quiet: true)
                dismiss()
            } catch {
                failure = describe(error, fromSnapshot ? "create the machine" : "clone the machine")
                working = false
            }
        }
    }
}

/// View, and for editors change, the machine's cloud-init user-data. Changes apply on next boot.
struct CloudInitSheet: View {
    let vm: VM
    let client: ZeusClient
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var original: String?
    @State private var text = ""
    @State private var loadError: String?
    @State private var failure: String?
    @State private var working = false
    @State private var confirmSave = false

    private var dirty: Bool { original != nil && text != original }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cloud-init for \(vm.name)").font(.headline)
            if let loadError {
                ContentUnavailableView("Couldn't load", systemImage: "exclamationmark.triangle", description: Text(loadError))
            } else if original == nil {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                TextEditor(text: $text)
                    .font(.body.monospaced())
                    .disabled(!model.canWrite)
                    .border(.separator)
                    .frame(minHeight: 280)
                Text(model.canWrite ? "User-data may contain secrets. Saved changes take effect the next time the machine boots."
                                    : "Your role is read-only. User-data may contain secrets.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            if let failure { Text(failure).foregroundStyle(.red).font(.callout) }
            HStack {
                Spacer()
                Button(model.canWrite ? "Cancel" : "Close", role: .cancel) { dismiss() }
                if model.canWrite {
                    Button("Save…") { confirmSave = true }
                        .keyboardShortcut(.defaultAction).disabled(!dirty || working)
                }
            }
        }
        .padding().frame(width: 640, height: 460)
        .task {
            do {
                let c = try await client.cloudInit(of: vm)
                original = c.userData ?? ""; text = original ?? ""
            } catch { loadError = describe(error, "load cloud-init") }
        }
        .confirmationDialog("Save cloud-init for \(vm.name)?", isPresented: $confirmSave, titleVisibility: .visible) {
            Button("Save") { save() }
        } message: { Text("Replaces the stored user-data. A restart is needed for it to apply.") }
    }

    private func save() {
        working = true; failure = nil
        Task {
            do { try await client.saveCloudInit(userData: text, for: vm); dismiss() }
            catch { failure = describe(error, "save cloud-init"); working = false }
        }
    }
}

/// Read-only guest-agent data. The server documents these responses as free-form, so they are shown
/// as an outline of whatever comes back rather than a fixed layout.
struct GuestAgentSheet: View {
    let vm: VM
    let client: ZeusClient
    @Environment(\.dismiss) private var dismiss
    @State private var view = GuestAgentView.osInfo
    @State private var result: Result<JSONValue, Failure>?

    private struct Failure: Error { let message: String }

    private func title(_ v: GuestAgentView) -> String {
        switch v {
        case .osInfo: "OS"; case .networkInterfaces: "Network"; case .processes: "Processes"
        case .users: "Users"; case .filesystems: "Filesystems"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Guest agent on \(vm.name)").font(.headline)
            Picker("View", selection: $view) {
                ForEach(GuestAgentView.allCases, id: \.self) { Text(title($0)).tag($0) }
            }.pickerStyle(.segmented).labelsHidden()
            Group {
                switch result {
                case nil: ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                case .failure(let f):
                    ContentUnavailableView("Not available", systemImage: "person.crop.rectangle.badge.xmark", description: Text(f.message))
                case .success(let v):
                    List { JSONOutline(value: v) }
                }
            }
            .frame(maxHeight: .infinity)
            HStack { Spacer(); Button("Close") { dismiss() }.keyboardShortcut(.defaultAction) }
        }
        .padding().frame(width: 560, height: 440)
        .task(id: view) {
            result = nil
            do { result = .success(try await client.guestAgent(view, of: vm)) }
            catch is CancellationError { }
            catch ZeusError.server(let status, let message) where status == 500 || status == 503 {
                // The server reports "guest agent not connected" this way; its text says why.
                result = .failure(Failure(message: message.isEmpty ? "The guest agent isn't responding." : message))
            }
            catch { result = .failure(Failure(message: describe(error, "read guest-agent data"))) }
        }
    }
}

/// Generic outline for free-form JSON: scalars as rows, containers as disclosure groups.
struct JSONOutline: View {
    let value: JSONValue
    var label: String?

    var body: some View {
        switch value {
        case .object(let o):
            ForEach(o.keys.sorted(), id: \.self) { k in JSONOutline(value: o[k] ?? .null, label: k) }
        case .array(let a):
            if a.isEmpty { row("none") }
            else {
                DisclosureGroup("\(label ?? "Items") (\(a.count))") {
                    ForEach(a.indices, id: \.self) { i in
                        if a[i].object != nil || a[i].array != nil {
                            DisclosureGroup("#\(i + 1)") { JSONOutline(value: a[i]) }
                        } else { JSONOutline(value: a[i], label: "#\(i + 1)") }
                    }
                }
            }
        default: row(value.string ?? "—")
        }
    }

    @ViewBuilder private func row(_ text: String) -> some View {
        if let label { LabeledContent(label) { Text(text).textSelection(.enabled) } }
        else { Text(text).textSelection(.enabled) }
    }
}
