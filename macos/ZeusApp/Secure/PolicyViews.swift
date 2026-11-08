import SwiftUI
import ZeusKit

struct PoliciesData: Sendable { let rows: [PolicyRow]; let failed: [String] }

/// Kyverno, admission and Gatekeeper policies in one read-only list.
struct PoliciesView: View {
    @State private var loader: Loader<PoliciesData>
    @State private var search = ""

    init(client: ZeusClient) {
        _loader = State(initialValue: Loader {
            let r = await client.policyRows()
            return PoliciesData(rows: r.rows, failed: r.failed)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { data in
            let rows = data.rows.filter { search.isEmpty || [$0.name, $0.source, $0.detail].contains { $0.localizedCaseInsensitiveContains(search) } }
            VStack(spacing: 0) {
                if !data.failed.isEmpty {
                    Label("Couldn't read: \(data.failed.joined(separator: ", "))", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange).frame(maxWidth: .infinity, alignment: .leading).padding([.horizontal, .top])
                }
                if data.rows.isEmpty {
                    ContentUnavailableView("No policies", systemImage: "checklist", description: Text("No admission or policy-engine rules found."))
                } else {
                    Table(rows) {
                        TableColumn("Engine", value: \.source).width(90)
                        TableColumn("Name", value: \.name)
                        TableColumn("Namespace") { Text($0.namespace ?? "—") }
                        TableColumn("Detail") { Text($0.detail) }
                    }
                }
            }
        }
        .navigationTitle("Policies")
        .searchable(text: $search, prompt: "Search policies")
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
        .task { loader.start(polling: false) }
    }
}

struct NetworkPoliciesData: Sendable { let cilium: [CiliumPolicy]; let k8s: [K8sNetworkPolicy]; let ciliumFailed: Bool }

/// Kubernetes NetworkPolicies and Cilium policies.
struct NetworkPoliciesView: View {
    enum Kind: String, CaseIterable, Identifiable { case k8s = "Kubernetes", cilium = "Cilium"; var id: String { rawValue } }
    @State private var loader: Loader<NetworkPoliciesData>
    @State private var kind = Kind.k8s
    @State private var search = ""

    init(client: ZeusClient) {
        _loader = State(initialValue: Loader {
            async let k = client.networkPolicies()
            async let c: [CiliumPolicy]? = try? await client.ciliumPolicies()
            let cilium = await c
            return try await NetworkPoliciesData(cilium: cilium ?? [], k8s: k, ciliumFailed: cilium == nil)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { data in
            VStack(spacing: 0) {
                Picker("Kind", selection: $kind) { ForEach(Kind.allCases) { Text($0.rawValue).tag($0) } }
                    .pickerStyle(.segmented).labelsHidden().padding()
                switch kind {
                case .k8s:
                    Table(data.k8s.filter { match([$0.name, $0.namespace, $0.podSelector]) }) {
                        TableColumn("Name", value: \.name)
                        TableColumn("Namespace") { Text($0.namespace ?? "—") }
                        TableColumn("Selector") { Text($0.podSelector ?? "—") }
                        TableColumn("Types") { Text($0.policyTypes?.joined(separator: ", ") ?? "—") }
                        TableColumn("In") { Text($0.ingressRules.map(String.init) ?? "—") }.width(50)
                        TableColumn("Out") { Text($0.egressRules.map(String.init) ?? "—") }.width(50)
                    }.emptyState(data.k8s.filter { match([$0.name, $0.namespace, $0.podSelector]) }.count, searching: !search.isEmpty, none: "No network policies")
                case .cilium:
                    if data.ciliumFailed {
                        ContentUnavailableView("Cilium unavailable", systemImage: "exclamationmark.triangle",
                                               description: Text("The server didn't return Cilium policies."))
                    } else {
                        Table(data.cilium.filter { match([$0.name, $0.namespace, $0.endpointSelector]) }) {
                            TableColumn("Name", value: \.name)
                            TableColumn("Namespace") { Text($0.namespace ?? "—") }
                            TableColumn("Endpoints") { Text($0.endpointSelector ?? "—") }
                            TableColumn("In") { Text($0.ingressRulesCount.map(String.init) ?? "—") }.width(50)
                            TableColumn("Out") { Text($0.egressRulesCount.map(String.init) ?? "—") }.width(50)
                            TableColumn("Age") { Text($0.age ?? "—") }.width(60)
                        }.emptyState(data.cilium.filter { match([$0.name, $0.namespace, $0.endpointSelector]) }.count, searching: !search.isEmpty, none: "No Cilium policies")
                    }
                }
            }
        }
        .navigationTitle("Network Policies")
        .searchable(text: $search, prompt: "Search")
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
        .task { loader.start(polling: false) }
    }

    private func match(_ fields: [String?]) -> Bool { search.isEmpty || fields.contains { ($0 ?? "").localizedCaseInsensitiveContains(search) } }
}
