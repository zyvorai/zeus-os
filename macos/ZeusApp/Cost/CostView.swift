import SwiftUI
import Charts
import ZeusKit

struct CostData: Sendable {
    let summary: CostSummary
    let vms: [VMCost]
    let waste: WasteReport?
    let budgets: BudgetReport?
}

struct CostView: View {
    let client: ZeusClient
    @State private var loader: Loader<CostData>
    @State private var search = ""
    @State private var sort = [KeyPathComparator(\VMCost.monthlyEstimate, order: .reverse)]

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader {
            async let o = client.costOverview()
            async let v = client.vmCosts()
            async let w = try? client.wasteReport()
            async let b = try? client.budgets()
            return try await CostData(summary: o.summary, vms: v, waste: await w, budgets: await b)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { data in
            let rows = data.vms.filter { search.isEmpty || $0.vmName.localizedCaseInsensitiveContains(search)
                || $0.namespace.localizedCaseInsensitiveContains(search) }.sorted(using: sort)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Modelled from your configured unit prices and recorded usage. These are estimates, not invoices.")
                        .font(.callout).foregroundStyle(.secondary)
                    summary(data)
                    if !data.vms.isEmpty { CostBreakdownChart(vms: Array(data.vms.sorted { $0.dailyCost > $1.dailyCost }.prefix(10))) }
                    Table(rows, sortOrder: $sort) {
                        TableColumn("Machine", value: \.vmName)
                        TableColumn("Namespace", value: \.namespace)
                        TableColumn("Per day", value: \.dailyCost) { Text($0.dailyCost, format: .currency(code: currency(data))) }
                        TableColumn("Per month", value: \.monthlyEstimate) { Text($0.monthlyEstimate, format: .currency(code: currency(data))) }
                        TableColumn("Savings") { Text($0.optimizationAvailable == true ? "Available" : "—") }
                    }
                    .frame(minHeight: 220)
                    budgetNote(data)
                }
                .padding()
            }
        }
        .navigationTitle("Cost")
        .searchable(text: $search, prompt: "Search machines")
        .task { loader.start(polling: false) }
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
    }

    private func currency(_ d: CostData) -> String { d.budgets?.currency ?? "USD" }

    private func summary(_ d: CostData) -> some View {
        Grid(horizontalSpacing: 28, verticalSpacing: 6) {
            GridRow {
                stat("Per month", d.summary.totalMonthlyCost.formatted(.currency(code: currency(d))))
                stat("Per day", d.summary.totalDailyCost.formatted(.currency(code: currency(d))))
                stat("Machines", "\(d.summary.vmCount)")
                stat("Potential savings", (d.waste?.totalPotentialSavings ?? d.summary.optimizationAvailable)
                        .formatted(.currency(code: currency(d))))
            }
        }
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title2.weight(.semibold)).monospacedDigit()
        }
    }

    @ViewBuilder private func budgetNote(_ d: CostData) -> some View {
        if let b = d.budgets {
            Text(b.budgets.isEmpty ? "No budgets are set for \(b.period ?? "this period")."
                                   : "\(b.budgets.count) budgets for \(b.period ?? "this period"); budget details are not shown yet.")
                .font(.callout).foregroundStyle(.secondary)
        }
    }
}

/// Daily cost per machine, split by what it is spent on. One axis; the table below holds the same numbers.
struct CostBreakdownChart: View {
    let vms: [VMCost]
    @State private var picked: String?

    private struct Slice: Identifiable { let id = UUID(); let vm: String; let part: String; let cost: Double }
    private static let parts = ["CPU", "Memory", "Storage", "Network"]

    private var slices: [Slice] {
        vms.flatMap { v in
            let b = v.breakdown
            return [("CPU", b?.cpuCost), ("Memory", b?.memoryCost), ("Storage", b?.storageCost), ("Network", b?.networkCost)]
                .map { Slice(vm: v.vmName, part: $0.0, cost: $0.1 ?? 0) }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Daily cost by component").font(.headline)
            Chart(slices) { s in
                BarMark(x: .value("Machine", s.vm), y: .value("Cost per day", s.cost))
                    .foregroundStyle(by: .value("Component", s.part))
                if let picked, picked == s.vm, s.part == "CPU" {
                    RuleMark(x: .value("Machine", picked)).foregroundStyle(.secondary.opacity(0.4))
                        .annotation(position: .top, overflowResolution: .init(x: .fit, y: .disabled)) { tooltip(picked) }
                }
            }
            .chartXSelection(value: $picked)
            .chartForegroundStyleScale(domain: Self.parts, range: [Color.blue, .teal, .orange, .purple])
            .chartYAxis { AxisMarks(format: .currency(code: "USD")) }
            .frame(height: 220)
            .accessibilityLabel("Stacked bar chart of daily cost per machine by CPU, memory, storage and network")
        }
    }

    private func tooltip(_ vm: String) -> some View {
        VStack(alignment: .leading) {
            Text(vm).font(.caption.weight(.semibold))
            ForEach(slices.filter { $0.vm == vm }) { s in
                Text("\(s.part): \(s.cost, format: .currency(code: "USD"))").font(.caption2).monospacedDigit()
            }
        }
        .padding(6).background(.regularMaterial, in: .rect(cornerRadius: 6))
    }
}
