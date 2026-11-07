import SwiftUI
import Charts
import ZeusKit

struct CapacityData: Sendable {
    let usage: CapacityUsage
    let thresholds: CapacityThresholds?
    let projections: [CapacityProjection]
    let forecasts: [CapacityForecast]
    let recommendations: [JSONValue]
}

struct CapacityView: View {
    let client: ZeusClient
    @State private var loader: Loader<CapacityData>

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader {
            async let u = client.capacityUsage()
            async let t = try? client.capacityThresholds()
            async let p = try? client.capacityProjections()
            async let f = try? client.capacityForecasts()
            async let r = try? client.capacityRecommendations()
            return try await CapacityData(usage: u, thresholds: await t, projections: await p ?? [],
                                          forecasts: await f ?? [], recommendations: await r ?? [])
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { d in
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    usage(d)
                    if !d.projections.isEmpty { ProjectionChart(projections: d.projections) }
                    forecasts(d.forecasts)
                    recommendations(d.recommendations)
                }
                .padding()
            }
        }
        .navigationTitle("Capacity")
        .task { loader.start() }
        .onDisappear { loader.stop() }
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
    }

    private func usage(_ d: CapacityData) -> some View {
        let u = d.usage
        return VStack(alignment: .leading) {
            Text("Current usage").font(.headline)
            Grid(alignment: .leading, horizontalSpacing: 28, verticalSpacing: 12) {
                GridRow {
                    meter("CPU", u.cpuUtilizationPercent, detail: pair(u.cpuCoresUsed, u.cpuCoresTotal, "cores"),
                          warn: d.thresholds?.cpuWarningPercent, crit: d.thresholds?.cpuCriticalPercent)
                    meter("Memory", u.memoryUtilizationPercent, detail: pair(u.memoryGBUsed, u.memoryGBTotal, "GB"),
                          warn: d.thresholds?.memoryWarningPercent, crit: d.thresholds?.memoryCriticalPercent)
                    meter("Storage", u.storageUtilizationPercent, detail: pair(u.storageTBUsed, u.storageTBTotal, "TB"),
                          warn: d.thresholds?.storageWarningPercent, crit: d.thresholds?.storageCriticalPercent)
                    meter("Pods", podPercent(u), detail: u.podsTotal.map { "\(u.podsUsed ?? 0) of \($0)" } ?? "—", warn: nil, crit: nil)
                }
            }
            if let n = u.nodeCount { Text("\(n) \(n == 1 ? "node" : "nodes")").font(.callout).foregroundStyle(.secondary) }
        }
    }

    private func podPercent(_ u: CapacityUsage) -> Double? {
        guard let t = u.podsTotal, t > 0, let used = u.podsUsed else { return nil }
        return Double(used) / Double(t) * 100
    }

    private func pair(_ used: Double?, _ total: Double?, _ unit: String) -> String {
        guard let total else { return "—" }
        let f = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(0...2))
        return "\((used ?? 0).formatted(f)) of \(total.formatted(f)) \(unit)"
    }

    private func meter(_ label: String, _ percent: Double?, detail: String, warn: Double?, crit: Double?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(percent.map { "\($0.formatted(.number.precision(.fractionLength(0...1))))%" } ?? "—")
                .font(.title2.weight(.semibold)).monospacedDigit()
            ProgressView(value: min(max((percent ?? 0) / 100, 0), 1)).tint(tint(percent, warn, crit)).frame(width: 140)
            Text(detail).font(.caption).foregroundStyle(.secondary).monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }

    private func tint(_ p: Double?, _ warn: Double?, _ crit: Double?) -> Color {
        guard let p else { return .secondary }
        if let crit, p >= crit { return .red }
        if let warn, p >= warn { return .orange }
        return .accentColor
    }

    @ViewBuilder private func forecasts(_ f: [CapacityForecast]) -> some View {
        VStack(alignment: .leading) {
            Text("Forecasts").font(.headline)
            if f.isEmpty {
                Text("No forecasts configured.").foregroundStyle(.secondary)
            } else {
                Table(f) {
                    TableColumn("Name") { Text($0.name ?? $0.forecastID) }
                    TableColumn("Resource") { Text($0.resourceType ?? "—") }
                    TableColumn("Method") { Text($0.forecastMethod ?? "—") }
                    TableColumn("Horizon") { Text($0.timeHorizonDays.map { "\($0) days" } ?? "—") }
                    TableColumn("Confidence") { Text($0.confidenceLevel.map { $0.formatted(.percent.precision(.fractionLength(0))) } ?? "—") }
                }
                .frame(height: 40 + CGFloat(f.count) * 28)
            }
        }
    }

    @ViewBuilder private func recommendations(_ r: [JSONValue]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Capacity recommendations").font(.headline)
            if r.isEmpty {
                Text("No capacity recommendations.").foregroundStyle(.secondary)
            } else {
                ForEach(Array(r.enumerated()), id: \.offset) { _, item in
                    Text(item["title"]?.string ?? item["description"]?.string ?? item["recommendation"]?.string ?? "Recommendation")
                }
            }
        }
    }
}

