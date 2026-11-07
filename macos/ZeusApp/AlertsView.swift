import SwiftUI
import ZeusKit

struct AlertsView: View {
    @Environment(AppModel.self) private var model
    @State private var search = ""
    @State private var sort = [KeyPathComparator(\FiredAlert.severityRank), KeyPathComparator(\FiredAlert.firedAt, order: .reverse)]

    private var reported: Int { model.alerts?.totalActive ?? 0 }

    private var rows: [FiredAlert] {
        (model.alertList ?? [])
            .filter { search.isEmpty || [$0.ruleName, $0.resourceName, $0.namespace]
                .contains { $0.localizedCaseInsensitiveContains(search) } }
            .sorted(using: sort)
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
        Table(rows, sortOrder: $sort) {
            TableColumn("Severity", value: \.severityRank) { a in
                SeverityLabel(severity: a.severity)       // icon + text, never color alone
            }
            .width(min: 90, ideal: 100)
            TableColumn("Rule", value: \.ruleName)
            TableColumn("Resource", value: \.resourceName)
            TableColumn("Namespace", value: \.namespace)
            TableColumn("Value") { a in
                Text("\(a.currentValue.formatted(.number.precision(.fractionLength(0...2)))) / \(a.thresholdValue.formatted(.number.precision(.fractionLength(0...2))))")
                    .monospacedDigit()
            }
            TableColumn("Seen") { Text("\($0.count)×").monospacedDigit() }.width(50)
            TableColumn("Fired", value: \.firedAt) { Text($0.firedAt, style: .relative) }
            TableColumn("State") { a in
                Text(a.acknowledged ? "Acknowledged" : "Open")
                    .foregroundStyle(a.acknowledged ? .secondary : .primary)
            }
        }
        .searchable(text: $search)
        .overlay { if rows.isEmpty { ContentUnavailableView.search(text: search) } }
    }
}

struct SeverityLabel: View {
    let severity: String

    var body: some View {
        switch severity.lowercased() {
        case "critical": Label("Critical", systemImage: "exclamationmark.octagon.fill").foregroundStyle(.red)
        case "warning": Label("Warning", systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
        case "info": Label("Info", systemImage: "info.circle.fill").foregroundStyle(.blue)
        default: Label(severity.capitalized, systemImage: "questionmark.circle").foregroundStyle(.secondary)
        }
    }
}
