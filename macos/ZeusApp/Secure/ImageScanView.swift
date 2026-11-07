import SwiftUI
import Charts
import ZeusKit

struct ImageScanData: Sendable { let report: ImageScanReport; let results: [ImageScanResult] }

struct ImageScanView: View {
    @State private var loader: Loader<ImageScanData>

    init(client: ZeusClient) {
        _loader = State(initialValue: Loader {
            async let r = client.imageScanReport()
            async let s = client.imageScanResults()
            return try await ImageScanData(report: r, results: s)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { data in
            let r = data.report
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 24) {
                        stat("Images", r.totalImages); stat("Scanned", r.scannedImages)
                        stat("Vulnerable", r.vulnerableImages); stat("Vulnerabilities", r.totalVulnerabilities)
                    }
                    if let s = r.severityDistribution, s.total > 0 {
                        Chart(severityBars(s), id: \.0) { BarMark(x: .value("Count", $0.1), y: .value("Severity", $0.0)) }
                            .frame(height: 140)
                    } else {
                        Text("No vulnerabilities reported.").foregroundStyle(.secondary)
                    }
                    if !r.topVulnerableImages.isEmpty {
                        Text("Most vulnerable images").font(.headline)
                        Table(r.topVulnerableImages) {
                            TableColumn("Image", value: \.image)
                            TableColumn("Critical") { Text("\($0.critical ?? 0)") }.width(70)
                            TableColumn("High") { Text("\($0.high ?? 0)") }.width(70)
                            TableColumn("Total") { Text("\($0.total ?? 0)") }.width(70)
                        }.frame(minHeight: 160)
                    }
                    Text("Scan results").font(.headline)
                    if data.results.isEmpty {
                        ContentUnavailableView("No scans", systemImage: "shield.lefthalf.filled",
                                               description: Text("No image has been scanned yet."))
                    } else {
                        Table(data.results) {
                            TableColumn("Image") { Text($0.image + ($0.tag.map { ":\($0)" } ?? "")) }
                            TableColumn("Critical") { Text("\($0.severityCounts?.critical ?? 0)") }.width(70)
                            TableColumn("High") { Text("\($0.severityCounts?.high ?? 0)") }.width(70)
                            TableColumn("Status") { Text($0.complianceStatus ?? "—") }
                            TableColumn("Scanner") { Text($0.scanner ?? "—") }
                        }.frame(minHeight: 240)
                    }
                }.padding()
            }
        }
        .navigationTitle("Image Scanning")
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
        .task { loader.start(polling: false) }
    }

    private func severityBars(_ s: SeverityCounts) -> [(String, Int)] {
        [("Critical", s.critical), ("High", s.high), ("Medium", s.medium), ("Low", s.low), ("Negligible", s.negligible)]
    }

    private func stat(_ label: String, _ v: Int?) -> some View {
        VStack(alignment: .leading) {
            Text(v.map(String.init) ?? "—").font(.title.bold()); Text(label).font(.caption).foregroundStyle(.secondary)
        }.accessibilityElement(children: .combine)
    }
}