/// Projected utilisation per resource over time. One axis (percent); a table of the same numbers is one toggle away.
struct ProjectionChart: View {
    let projections: [CapacityProjection]
    @State private var picked: Date?
    @State private var showTable = false

    private struct Pt: Identifiable { let id = UUID(); let resource: String; let date: Date; let value: Double }
    private var points: [Pt] {
        projections.flatMap { p in p.projections.compactMap { q in
            guard let d = q.date, let v = q.projectedUtilization else { return nil }
            return Pt(resource: p.resourceType.capitalized, date: d, value: v)
        } }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Projected utilisation").font(.headline)
                Spacer()
                Toggle("Show as table", isOn: $showTable).toggleStyle(.button).controlSize(.small)
            }
            if showTable { table } else { chart }
            ForEach(projections) { p in
                Text("\(p.resourceType.capitalized): \(p.currentUtilization.map { "\($0.formatted(.number.precision(.fractionLength(0...1))))% now" } ?? "—"), trend \(p.trend ?? "unknown")")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var chart: some View {
        let pts = points
        let pk = nearest(pts)
        return Chart(pts) { p in
            LineMark(x: .value("Date", p.date), y: .value("Utilisation", p.value))
                .foregroundStyle(by: .value("Resource", p.resource))
            if let pk, pk == p.date {
                PointMark(x: .value("Date", p.date), y: .value("Utilisation", p.value))
                    .foregroundStyle(by: .value("Resource", p.resource))
            }
        }
        .chartXSelection(value: $picked)
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(values: .stride(by: 25)) { v in
                AxisGridLine()
                AxisValueLabel { if let d = v.as(Double.self) { Text("\(Int(d))%") } }
            }
        }
        .chartForegroundStyleScale(domain: projections.map { $0.resourceType.capitalized }, range: [Color.blue, .teal, .orange, .purple])
        .overlay(alignment: .topTrailing) {
            if let pk {
                VStack(alignment: .leading) {
                    Text(pk.formatted(date: .abbreviated, time: .omitted)).font(.caption.weight(.semibold))
                    ForEach(pts.filter { $0.date == pk }) { q in
                        Text("\(q.resource): \(q.value.formatted(.number.precision(.fractionLength(1))))%").font(.caption2).monospacedDigit()
                    }
                }
                .padding(6).background(.regularMaterial, in: .rect(cornerRadius: 6))
            }
        }
        .frame(height: 220)
        .accessibilityLabel("Line chart of projected utilisation per resource over the coming weeks")
    }

    private func nearest(_ pts: [Pt]) -> Date? {
        guard let picked else { return nil }
        return pts.map(\.date).min { abs($0.timeIntervalSince(picked)) < abs($1.timeIntervalSince(picked)) }
    }

    private var table: some View {
        let pts = points
        let dates = Array(Set(pts.map(\.date))).sorted()
        let names = projections.map { $0.resourceType.capitalized }
        return ScrollView {
            Grid(alignment: .leading, horizontalSpacing: 20) {
                GridRow { Text("Date").bold(); ForEach(names, id: \.self) { Text($0).bold() } }
                ForEach(dates, id: \.self) { d in
                    GridRow {
                        Text(d.formatted(date: .abbreviated, time: .omitted))
                        ForEach(names, id: \.self) { n in
                            Text(pts.first { $0.date == d && $0.resource == n }
                                .map { $0.value.formatted(.number.precision(.fractionLength(1))) + "%" } ?? "—").monospacedDigit()
                        }
                    }
                }
            }
        }.frame(height: 220)
    }
}
