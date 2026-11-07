import SwiftUI
import ZeusKit

extension AppModel {
    /// Runs one power action over several machines through `/vms/bulk` and returns a message to show,
    /// or nil when everything succeeded. Partial failure names the machines that failed.
    func bulkPerform(_ action: VMAction, on targets: [VM]) async -> String? {
        let todo = targets.filter { !busy.contains($0.id) }
        guard canWrite, let client, !todo.isEmpty else { return nil }
        busy.formUnion(todo.map(\.id))
        defer { busy.subtract(todo.map(\.id)) }
        defer { Task { _ = await self.refresh(quiet: true) } }
        do {
            let r = try await client.bulk(action, on: todo)
            return Self.bulkSummary(action, r, requested: todo.count)
        } catch ZeusError.unauthorized {
            signOut(forget: false); error = "Session expired. Sign in again."
            return nil
        } catch {
            return describe(error, "\(action.rawValue) these machines")
        }
    }

    static func bulkSummary(_ action: VMAction, _ r: BulkActionResponse, requested: Int) -> String? {
        let bad = r.failures
        guard !bad.isEmpty else { return nil }
        let names = bad.prefix(5).map { $0.message.isEmpty ? $0.name : "\($0.name) (\($0.message))" }.joined(separator: ", ")
        let more = bad.count > 5 ? " and \(bad.count - 5) more" : ""
        return bad.count == requested ? "Couldn't \(action.rawValue) any of the \(requested) machines: \(names)\(more)."
                                      : "Couldn't \(action.rawValue) \(bad.count) of \(requested) machines: \(names)\(more)."
    }
}

/// Toolbar items, bulk-action confirmation, and the New Machine sheet for the Machines table.
struct MachineWriteTools: ViewModifier {
    let selected: [VM]
    @Environment(AppModel.self) private var model
    @State private var creating = false
    @State private var bulk: VMAction?
    @State private var failure: String?

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup {
                    if model.canWrite {
                        Button("New Machine", systemImage: "plus") { creating = true }
                            .help("Create a machine")
                        if selected.count > 1 {
                            ForEach(VMAction.allCases, id: \.self) { action in
                                Button("\(action.title) \(selected.count)", systemImage: symbol(action)) { bulk = action }
                                    .disabled(!selected.contains { action.isAvailable(for: $0.status) })
                                    .help("\(action.title) the selected machines")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $creating) {
                if let client = model.client { NewMachineSheet(client: client) }
            }
            .confirmationDialog(bulk.map { "\($0.title) \(targets($0).count) machines?" } ?? "",
                                isPresented: Binding(get: { bulk != nil }, set: { if !$0 { bulk = nil } }),
                                titleVisibility: .visible) {
                if let action = bulk {
                    Button("\(action.title) \(targets(action).count)", role: action == .start ? nil : .destructive) {
                        let list = targets(action)
                        Task { failure = await model.bulkPerform(action, on: list) }
                    }
                }
            } message: {
                if let action = bulk { Text(listing(targets(action))) }
            }
            .safeAreaInset(edge: .bottom) { if let failure { InlineError(message: failure) { self.failure = nil } } }
    }

    /// Only machines the action applies to are sent; the others are left alone.
    private func targets(_ action: VMAction) -> [VM] { selected.filter { action.isAvailable(for: $0.status) } }

    private func listing(_ vms: [VM]) -> String {
        let names = vms.prefix(8).map(\.name).joined(separator: ", ")
        return vms.count > 8 ? "\(names) and \(vms.count - 8) more." : "\(names)."
    }

    private func symbol(_ a: VMAction) -> String {
        switch a { case .start: "play.fill"; case .stop: "stop.fill"; case .restart: "arrow.clockwise" }
    }
}

/// View and edit a machine's labels (shown as tags). Adding is immediate; removing asks first.
struct VMLabelsSection: View {
    let vm: VM
    @Environment(AppModel.self) private var model
    @State private var key = ""
    @State private var value = ""
    @State private var removing: String?
    @State private var working = false
    @State private var failure: String?

    private var labels: [(key: String, value: String)] { VMLabels.parse(vm.tags) }
    private var inputOK: Bool { VMLabels.validKey(key) && VMLabels.validValue(value) }

    var body: some View {
        Section("Labels") {
            if labels.isEmpty { Text("No labels").foregroundStyle(.secondary) }
            ForEach(labels, id: \.key) { l in
                HStack {
                    Text(l.value.isEmpty ? l.key : "\(l.key)=\(l.value)").textSelection(.enabled)
                    Spacer()
                    if model.canWrite {
                        Button("Remove", systemImage: "minus.circle") { removing = l.key }
                            .labelStyle(.iconOnly).buttonStyle(.borderless).disabled(working)
                    }
                }
            }
            if model.canWrite {
                HStack {
                    TextField("Key", text: $key).textFieldStyle(.roundedBorder)
                    TextField("Value", text: $value).textFieldStyle(.roundedBorder)
                    Button("Add") { add() }.disabled(!inputOK || working)
                }
                if !key.isEmpty && !inputOK {
                    Text("Keys and values may use letters, digits, '-', '_' and '.'.").font(.caption).foregroundStyle(.red)
                }
            }
            if let failure { Text(failure).font(.callout).foregroundStyle(.red) }
        }
        .confirmationDialog("Remove label \(removing ?? "") from \(vm.name)?",
                            isPresented: Binding(get: { removing != nil }, set: { if !$0 { removing = nil } }),
                            titleVisibility: .visible) {
            if let k = removing { Button("Remove", role: .destructive) { apply(set: [:], remove: [k], "remove the label") } }
        }
    }

    private func add() { apply(set: [key: value], remove: [], "add the label") { key = ""; value = "" } }

    private func apply(set: [String: String], remove: [String], _ doing: String, done: @escaping () -> Void = {}) {
        guard let client = model.client else { return }
        working = true; failure = nil
        Task {
            do { try await client.applyLabels(set: set, remove: remove, on: [vm]); done() }
            catch ZeusError.unauthorized { model.signOut(forget: false); model.error = "Session expired. Sign in again." }
            catch { failure = describe(error, doing) }
            _ = await model.refresh(quiet: true)
            working = false
        }
    }
}
