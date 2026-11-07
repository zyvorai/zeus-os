import SwiftUI
import ZeusKit

struct ComplianceView: View {
    let client: ZeusClient
    @State private var loader: Loader<[ComplianceFramework]>
    @State private var selected: ComplianceFramework?

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader { try await client.complianceFrameworks() })
    }

    var body: some View {
        LoadStateView(loader: loader) { frameworks in
            if frameworks.isEmpty {
                ContentUnavailableView("No frameworks", systemImage: "checkmark.shield",
                                       description: Text("No compliance frameworks are enabled."))
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 16)], spacing: 16) {
                        ForEach(frameworks) { f in
                            Button { selected = f } label: { FrameworkCard(framework: f) }
                                .buttonStyle(.plain).accessibilityHint("Shows control detail")
                        }
                    }.padding()
                }
            }
        }
        .sheet(item: $selected) { ComplianceDetailView(client: client, framework: $0) }
        .navigationTitle("Compliance")
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
        .task { loader.start(polling: false) }
    }
}

struct FrameworkCard: View {
    let framework: ComplianceFramework

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(framework.frameworkType ?? framework.name).font(.headline)
                    Text(framework.version.map { "Version \($0)" } ?? framework.name)
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Gauge(value: framework.complianceScore, in: 0...100) { Text("Score") } currentValueLabel: {
                    Text(framework.complianceScore, format: .number.precision(.fractionLength(0)))
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(framework.complianceScore >= 80 ? .green : framework.complianceScore >= 50 ? .orange : .red)
            }
            Divider()
            HStack {
                Label("\(framework.passedControls) passed", systemImage: "checkmark.circle")
                Spacer()
                Label("\(framework.failedControls) failed", systemImage: "xmark.circle")
            }.font(.callout)
            if let d = framework.lastScanDate {
                Text("Scanned ") + Text(d, style: .relative) + Text(" ago")
            }
        }
        .padding().background(.background.secondary, in: .rect(cornerRadius: 12))
        .accessibilityElement(children: .combine)
    }
}
