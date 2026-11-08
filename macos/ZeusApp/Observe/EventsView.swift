import SwiftUI
import ZeusKit

struct EventsData: Sendable { let anomalies: [EventAnomaly]; let timeline: [TimelineEvent]; let incidents: [EventRecord] }

/// Event analysis: detected anomalies, the event timeline and correlated incidents.
struct EventsView: View {
    let client: ZeusClient
    @State private var loader: Loader<EventsData>
    @State private var tab = Tab.anomalies
    @State private var search = ""

    enum Tab: String, CaseIterable, Identifiable { case anomalies = "Anomalies", timeline = "Timeline", incidents = "Incidents"; var id: String { rawValue } }

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader {
            async let a = client.eventAnomalies()
            async let t = client.eventTimeline()
            async let i = (try? await client.eventIncidents()) ?? []
            return try await EventsData(anomalies: a, timeline: t, incidents: i)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { data in
            VStack(spacing: 0) {
                Picker("View", selection: $tab) { ForEach(Tab.allCases) { Text($0.rawValue).tag($0) } }
                    .pickerStyle(.segmented).labelsHidden().frame(width: 320).padding()
                switch tab {
                case .anomalies: anomalies(data.anomalies)
                case .timeline: timeline(data.timeline)
                case .incidents: incidents(data.incidents)
                }
            }
        }
        .navigationTitle("Events")
        .searchable(text: $search, prompt: "Search")
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }

    private func matches(_ parts: [String?]) -> Bool {
        search.isEmpty || parts.contains { ($0 ?? "").localizedCaseInsensitiveContains(search) }
    }

    @ViewBuilder private func anomalies(_ all: [EventAnomaly]) -> some View {
        let rows = all.filter { matches([$0.anomalyType, $0.description, $0.severity]) }
        if rows.isEmpty { ContentUnavailableView(all.isEmpty ? "No anomalies" : "No matches", systemImage: "waveform.path.ecg") } else {
            Table(rows) {
                TableColumn("Detected") { a in if let d = a.date { Text(d, format: .dateTime.month().day().hour().minute()) } else { Text("") } }.width(min: 90, ideal: 110)
                TableColumn("Severity") { Text($0.severity ?? "—") }.width(70)
                TableColumn("Type") { Text($0.anomalyType ?? "—") }
                TableColumn("Description") { Text($0.description ?? "").lineLimit(2).help($0.description ?? "") }
                TableColumn("Expected") { Text($0.expectedValue.map { $0.formatted(.number.precision(.fractionLength(0...2))) } ?? "—") }.width(70)
                TableColumn("Actual") { Text($0.actualValue.map { $0.formatted(.number.precision(.fractionLength(0...2))) } ?? "—") }.width(70)
                TableColumn("Deviation") { Text($0.deviationPercent.map { "\($0.formatted(.number.precision(.fractionLength(0...1))))%" } ?? "—") }.width(80)
                TableColumn("Confidence") { Text($0.confidenceScore.map { $0.formatted(.percent.precision(.fractionLength(0))) } ?? "—") }.width(min: 80, ideal: 90)
            }
        }
    }

    @ViewBuilder private func timeline(_ all: [TimelineEvent]) -> some View {
        let rows = all.filter { matches([$0.reason, $0.resource, $0.namespace, $0.message]) }
        if rows.isEmpty { ContentUnavailableView(all.isEmpty ? "No events" : "No matches", systemImage: "clock") } else {
            Table(rows) {
                TableColumn("Time") { e in if let d = e.date { Text(d, format: .dateTime.month().day().hour().minute()) } else { Text("") } }.width(min: 90, ideal: 110)
                TableColumn("Type") { e in Text(e.eventType ?? "—").foregroundStyle(e.eventType == "Warning" ? .orange : .primary) }.width(70)
                TableColumn("Reason") { Text($0.reason ?? "—") }
                TableColumn("Resource") { Text($0.resource ?? "—") }
                TableColumn("Namespace") { Text($0.namespace ?? "—") }
                TableColumn("Message") { Text($0.message ?? "").lineLimit(2).help($0.message ?? "") }
            }
        }
    }

    @ViewBuilder private func incidents(_ all: [EventRecord]) -> some View {
        if all.isEmpty {
            ContentUnavailableView("No incidents", systemImage: "checkmark.circle", description: Text("No correlated incidents right now."))
        } else {
            Table(all) {
                TableColumn("ID") { Text($0.id) }
                TableColumn("Title") { Text($0.string("title") ?? $0.string("description") ?? "—") }
                TableColumn("Severity") { Text($0.string("severity") ?? "—") }
                TableColumn("Status") { Text($0.string("status") ?? "—") }
            }
        }
    }
}
