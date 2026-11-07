import SwiftUI
import Charts
import ZeusKit

struct FinOpsData: Sendable {
    let budgets: BudgetReport
    let pricing: FinOpsPricing?
    let history: CostHistory?
}

struct BudgetRow: Identifiable {
    let raw: JSONValue
    var id: String { raw["id"]?.string ?? raw["name"]?.string ?? "?" }
    var name: String { raw["name"]?.string ?? id }
    var limit: Double? { raw["monthly_limit"]?.number }
}

struct FinOpsView: View {
    @Environment(AppModel.self) private var model
    let client: ZeusClient
    @State private var loader: Loader<FinOpsData>
    @State private var deleting: BudgetRow?
    @State private var editingPricing = false
    @State private var failure: String?

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader {
            async let b = client.budgets()
            async let p = try? client.pricing()
            async let h = try? client.costHistory()
            return try await FinOpsData(budgets: b, pricing: await p, history: await h)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { d in
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text(d.budgets.basis ?? "Estimates from configured unit prices, not invoices.")
                        .font(.callout).foregroundStyle(.secondary)
                    if let h = d.history { CostHistoryChart(history: h) }
                    pricing(d.pricing)
                    budgets(d.budgets)
                }
                .padding()
            }
        }
        .navigationTitle("FinOps")
        .task { loader.start(polling: false) }
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
        .safeAreaInset(edge: .bottom) { if let failure { InlineError(message: failure) { self.failure = nil } } }
        .sheet(isPresented: $editingPricing) {
            if let p = loader.value?.pricing?.pricing {
                PricingEditSheet(current: p) { update in await save(update) }
            }
        }
        .confirmationDialog(deleting.map { "Delete budget \($0.name)?" } ?? "",
                            isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }),
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) { if let d = deleting { Task { await delete(d) } } }
        } message: { Text("This can't be undone.") }
    }

    private func pricing(_ p: FinOpsPricing?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Unit prices").font(.headline)
                Spacer()
                if model.canWrite, p?.pricing != nil { Button("Edit…") { editingPricing = true } }
            }
            if let u = p?.pricing {
                let cur = u.currency ?? "USD"
                Grid(alignment: .leading, horizontalSpacing: 28, verticalSpacing: 4) {
                    price("CPU core hour", u.cpuCoreHour, cur)
                    price("Memory GiB hour", u.memoryGiBHour, cur)
                    price("Storage GiB month", u.storageGiBMonth, cur)
                    price("GPU hour", u.gpuHour, cur)
                }
                Text("Source: \(p?.source ?? "unknown")").font(.caption).foregroundStyle(.secondary)
                ForEach(p?.envWarnings ?? [], id: \.self) { Label($0, systemImage: "exclamationmark.triangle").font(.caption) }
            } else {
                Text("Pricing isn't available.").foregroundStyle(.secondary)
            }
        }
    }

    private func price(_ label: String, _ v: Double?, _ cur: String) -> some View {
        GridRow {
            Text(label).foregroundStyle(.secondary)
            Text(v.map { $0.formatted(.currency(code: cur).precision(.fractionLength(2...4))) } ?? "Not charged").monospacedDigit()
        }
    }

    private func budgets(_ b: BudgetReport) -> some View {
        let rows = b.budgets.map(BudgetRow.init)
        return VStack(alignment: .leading) {
            Text("Budgets for \(b.period ?? "this month")").font(.headline)
            if rows.isEmpty {
                Text("No budgets are set.").foregroundStyle(.secondary)
            } else {
                Table(rows) {
                    TableColumn("Name") { Text($0.name) }
                    TableColumn("Monthly limit") { Text($0.limit.map { $0.formatted(.currency(code: b.currency ?? "USD")) } ?? "—").monospacedDigit() }
                    TableColumn("") { r in
                        if model.canWrite { Button("Delete…", role: .destructive) { deleting = r }.buttonStyle(.borderless) }
                    }
                }
                .frame(height: 40 + CGFloat(rows.count) * 28)
            }
            if model.canWrite {
                Text("Creating budgets isn't available in the app yet.").font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private func save(_ u: PricingUpdate) async {
        do { try await client.updatePricing(u); failure = nil } catch { failure = describe(error, "update pricing") }
        await loader.reload()
    }

    private func delete(_ r: BudgetRow) async {
        do { try await client.deleteBudget(id: r.id); failure = nil } catch { failure = describe(error, "delete the budget") }
        await loader.reload()
    }
}

/// Recorded run-rate samples. One series on one axis; the forecast is only quoted when the server says it is ready.
struct CostHistoryChart: View {
    let history: CostHistory
    @State private var picked: Date?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Estimated hourly cost").font(.headline)
            if history.points.isEmpty {
                Text(history.reason ?? "No samples recorded yet.").foregroundStyle(.secondary)
            } else {
                let cur = history.currency ?? "USD"
                let pk = nearest
                Chart(history.points, id: \.ts) { p in
                    LineMark(x: .value("Time", p.ts), y: .value("Cost per hour", p.hourly)).foregroundStyle(Color.blue)
                    if let pk, pk == p.ts {
                        PointMark(x: .value("Time", p.ts), y: .value("Cost per hour", p.hourly)).foregroundStyle(Color.blue)
                            .annotation(position: .top, overflowResolution: .init(x: .fit, y: .disabled)) {
                                Text("\(p.ts.formatted(date: .abbreviated, time: .shortened)): \(p.hourly.formatted(.currency(code: cur).precision(.fractionLength(4)))) per hour")
                                    .font(.caption2).padding(6).background(.regularMaterial, in: .rect(cornerRadius: 6))
                            }
                    }
                }
                .chartXSelection(value: $picked)
                .chartYScale(domain: .automatic(includesZero: true))
                .chartYAxis { AxisMarks(format: .currency(code: cur).precision(.fractionLength(2))) }
                .frame(height: 180)
                .accessibilityLabel("Line chart of estimated hourly cost across \(history.points.count) recorded samples")
            }
            if history.ready == true, let m = history.projectedMonthEnd {
                Text("Projected month end: \(m.formatted(.currency(code: history.currency ?? "USD")))").font(.callout)
            } else if let r = history.reason {
                Text(r).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var nearest: Date? {
        guard let picked else { return nil }
        return history.points.map(\.ts).min { abs($0.timeIntervalSince(picked)) < abs($1.timeIntervalSince(picked)) }
    }
}

struct PricingEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    let current: FinOpsPricing.Prices
    let onSave: (PricingUpdate) async -> Void
    @State private var cpu = ""
    @State private var mem = ""
    @State private var storage = ""
    @State private var gpu = ""
    @State private var working = false

    var body: some View {
        Form {
            TextField("CPU core hour", text: $cpu)
            TextField("Memory GiB hour", text: $mem)
            TextField("Storage GiB month", text: $storage)
            TextField("GPU hour (empty = not charged)", text: $gpu)
            Text("Prices in \(current.currency ?? "USD"). Changes apply to every cost estimate.").font(.caption).foregroundStyle(.secondary)
        }
        .formStyle(.grouped).frame(width: 420).padding()
        .onAppear {
            cpu = fmt(current.cpuCoreHour); mem = fmt(current.memoryGiBHour); storage = fmt(current.storageGiBMonth); gpu = fmt(current.gpuHour)
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                Button("Save") {
                    working = true
                    Task { await onSave(update()); dismiss() }
                }
                .keyboardShortcut(.defaultAction).disabled(working || !valid)
            }.padding([.horizontal, .bottom])
        }
    }

    private func fmt(_ v: Double?) -> String { v.map { String($0) } ?? "" }
    private func num(_ s: String) -> Double? { Double(s.trimmingCharacters(in: .whitespaces)) }
    private var gpuEmpty: Bool { gpu.trimmingCharacters(in: .whitespaces).isEmpty }
    private var valid: Bool {
        [cpu, mem, storage].allSatisfy { num($0).map { $0 >= 0 } ?? false } && (gpuEmpty || (num(gpu).map { $0 >= 0 } ?? false))
    }

    private func update() -> PricingUpdate {
        var u = PricingUpdate(cpuCoreHour: num(cpu), memoryGiBHour: num(mem), storageGiBMonth: num(storage))
        if gpuEmpty { if current.gpuHour != nil { u.clearGPUHour = true } } else { u.gpuHour = num(gpu) }
        return u
    }
}
