import SwiftUI
import Charts
import ZeusKit

struct TopologyData: Sendable { let topology: Topology; let dvr: DVRCluster?; let dvrStatus: DVRStatus? }

/// Nodes as cards with the VMs they host, plus the cluster flight recorder (DVR) as a chart over time.
struct TopologyView: View {
    let client: ZeusClient
    @State private var loader: Loader<TopologyData>
    @State private var hover: Date?

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader {
            async let t = client.topology()
            async let d = try? client.dvrCluster()
            async let s = try? client.dvrStatus()
            return try await TopologyData(topology: t, dvr: await d, dvrStatus: await s)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { data in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if data.topology.nodes.isEmpty {
                        ContentUnavailableView("No nodes", systemImage: "point.3.connected.trianglepath.dotted")
                    }
                    ForEach(data.topology.nodes) { node in nodeCard(node, vms: data.topology.vms.filter { $0.node == node.id || $0.node == node.name }) }
                    let orphans = data.topology.vms.filter { vm in !data.topology.nodes.contains { $0.id == vm.node || $0.name == vm.node } }
                    if !orphans.isEmpty { GroupBox("Not placed on a node") { vmGrid(orphans) } }
                    if let dvr = data.dvr, !dvr.frames.isEmpty { recorder(dvr, status: data.dvrStatus) }
                }.padding()
            }
        }
        .navigationTitle("Topology")
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }

    private func nodeCard(_ node: TopologyNode, vms: [TopologyVM]) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 16) {
                    Label(node.status ?? "Unknown", systemImage: node.status == "Ready" ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundStyle(node.status == "Ready" ? .green : .orange)
                    if let c = node.cpuUsage { Text("CPU \(c, specifier: "%.0f")%") }
                    if let m = node.memoryUsage { Text("Memory \(m, specifier: "%.0f")%") }
                    Text("\(vms.count) machine\(vms.count == 1 ? "" : "s")")
                }.font(.callout).foregroundStyle(.secondary)
                if vms.isEmpty { Text("No machines on this node.").foregroundStyle(.secondary) } else { vmGrid(vms) }
            }.frame(maxWidth: .infinity, alignment: .leading)
        } label: { Label(node.name ?? node.id, systemImage: "server.rack").font(.headline) }
    }

    private func vmGrid(_ vms: [TopologyVM]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 10)], alignment: .leading, spacing: 10) {
            ForEach(vms) { vm in
                VStack(alignment: .leading, spacing: 2) {
                    Text(vm.name ?? vm.id).font(.body.weight(.medium))
                    Text("\(vm.namespace ?? "") · \(vm.status ?? "Unknown")").font(.caption).foregroundStyle(.secondary)
                    if let c = vm.cpuUsage, let m = vm.memoryUsage {
                        Text("CPU \(c, specifier: "%.1f")% · Mem \(m, specifier: "%.0f")%").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(8).frame(maxWidth: .infinity, alignment: .leading)
                .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private func recorder(_ dvr: DVRCluster, status: DVRStatus?) -> some View {
        let frames = dvr.frames.compactMap { f in f.date.map { (date: $0, frame: f) } }
        let near = hover.flatMap { h in frames.min { abs($0.date.timeIntervalSince(h)) < abs($1.date.timeIntervalSince(h)) } }
        return GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                Text("Cluster flight recorder: machines running over time" + (status?.clusterFrames.map { " (\($0) frames)" } ?? ""))
                    .font(.callout).foregroundStyle(.secondary)
                Chart {
                    ForEach(frames, id: \.date) { p in
                        LineMark(x: .value("Time", p.date), y: .value("Machines running", p.frame.vmsRunning ?? 0))
                    }
                    if let near {
                        RuleMark(x: .value("Time", near.date))
                            .annotation(position: .top, overflowResolution: .init(x: .fit, y: .disabled)) {
                                Text("\(near.date.formatted(.dateTime.hour().minute())): \(near.frame.vmsRunning ?? 0) of \(near.frame.vmsTotal ?? 0) running, \(near.frame.warningEvents ?? 0) warnings")
                                    .font(.caption).padding(4).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 4))
                            }
                    }
                }
                .chartYScale(domain: 0...Double(max(1, frames.map { $0.frame.vmsTotal ?? 0 }.max() ?? 1)))
                .chartXSelection(value: $hover)
                .frame(height: 180)
                DisclosureGroup("Table") {
                    Table(Array(dvr.frames.suffix(24).reversed())) {
                        TableColumn("Time") { f in if let d = f.date { Text(d, format: .dateTime.month().day().hour().minute()) } else { Text(f.ts) } }
                        TableColumn("Running") { Text("\($0.vmsRunning ?? 0)") }
                        TableColumn("Failed") { Text("\($0.vmsFailed ?? 0)") }
                        TableColumn("Nodes ready") { Text("\($0.nodesReady ?? 0) of \($0.nodesTotal ?? 0)") }
                        TableColumn("Warnings") { Text("\($0.warningEvents ?? 0)") }
                    }.frame(height: 220)
                }
            }
        } label: { Label("Flight recorder", systemImage: "record.circle").font(.headline) }
    }
}
