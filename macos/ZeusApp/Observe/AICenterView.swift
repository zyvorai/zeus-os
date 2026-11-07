import SwiftUI
import ZeusKit

struct AIData: Sendable { let status: AIStatus; let doctor: DoctorSummary?; let fleet: GuestFleet? }

/// AI Center, read-only: provider status, the doctor summary and fleet guest findings. Chat is not here (it sends prompts).
struct AICenterView: View {
    let client: ZeusClient
    @State private var loader: Loader<AIData>

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader {
            async let s = client.aiStatus()
            async let d = try? client.aiDoctor()
            async let f = try? client.guestFleet()
            return try await AIData(status: s, doctor: await d, fleet: await f)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { data in
            Form {
                Section("Providers") {
                    LabeledContent("Enabled", value: "\(data.status.enabledCount ?? 0)")
                    LabeledContent("Default", value: data.status.defaultProviderName ?? "None configured")
                    LabeledContent("Air-gap mode", value: data.status.airGapMode == true ? "On" : "Off")
                    ForEach(data.status.providers) { p in
                        LabeledContent(p.string("name") ?? p.id, value: p.string("kind") ?? p.string("provider_type") ?? "")
                    }
                    if data.status.providers.isEmpty { Text("No AI provider is configured on this server.").foregroundStyle(.secondary) }
                }
                if let d = data.doctor {
                    Section("Doctor") {
                        LabeledContent("Findings", value: "\(d.totalFindings ?? 0)")
                        LabeledContent("Priority 1", value: "\(d.p1Count ?? 0)")
                    }
                }
                if let f = data.fleet {
                    Section("Guest intelligence") {
                        LabeledContent("Machines scanned", value: "\(f.vmsScanned ?? 0)")
                        LabeledContent("With a profile", value: "\(f.vmsWithProfile ?? 0)")
                        ForEach(f.issues) { i in
                            LabeledContent(i.message ?? i.id, value: "\(i.count ?? 0) machine\(i.count == 1 ? "" : "s")")
                        }
                    }
                }
            }
            .formStyle(.grouped)
        }
        .navigationTitle("AI Center")
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}

struct ChaosData: Sendable { let stats: ChaosStats?; let experiments: [ChaosExperiment] }

/// Chaos experiments, list only.
struct ChaosView: View {
    let client: ZeusClient
    @State private var loader: Loader<ChaosData>

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader {
            async let s = try? client.chaosStats()
            async let e = client.chaosExperiments()
            return try await ChaosData(stats: await s, experiments: e)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { data in
            VStack(spacing: 0) {
                if let s = data.stats {
                    Text("\(s.totalExperiments ?? 0) experiments · \(s.runningExperiments ?? 0) running · \(s.failedExperiments ?? 0) failed · resilience score \(s.resilienceScore ?? 0, specifier: "%.0f")")
                        .font(.callout).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading).padding()
                }
                if data.experiments.isEmpty {
                    ContentUnavailableView("No chaos experiments", systemImage: "bolt.trianglebadge.exclamationmark",
                                           description: Text("None have been defined on this server."))
                } else {
                    Table(data.experiments) {
                        TableColumn("Name") { Text($0.name ?? "—") }
                        TableColumn("Namespace") { Text($0.namespace ?? "—") }
                        TableColumn("Type") { Text($0.experimentType ?? "—") }
                        TableColumn("Status") { Text($0.status ?? "—") }
                    }
                }
            }
        }
        .navigationTitle("Chaos")
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}
