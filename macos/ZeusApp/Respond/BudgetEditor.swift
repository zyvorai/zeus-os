import SwiftUI
import ZeusKit

/// Create or edit a FinOps budget. The request body is the one the server's own dashboard sends
/// (`{name, scope, monthly_limit, thresholds, channel_ids, enabled}`); nothing is sent until Save.
struct BudgetEditor: View {
    @Environment(\.dismiss) private var dismiss
    let existing: BudgetRow?
    let currency: String
    let channels: [NotificationChannel]
    let onSave: (BudgetInput) async -> String?

    private enum Kind: String, CaseIterable, Identifiable { case namespace = "Namespace", tenant = "Tenant", cluster = "Cluster"; var id: Self { self } }

    @State private var name = ""
    @State private var kind: Kind = .namespace
    @State private var target = ""
    @State private var limit = ""
    @State private var thresholds = "50, 80, 100"
    @State private var channelIds: Set<String> = []
    @State private var enabled = true
    @State private var working = false
    @State private var failure: String?

    private var draft: (BudgetInput?, String?) {
        let scope: BudgetScope = switch kind {
        case .cluster: .cluster
        case .tenant: .tenant(target.trimmingCharacters(in: .whitespaces))
        case .namespace: .namespace(target.trimmingCharacters(in: .whitespaces))
        }
        guard let l = Double(limit.trimmingCharacters(in: .whitespaces)) else { return (nil, "Enter a monthly limit greater than 0.") }
        switch BudgetInput.parseThresholds(thresholds) {
        case .failure(let e): return (nil, e.message)
        case .success(let t):
            let b = BudgetInput(name: name.trimmingCharacters(in: .whitespaces), scope: scope, monthlyLimit: l,
                                thresholds: t, channelIds: channels.map(\.id).filter(channelIds.contains), enabled: enabled)
            if let m = b.validationMessage { return (nil, m) }
            return (b, nil)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(existing == nil ? "New Budget" : "Edit Budget").font(.headline).padding()
            Form {
                TextField("Name", text: $name)
                Picker("Scope", selection: $kind) { ForEach(Kind.allCases) { Text($0.rawValue).tag($0) } }
                if kind != .cluster { TextField(kind == .namespace ? "Namespace" : "Tenant id", text: $target) }
                TextField("Monthly limit (\(currency))", text: $limit)
                TextField("Alert thresholds, % of limit", text: $thresholds)
                Toggle("Enabled", isOn: $enabled)
                if !channels.isEmpty {
                    Section("Notify") {
                        ForEach(channels) { c in
                            Toggle(c.name ?? c.id, isOn: Binding(get: { channelIds.contains(c.id) },
                                                                set: { if $0 { channelIds.insert(c.id) } else { channelIds.remove(c.id) } }))
                        }
                    }
                }
                if let failure { Text(failure).foregroundStyle(.red).font(.callout) }
            }
            .formStyle(.grouped)
            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                Button("Save") {
                    guard let b = draft.0 else { return }
                    working = true; failure = nil
                    Task {
                        failure = await onSave(b)
                        working = false
                        if failure == nil { dismiss() }
                    }
                }
                .keyboardShortcut(.defaultAction).disabled(working || draft.0 == nil)
            }.padding()
        }
        .frame(width: 460)
        .onAppear(perform: load)
    }

    private func load() {
        guard let r = existing else { return }
        name = r.name
        if let s = BudgetScope(json: r.raw["scope"]) {
            switch s {
            case .cluster: kind = .cluster
            case .tenant(let n): kind = .tenant; target = n
            case .namespace(let n): kind = .namespace; target = n
            }
        }
        limit = r.limit.map { $0.formatted(.number.grouping(.never)) } ?? ""
        thresholds = (r.raw["thresholds"]?.array ?? []).compactMap { $0.number.map { String(Int($0)) } }.joined(separator: ", ")
        if thresholds.isEmpty { thresholds = "50, 80, 100" }
        channelIds = Set((r.raw["channel_ids"]?.array ?? []).compactMap(\.string))
        enabled = r.raw["enabled"]?.bool ?? true
    }
}
