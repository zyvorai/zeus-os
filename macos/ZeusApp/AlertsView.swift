import SwiftUI
import ZeusKit

struct AlertsView: View {
    @Environment(AppModel.self) private var model
    @State private var search = ""
    @State private var selection = Set<FiredAlert.ID>()
    @State private var confirming: [FiredAlert]?
    @State private var resolving: [FiredAlert]?
    @State private var sort = [KeyPathComparator(\FiredAlert.severityRank), KeyPathComparator(\FiredAlert.firedAt, order: .reverse)]

    private var reported: Int { model.alerts?.totalActive ?? 0 }

    private var rows: [FiredAlert] {
        (model.alertList ?? [])
            .filter { search.isEmpty || [$0.ruleName, $0.resourceName, $0.namespace]
                .contains { $0.localizedCaseInsensitiveContains(search) } }
            .sorted(using: sort)
    }

    /// Selected alerts that can still be acknowledged.
    private func eligible(_ ids: Set<FiredAlert.ID>) -> [FiredAlert] {
        (model.alertList ?? []).filter { ids.contains($0.id) && !$0.acknowledged }
    }

    private func resolvable(_ ids: Set<FiredAlert.ID>) -> [FiredAlert] {
        (model.alertList ?? []).filter { ids.contains($0.id) }
    }

    /// One alert goes straight through; several ask first because there is no way to undo it.
    private func request(_ alerts: [FiredAlert]) {
        guard !alerts.isEmpty else { return }
        if alerts.count == 1 { Task { await model.acknowledge(alerts) } } else { confirming = alerts }
    }

    var body: some View {
        Group {
            switch model.alertList {
            case nil:
                // Never claim "none" when we simply don't know.
                ContentUnavailableView("Couldn't load alerts", systemImage: "exclamationmark.triangle",
                    description: Text(reported > 0 ? "The server reports \(reported) active. Try again in a moment."
                                                   : "Try again in a moment."))
            case let list? where list.isEmpty && reported > 0:
                // Counts are server-wide; the list is filtered to what this account may see.
                ContentUnavailableView("\(reported) active alert\(reported == 1 ? "" : "s")",
                    systemImage: "bell.badge",
                    description: Text("They're outside the namespaces this account can see."))
            case let list? where list.isEmpty:
                ContentUnavailableView("No active alerts", systemImage: "checkmark.seal")
            default:
                table
            }
        }
        .navigationTitle("Alerts")
    }

    private var table: some View {
        Table(rows, selection: $selection, sortOrder: $sort) {
            TableColumn("Severity", value: \.severityRank) { a in
                SeverityLabel(severity: a.severity)       // icon + text, never color alone
            }
            .width(min: 100, ideal: 110)
            TableColumn("Rule", value: \.ruleName).width(min: 140, ideal: 220)
            TableColumn("Resource", value: \.resourceName).width(min: 110, ideal: 150)
            TableColumn("Namespace", value: \.namespace).width(min: 90, ideal: 120)
            TableColumn("Value / Limit") { a in
                Text("\(a.currentValue.formatted(.number.precision(.fractionLength(0...2)))) / \(a.thresholdValue.formatted(.number.precision(.fractionLength(0...2))))")
                    .monospacedDigit()
            }
            .width(min: 90, ideal: 110)
            TableColumn("Seen") { Text("\($0.count)×").monospacedDigit() }.width(min: 44, ideal: 54)
            TableColumn("Fired", value: \.firedAt) { Text($0.firedAt, style: .relative) }
                .width(min: 100, ideal: 130)
            TableColumn("State") { a in
                if model.busyAlerts.contains(a.id) { ProgressView().controlSize(.small) }
                else if a.acknowledged {
                    Label("Acknowledged", systemImage: "checkmark.circle").foregroundStyle(.secondary)
                } else {
                    Label("Open", systemImage: "circle.dotted")
                }
            }
            .width(min: 110, ideal: 130)
        }
        .searchable(text: $search)
        .overlay { if rows.isEmpty { ContentUnavailableView.search(text: search) } }
        .contextMenu(forSelectionType: FiredAlert.ID.self) { ids in
            let targets = eligible(ids)
            Button(targets.count > 1 ? "Acknowledge \(targets.count) Alerts" : "Acknowledge",
                   systemImage: "checkmark.circle") { request(targets) }
                .disabled(!model.canWrite || targets.isEmpty)
            let open = resolvable(ids)
            Button(open.count > 1 ? "Resolve \(open.count) Alerts…" : "Resolve…", systemImage: "checkmark.seal") { resolving = open }
                .disabled(!model.canWrite || open.isEmpty)
        }
        .toolbar {
            ToolbarItem {
                let open = resolvable(selection)
                Button("Resolve", systemImage: "checkmark.seal") { resolving = open }
                    .disabled(!model.canWrite || open.isEmpty || open.contains { model.busyAlerts.contains($0.id) })
                    .help(model.canWrite ? "Resolve the selected alerts" : "Your role is read-only")
            }
            ToolbarItem {
                let targets = eligible(selection)
                Button("Acknowledge", systemImage: "checkmark.circle") { request(targets) }
                    .disabled(!model.canWrite || targets.isEmpty || targets.contains { model.busyAlerts.contains($0.id) })
                    .help(model.canWrite ? "Acknowledge the selected alerts" : "Your role is read-only")
            }
        }
        .confirmationDialog("Acknowledge \(confirming?.count ?? 0) alerts?",
                            isPresented: Binding(get: { confirming != nil }, set: { if !$0 { confirming = nil } }),
                            titleVisibility: .visible) {
            if let c = confirming { Button("Acknowledge \(c.count)") { Task { await model.acknowledge(c) } } }
        } message: { Text("This can't be undone from here.") }
        .confirmationDialog(resolving.map { $0.count == 1 ? "Resolve \($0[0].ruleName) on \($0[0].resourceName)?" : "Resolve \($0.count) alerts?" } ?? "",
                            isPresented: Binding(get: { resolving != nil }, set: { if !$0 { resolving = nil } }),
                            titleVisibility: .visible) {
            if let r = resolving { Button("Resolve \(r.count)") { Task { await model.resolve(r) } } }
        } message: { Text("Marks the alert resolved on the server. This can't be undone from here.") }
        .safeAreaInset(edge: .bottom) {
            if let e = model.alertError { Text(e).font(.callout).foregroundStyle(.red).padding(8) }
        }
        .onChange(of: model.alertList) { _, list in      // drop selections for alerts that went away
            selection.formIntersection(Set((list ?? []).map(\.id)))
        }
    }
}

struct SeverityLabel: View {
    let severity: String

    var body: some View {
        // Icon is tinted, text stays primary (better contrast in dark mode); fixed icon width keeps labels aligned.
        switch severity.lowercased() {
        case "critical": label("Critical", "exclamationmark.octagon.fill", .red)
        case "warning": label("Warning", "exclamationmark.triangle.fill", .orange)
        case "info": label("Info", "info.circle.fill", .blue)
        default: label(severity.capitalized, "questionmark.circle", .secondary)
        }
    }

    private func label(_ title: String, _ symbol: String, _ tint: Color) -> some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: symbol).foregroundStyle(tint).frame(width: 16)
        }
    }
}
