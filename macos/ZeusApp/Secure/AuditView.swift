import SwiftUI
import ZeusKit

struct AuditData: Sendable { let events: [AuditEvent]; let stats: AuditStats? }

struct AuditView: View {
    let client: ZeusClient
    @State private var loader: Loader<AuditData>
    @State private var search = ""
    @State private var onlyWarnings = false
    @State private var sort = [KeyPathComparator(\AuditEvent.timestamp, order: .reverse)]

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader {
            async let e = client.auditEvents()
            async let s = try? client.auditStats()
            return try await AuditData(events: e, stats: await s)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { data in
            let rows = data.events
                .filter { !onlyWarnings || $0.isWarning }
                .filter { search.isEmpty || [$0.action, $0.resourceName ?? "", $0.namespace ?? "", $0.user ?? "", $0.details ?? ""]
                    .contains { $0.localizedCaseInsensitiveContains(search) } }
                .sorted(using: sort)
            VStack(spacing: 0) {
                if let s = data.stats {
                    Text("\(s.totalEvents) events · \(s.last24h) in the last 24 hours · \(s.last7d) in 7 days")
                        .font(.callout).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading).padding([.horizontal, .top])
                }
                if data.events.isEmpty {
                    ContentUnavailableView("No events", systemImage: "list.bullet.clipboard",
                                           description: Text("Nothing recorded for this account yet."))
                } else if rows.isEmpty {
                    ContentUnavailableView.search(text: search)
                } else {
                    Table(rows, sortOrder: $sort) {
                        TableColumn("Time", value: \.timestamp) { e in
                            if let d = e.date { Text(d, format: .dateTime.month().day().hour().minute()) } else { Text(e.timestamp) }
                        }.width(min: 90, ideal: 110)
                        TableColumn("Result") { e in
                            Label(e.result ?? "—", systemImage: e.isWarning ? "exclamationmark.triangle.fill" : "checkmark.circle")
                                .foregroundStyle(e.isWarning ? .orange : .primary)
                        }.width(min: 80, ideal: 90)
                        TableColumn("Action", value: \.action)
                        TableColumn("Resource") { Text([$0.resourceType, $0.resourceName].compactMap { $0 }.joined(separator: " ")) }
                        TableColumn("Namespace") { Text($0.namespace ?? "—") }
                        TableColumn("By") { Text($0.user ?? "—") }
                        TableColumn("Details") { Text($0.details ?? "").lineLimit(1).help($0.details ?? "") }
                        TableColumn("×") { Text($0.count.map(String.init) ?? "") }.width(50)
                    }
                }
            }
        }
        .navigationTitle("Audit")
        .searchable(text: $search, prompt: "Search events")
        .toolbar {
            ToolbarItem { Toggle("Warnings only", systemImage: "exclamationmark.triangle", isOn: $onlyWarnings) }
            ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } }
        }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}
