import SwiftUI
import ZeusKit

@MainActor @Observable
final class VMMetricsModel {
    var points: [MetricPoint] = []
    var isLoading = false
    var failed = false

    func load(client: ZeusClient?, vm: VM, range: MetricsRange) async {
        guard let client else { return }
        isLoading = true; defer { isLoading = false }
        do {
            let p = try await client.vmHistory(vm, range: range)
            guard !Task.isCancelled else { return }       // a newer selection superseded this one
            points = p; failed = false
        } catch is CancellationError {
        } catch {
            if !Task.isCancelled { points = []; failed = true }
        }
    }

    func series(_ name: String, _ color: Color, _ key: KeyPath<MetricPoint, Double?>) -> MetricSeries {
        MetricSeries(name: name, color: color,
                     points: points.compactMap { p in p[keyPath: key].map { (p.timestamp, $0) } })
    }
}

struct VMMetricsView: View {
    let vm: VM
    @Environment(AppModel.self) private var model
    @State private var metrics = VMMetricsModel()
    @State private var range = MetricsRange.hour
    @State private var showTable = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Range", selection: $range) {
                ForEach(MetricsRange.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented).labelsHidden()

            if vm.status != "Running" && metrics.points.isEmpty {
                ContentUnavailableView("No live metrics", systemImage: "chart.xyaxis.line",
                                       description: Text("\(vm.name) is \(vm.status.lowercased())."))
            } else if metrics.failed {
                ContentUnavailableView("Metrics unavailable", systemImage: "exclamationmark.triangle")
            } else {
                MetricChart(title: "CPU", series: [metrics.series("CPU", .blue, \.cpuUsagePercent)],
                            format: Fmt.percent, domain: 0...100)
                MetricChart(title: "Memory (of requested)",
                            series: [metrics.series("Memory", .purple, \.memoryUsagePercent)],
                            format: Fmt.percent, domain: 0...100)
                MetricChart(title: "Network", series: [
                    metrics.series("Receive", .teal, \.networkRxBytesPerSec),
                    metrics.series("Send", .orange, \.networkTxBytesPerSec)], format: Fmt.rate)
                MetricChart(title: "Disk", series: [
                    metrics.series("Read", .teal, \.diskReadBytesPerSec),
                    metrics.series("Write", .orange, \.diskWriteBytesPerSec)], format: Fmt.rate)
                DisclosureGroup("Data table", isExpanded: $showTable) { MetricTable(points: metrics.points) }
                    .font(.subheadline)
            }
        }
        .overlay(alignment: .topTrailing) { if metrics.isLoading { ProgressView().controlSize(.small) } }
        .task(id: "\(vm.id)|\(range.rawValue)") { await metrics.load(client: model.client, vm: vm, range: range) }
    }
}

struct MetricTable: View {
    let points: [MetricPoint]

    var body: some View {
        Table(points.suffix(30).reversed()) {
            TableColumn("Time") { Text($0.timestamp, format: .dateTime.hour().minute().second()) }
            TableColumn("CPU") { Text($0.cpuUsagePercent.map(Fmt.percent) ?? "—") }
            TableColumn("Mem") { Text($0.memoryUsagePercent.map(Fmt.percent) ?? "—") }
            TableColumn("Rx") { Text($0.networkRxBytesPerSec.map(Fmt.rate) ?? "—") }
            TableColumn("Tx") { Text($0.networkTxBytesPerSec.map(Fmt.rate) ?? "—") }
        }
        .frame(height: 200)
    }
}
