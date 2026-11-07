import SwiftUI
import Charts
import ZeusKit

extension Destination {
    static let tailObserve: [Destination] = [
        Destination("Metrics & Dashboards", symbol: "chart.xyaxis.line", group: "Observe") {
            TailScreen(client: $0, title: "Metrics & Dashboards", endpoints: TailCatalog.metrics) },
        Destination("Activity & Health", symbol: "heart.text.square", group: "Observe") {
            TailScreen(client: $0, title: "Activity & Health", endpoints: TailCatalog.activity, withHeatmap: true) },
        Destination("Databases", symbol: "cylinder.split.1x2", group: "Observe") {
            TailScreen(client: $0, title: "Databases", endpoints: TailCatalog.databases) },
        Destination("Testing", symbol: "gauge.with.needle", group: "Observe") {
            TailScreen(client: $0, title: "Testing", endpoints: TailCatalog.testing) },
        Destination("Operations", symbol: "wrench.and.screwdriver", group: "Observe") {
            TailScreen(client: $0, title: "Operations", endpoints: TailCatalog.operations) },
    ]
}

/// A read-only screen over a group of free-form endpoints: a menu picks the endpoint, a table shows it.
struct TailScreen: View {
    let client: ZeusClient
    let title: String
    let endpoints: [TailEndpoint]
    let withHeatmap: Bool
    @State private var showHeatmap: Bool
    @State private var selected: TailEndpoint

    init(client: ZeusClient, title: String, endpoints: [TailEndpoint], withHeatmap: Bool = false) {
        self.client = client; self.title = title; self.endpoints = endpoints; self.withHeatmap = withHeatmap
        _showHeatmap = State(initialValue: withHeatmap)
        _selected = State(initialValue: endpoints[0])
    }

    private var groups: [String] { endpoints.map(\.group).reduce(into: []) { if !$0.contains($1) { $0.append($1) } } }

    var body: some View {
        Group {
            if showHeatmap { HeatmapView(client: client) }
            else { TailEndpointView(client: client, endpoint: selected).id(selected.id) }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem {
                Picker("View", selection: Binding(
                    get: { showHeatmap ? "heatmap" : selected.id },
                    set: { id in
                        if id == "heatmap" { showHeatmap = true }
                        else if let e = endpoints.first(where: { $0.id == id }) { selected = e; showHeatmap = false }
                    })) {
                    if withHeatmap { Text("Heatmap").tag("heatmap") }
                    ForEach(groups, id: \.self) { g in
                        Section(g) { ForEach(endpoints.filter { $0.group == g }) { Text($0.title).tag($0.id) } }
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
}

struct TailEndpointView: View {
    let endpoint: TailEndpoint
    @State private var loader: Loader<TailPayload>

    init(client: ZeusClient, endpoint: TailEndpoint) {
        self.endpoint = endpoint
        _loader = State(initialValue: Loader { try await client.tail(endpoint) })
    }

    var body: some View {
        LoadStateView(loader: loader) { payload in
            switch payload {
            case .rows(let rows, let summary):
                VStack(spacing: 0) {
                    if !summary.isEmpty { SummaryStrip(summary: summary) }
                    JSONTable(rows: rows, emptyTitle: "No \(endpoint.title.lowercased())",
                              emptyDescription: "The server returned nothing for \(endpoint.title).")
                }
            case .record(let value):
                if value.object?.isEmpty == false || value.array?.isEmpty == false {
                    List { JSONOutline(value: value) }
                } else {
                    ContentUnavailableView("No \(endpoint.title.lowercased())", systemImage: "tray",
                                           description: Text("The server returned nothing for \(endpoint.title)."))
                }
            }
        }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}

private struct SummaryStrip: View {
    let summary: [String: JSONValue]
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(summary.keys.sorted(), id: \.self) { k in
                        VStack(alignment: .leading) {
                            Text(k.replacing("_", with: " ").capitalized).font(.caption).foregroundStyle(.secondary)
                            Text(summary[k]?.string ?? "—").monospacedDigit()
                        }
                    }
                }.padding(.horizontal).padding(.vertical, 8)
            }
            Divider()
        }
    }
}

/// Machines against nodes, coloured by one metric at a time (units differ per metric, so one shared scale would mislead).
/// Hover shows the exact values; the table below lists the same cells.
struct HeatmapView: View {
    @State private var loader: Loader<Heatmap>
    @State private var metric = "cpu"
    @State private var picked: String?

    init(client: ZeusClient) {
        _loader = State(initialValue: Loader { try await client.heatmap() })
    }

    var body: some View {
        LoadStateView(loader: loader) { map in
            if map.cells.isEmpty {
                ContentUnavailableView("No machines", systemImage: "square.grid.3x3", description: Text("The heatmap has no cells yet."))
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Picker("Metric", selection: $metric) {
                        ForEach(map.metrics, id: \.self) { Text($0.capitalized).tag($0) }
                    }.pickerStyle(.segmented).labelsHidden().padding(.horizontal)
                    Chart(map.cells) { c in
                        RectangleMark(x: .value("Node", c.node ?? "unscheduled"), y: .value("Machine", c.vmName))
                            .foregroundStyle(by: .value(metric.capitalized, c.value(metric)))
                        if picked == c.vmName {
                            RuleMark(y: .value("Machine", c.vmName)).foregroundStyle(.secondary.opacity(0.4))
                                .annotation(position: .trailing, overflowResolution: .init(x: .fit, y: .disabled)) {
                                    VStack(alignment: .leading) {
                                        Text(c.vmName).font(.caption.weight(.semibold))
                                        ForEach(map.metrics, id: \.self) {
                                            Text("\($0.capitalized): \(c.value($0), format: .number.precision(.fractionLength(1)))")
                                                .font(.caption2).monospacedDigit()
                                        }
                                        Text("Health \(c.healthScore, format: .number.precision(.fractionLength(0)))")
                                            .font(.caption2)
                                    }.padding(6).background(.regularMaterial, in: .rect(cornerRadius: 6))
                                }
                        }
                    }
                    .chartYSelection(value: $picked)
                    .chartForegroundStyleScale(range: Gradient(colors: [.blue.opacity(0.25), .blue]))
                    .frame(height: max(120, CGFloat(map.cells.count) * 28 + 60)).padding(.horizontal)
                    .accessibilityLabel("Heatmap of \(metric) usage per machine and node")
                    Divider()
                    Table(map.cells) {
                        TableColumn("Machine", value: \.vmName)
                        TableColumn("Node") { Text($0.node ?? "—") }
                        TableColumn("Status", value: \.status)
                        TableColumn("CPU") { Text($0.cpuUsage, format: .number.precision(.fractionLength(1))) }
                        TableColumn("Memory") { Text($0.memoryUsage, format: .number.precision(.fractionLength(1))) }
                        TableColumn("Disk") { Text($0.diskUsage, format: .number.precision(.fractionLength(1))) }
                        TableColumn("Network") { Text($0.networkUsage, format: .number.precision(.fractionLength(1))) }
                        TableColumn("Health") { Text($0.healthScore, format: .number.precision(.fractionLength(0))) }
                    }
                }
            }
        }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}
