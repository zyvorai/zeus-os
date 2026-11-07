import SwiftUI
import ZeusKit

struct OverviewView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let c = model.cluster {
                    HStack(spacing: 32) {
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
                    Text("Nodes").font(.headline)
                    Table(model.nodes) {
                        TableColumn("Node", value: \.nodeName)
                        TableColumn("Status") { Text($0.status ?? "—") }
                        TableColumn("CPU") { Text($0.cpuUsagePercent.map(Fmt.percent) ?? "—") }
                        TableColumn("Memory") { Text($0.memoryUsagePercent.map(Fmt.percent) ?? "—") }
                        TableColumn("VMs") { Text($0.vmCount.map(String.init) ?? "—") }
                        TableColumn("Pods") { Text($0.podCount.map(String.init) ?? "—") }
                    }
                    .frame(height: CGFloat(60 + model.nodes.count * 28))
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

    private func gauge(_ title: String, _ percent: Double, caption: String? = nil, shows: String? = nil) -> some View {
        VStack {
            Gauge(value: min(max(percent, 0), 100), in: 0...100) {
                Text(title)
            } currentValueLabel: {
                Text(shows ?? Fmt.percent(percent)).foregroundStyle(.primary)
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .scaleEffect(1.6).frame(width: 80, height: 80)
            .tint(title == "Machines" ? .accentColor : percent >= 90 ? .red : percent >= 75 ? .orange : .accentColor)
            Text(caption ?? title).font(.caption).foregroundStyle(.secondary).padding(.top, 10)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(caption ?? Fmt.percent(percent))
    }
}
