import SwiftUI
import ZeusKit

/// APM service list. Latency and error rate need PacketWolf; when it is absent the server says so and we show that, not zeros.
struct APMView: View {
    let client: ZeusClient
    @State private var loader: Loader<[APMService]>
    @State private var search = ""

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader { try await client.apmServices() })
    }

    var body: some View {
        LoadStateView(loader: loader) { all in
            let rows = all.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) || ($0.environment ?? "").localizedCaseInsensitiveContains(search) }
            VStack(spacing: 0) {
                if let reason = all.compactMap(\.latencyReason).first {
                    Label(reason, systemImage: "info.circle").font(.callout).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading).padding([.horizontal, .top])
                }
                if rows.isEmpty {
                    ContentUnavailableView(all.isEmpty ? "No services" : "No matches", systemImage: "speedometer")
                } else {
                    Table(rows) {
                        TableColumn("Service", value: \.name)
                        TableColumn("Namespace") { Text($0.environment ?? "—") }
                        TableColumn("Instances") { Text($0.instanceCount.map(String.init) ?? "—") }.width(70)
                        TableColumn("Restarts") { Text($0.restartsPerPod.map { $0.formatted(.number.precision(.fractionLength(0...1))) } ?? "—") }.width(70)
                        TableColumn("Req/min") { Text(num($0.requestsPerMinute)) }.width(70)
                        TableColumn("Errors") { Text($0.errorRate.map { "\(num($0))%" } ?? "—") }.width(70)
                        TableColumn("p95 ms") { Text(num($0.p95LatencyMs)) }.width(70)
                        TableColumn("p99 ms") { Text(num($0.p99LatencyMs)) }.width(70)
                        TableColumn("Apdex") { Text(num($0.apdexScore)) }.width(60)
                    }
                }
            }
        }
        .navigationTitle("APM")
        .searchable(text: $search, prompt: "Search services")
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }

    private func num(_ v: Double?) -> String { v.map { $0.formatted(.number.precision(.fractionLength(0...2))) } ?? "—" }
}
