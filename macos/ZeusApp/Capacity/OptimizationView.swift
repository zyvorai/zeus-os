import SwiftUI
import ZeusKit

extension OptimizationRecommendation {
    var savings: Double { estimatedSavingsPerMonth ?? 0 }
}

struct OptimizationView: View {
    let client: ZeusClient
    @State private var loader: Loader<[OptimizationRecommendation]>
    @State private var search = ""
    @State private var selection: OptimizationRecommendation.ID?
    @State private var sort = [KeyPathComparator(\OptimizationRecommendation.savings, order: .reverse)]

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader { try await client.optimizationRecommendations() })
    }

    var body: some View {
        LoadStateView(loader: loader) { all in
            let rows = all.filter { r in
                search.isEmpty || [r.title, r.resourceName, r.namespace].contains { ($0 ?? "").localizedCaseInsensitiveContains(search) }
            }.sorted(using: sort)
            if all.isEmpty {
                ContentUnavailableView("No recommendations", systemImage: "lightbulb", description: Text("Nothing to optimise right now."))
            } else {
                VStack(spacing: 0) {
                    Text("Savings are estimates from your configured unit prices. Recommendations are advice only; nothing here changes a workload.")
                        .font(.callout).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading).padding([.horizontal, .top])
                    Table(rows, selection: $selection, sortOrder: $sort) {
                        TableColumn("Recommendation") { Text($0.title ?? $0.id) }
                        TableColumn("Type") { Text(($0.recommendationType ?? "—").replacing("_", with: " ")) }
                        TableColumn("Severity") { Text($0.severity?.capitalized ?? "—") }
                        TableColumn("Saves per month", value: \.savings) { Text($0.savings, format: .currency(code: "USD")).monospacedDigit() }
                        TableColumn("Status") { Text($0.status?.capitalized ?? "—") }
                    }
                    if let r = all.first(where: { $0.id == selection }) { detail(r) }
                }
            }
        }
        .navigationTitle("Optimization")
        .searchable(text: $search, prompt: "Search recommendations")
        .task { loader.start() }
        .onDisappear { loader.stop() }
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
    }

    private func detail(_ r: OptimizationRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(r.description ?? "").font(.callout)
            Text("Current: \(flat(r.currentConfig))   Recommended: \(flat(r.recommendedConfig))")
                .font(.caption).foregroundStyle(.secondary).monospaced()
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(10).background(.bar)
    }

    private func flat(_ v: JSONValue?) -> String {
        guard let o = v?.object, !o.isEmpty else { return "—" }
        return o.keys.sorted().map { "\($0)=\(o[$0]?.string ?? "?")" }.joined(separator: ", ")
    }
}
