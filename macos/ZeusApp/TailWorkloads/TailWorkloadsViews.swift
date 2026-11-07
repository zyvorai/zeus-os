import SwiftUI
import ZeusKit

/// One section of a grouped screen: a title and a fetch that yields table rows.
struct TailSection: Identifiable, Sendable {
    let title: String
    let fetch: @Sendable (ZeusClient) async throws -> [JSONValue]
    var id: String { title }
}

/// A segmented screen over several read-only lists; each section loads on demand and shows a JSONTable.
struct TailSectionsView: View {
    let client: ZeusClient
    let sections: [TailSection]
    @State private var current: String

    init(client: ZeusClient, sections: [TailSection]) {
        self.client = client; self.sections = sections; _current = State(initialValue: sections[0].id)
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Section", selection: $current) {
                ForEach(sections) { Text($0.title).tag($0.id) }
            }
            .pickerStyle(.segmented).labelsHidden().padding(10)
            Divider()
            if let s = sections.first(where: { $0.id == current }) {
                TailSectionBody(client: client, section: s).id(s.id)
            }
        }
    }
}

private struct TailSectionBody: View {
    @State private var loader: Loader<[JSONValue]>
    let title: String

    init(client: ZeusClient, section: TailSection) {
        title = section.title
        _loader = State(initialValue: Loader { try await section.fetch(client) })
    }

    var body: some View {
        LoadStateView(loader: loader) { rows in
            JSONTable(rows: rows, emptyTitle: "No \(title.lowercased())", emptyDescription: "Nothing found for this cluster.")
        }
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}

extension Destination {
    static let tailWorkloads: [Destination] = [
        Destination("Workloads", symbol: "square.stack.3d.up", group: "Kubernetes") {
            TailSectionsView(client: $0, sections: [
                TailSection(title: "Deployments") { try await $0.tail_deployments() },
                TailSection(title: "StatefulSets") { try await $0.tail_statefulSets() },
                TailSection(title: "DaemonSets") { try await $0.tail_daemonSets() },
                TailSection(title: "Jobs") { try await $0.tail_jobs() },
                TailSection(title: "CronJobs") { try await $0.tail_cronJobs() },
            ])
        },
        Destination("Config", symbol: "doc.text", group: "Kubernetes") {
            TailSectionsView(client: $0, sections: [
                TailSection(title: "ConfigMaps") { try await $0.tail_configMaps() },
                TailSection(title: "Service Accounts") { try await $0.serviceAccountSummaries().map(\.row) },
                TailSection(title: "Secrets") { try await $0.secretSummaries().map(\.row) },
                TailSection(title: "TLS Secrets") { try await $0.tlsSecretSummaries().map(\.row) },
                TailSection(title: "Certificates") { try await $0.tail_certificates() },
                TailSection(title: "External Secrets") { try await $0.tail_externalSecrets() },
            ])
        },
        Destination("VM Objects", symbol: "cube.transparent", group: "Kubernetes") {
            TailSectionsView(client: $0, sections: [
                TailSection(title: "VM Instances") { try await $0.tail_vmis() },
                TailSection(title: "Replica Sets") { try await $0.tail_vmReplicaSets() },
                TailSection(title: "Exports") { try await $0.tail_vmExports() },
                TailSection(title: "Templates") { try await $0.tail_vmTemplates() },
            ])
        },
        Destination("Cluster Resources", symbol: "square.grid.3x3", group: "Kubernetes") {
            TailSectionsView(client: $0, sections: [
                TailSection(title: "Storage Classes") { try await $0.tail_storageClasses() },
                TailSection(title: "Snapshot Classes") { try await $0.tail_volumeSnapshotClasses() },
                TailSection(title: "Ingress Classes") { try await $0.tail_ingressClasses() },
                TailSection(title: "CRDs") { try await $0.tail_crds() },
                TailSection(title: "Port Forwards") { try await $0.tail_portForwards() },
            ])
        },
    ]
}
