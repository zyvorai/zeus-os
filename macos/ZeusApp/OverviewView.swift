import SwiftUI
import ZeusKit

struct OverviewView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let c = model.cluster {
                    Text("Cluster").font(.title3.weight(.semibold))
                    HStack(alignment: .top, spacing: 40) {
                        gauge("CPU", c.cpuUsagePercent,
                              caption: "\(c.usedCpuCores.formatted(.number.precision(.fractionLength(1)))) of \(Int(c.totalCpuCores)) cores")
                        gauge("Memory", c.memoryUsagePercent,
                              caption: "\(Self.gb(c.usedMemoryBytes)) of \(Self.gb(c.totalMemoryBytes))")
                        gauge("Machines", Double(c.runningVms) / Double(max(c.totalVms, 1)) * 100,
                              caption: "\(c.runningVms) of \(c.totalVms) running", shows: "\(c.runningVms)")
                        Spacer()
                    }
                } else {
                    ContentUnavailableView("Cluster metrics unavailable", systemImage: "gauge.with.dots.needle.0percent")
                }
                if !model.nodes.isEmpty {
                    Text("Nodes").font(.title3.weight(.semibold))
                    Table(model.nodes) {
                        TableColumn("Node", value: \.nodeName)
                        TableColumn("Status") { n in n.status.map { StatusBadge(status: $0) } }
                        TableColumn("CPU") { Text($0.cpuUsagePercent.map(Fmt.percent) ?? "—").monospacedDigit() }
                        TableColumn("Memory") { Text($0.memoryUsagePercent.map(Fmt.percent) ?? "—").monospacedDigit() }
                        TableColumn("VMs") { Text($0.vmCount.map(String.init) ?? "—").monospacedDigit() }
                        TableColumn("Pods") { Text($0.podCount.map(String.init) ?? "—").monospacedDigit() }
                    }
                    .frame(height: CGFloat(48 + model.nodes.count * 24))
                }
            }
            .padding(24)
        }
        .navigationTitle("Overview")
    }

    private static func gb(_ bytes: Double) -> String {
        Measurement(value: bytes, unit: UnitInformationStorage.bytes).converted(to: .gigabytes)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided,
                                    numberFormatStyle: .number.precision(.fractionLength(0...1))))
    }

    /// A crisp ring (the system circular Gauge only ships at ~40pt and scaling it up blurs the text),
    /// with the measure's name above its detail so each ring says what it measures.
    private func gauge(_ title: String, _ percent: Double, caption: String? = nil, shows: String? = nil) -> some View {
        let fraction = min(max(percent, 0), 100) / 100
        let tint: Color = title == "Machines" ? .accentColor : percent >= 90 ? .red : percent >= 75 ? .orange : .accentColor
        return VStack(spacing: 4) {
            ZStack {
                Circle().stroke(.quaternary, lineWidth: 10)
                Circle().trim(from: 0, to: fraction)
                    .stroke(tint, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text(shows ?? Fmt.percent(percent)).font(.title2.weight(.semibold)).monospacedDigit()
            }
            .frame(width: 104, height: 104).padding(.bottom, 8)
            Text(title).font(.headline)
            if let caption { Text(caption).font(.caption).foregroundStyle(.secondary) }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(caption ?? Fmt.percent(percent))
    }
}
