import SwiftUI
import ZeusKit

struct AccessData: Sendable {
    let roles: [RBACRole], bindings: [RBACBinding], accounts: [RBACServiceAccount], analysis: RBACAnalysis?
}

/// Read-only RBAC: roles, bindings, service accounts and the server's findings.
struct AccessView: View {
    enum Tab: String, CaseIterable, Identifiable { case roles = "Roles", bindings = "Bindings", accounts = "Service Accounts", findings = "Findings"; var id: String { rawValue } }

    @State private var loader: Loader<AccessData>
    @State private var tab = Tab.roles
    @State private var search = ""

    init(client: ZeusClient) {
        _loader = State(initialValue: Loader {
            async let r = client.rbacRoles(), b = client.rbacBindings(), s = client.rbacServiceAccounts()
            async let a = try? client.rbacAnalysis()
            return try await AccessData(roles: r, bindings: b, accounts: s, analysis: await a)
        })
    }

    private func match(_ fields: [String?]) -> Bool { search.isEmpty || fields.contains { ($0 ?? "").localizedCaseInsensitiveContains(search) } }

    var body: some View {
        LoadStateView(loader: loader) { data in
            VStack(spacing: 0) {
                Picker("View", selection: $tab) { ForEach(Tab.allCases) { Text($0.rawValue).tag($0) } }
                    .pickerStyle(.segmented).labelsHidden().padding()
                switch tab {
                case .roles:
                    Table(data.roles.filter { match([$0.name, $0.namespace]) }) {
                        TableColumn("Name", value: \.name)
                        TableColumn("Scope") { Text($0.isClusterRole ? "Cluster" : ($0.namespace ?? "—")) }
                        TableColumn("Rules") { Text($0.rulesCount.map(String.init) ?? "—") }.width(60)
                    }.emptyState(data.roles.filter { match([$0.name, $0.namespace]) }.count, searching: !search.isEmpty, none: "No roles")
                case .bindings:
                    Table(data.bindings.filter { match([$0.name, $0.roleName, $0.namespace]) }) {
                        TableColumn("Name", value: \.name)
                        TableColumn("Scope") { Text($0.isClusterBinding ? "Cluster" : ($0.namespace ?? "—")) }
                        TableColumn("Role") { Text([$0.roleKind, $0.roleName].compactMap { $0 }.joined(separator: " ")) }
                        TableColumn("Subjects") { Text($0.subjectsCount.map(String.init) ?? "—") }.width(70)
                    }.emptyState(data.bindings.filter { match([$0.name, $0.roleName, $0.namespace]) }.count, searching: !search.isEmpty, none: "No bindings")
                case .accounts:
                    Table(data.accounts.filter { match([$0.name, $0.namespace]) }) {
                        TableColumn("Name", value: \.name)
                        TableColumn("Namespace", value: \.namespace)
                        TableColumn("Secrets") { Text($0.secretsCount.map(String.init) ?? "—") }.width(70)
                    }.emptyState(data.accounts.filter { match([$0.name, $0.namespace]) }.count, searching: !search.isEmpty, none: "No service accounts")
                case .findings:
                    findings(data.analysis)
                }
            }
        }
        .navigationTitle("Access")
        .searchable(text: $search, prompt: "Search")
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
        .task { loader.start(polling: false) }
    }

    @ViewBuilder private func findings(_ a: RBACAnalysis?) -> some View {
        if let a {
            List {
                Section("Totals") {
                    LabeledContent("Roles", value: "\(a.totalRoles ?? 0) namespaced, \(a.totalClusterRoles ?? 0) cluster")
                    LabeledContent("Bindings", value: "\(a.totalRoleBindings ?? 0) namespaced, \(a.totalClusterRoleBindings ?? 0) cluster")
                    LabeledContent("Service accounts", value: "\(a.totalServiceAccounts ?? 0)")
                }
                Section("Overly permissive roles (\(a.overlyPermissiveRoles.count))") {
                    ForEach(a.overlyPermissiveRoles) { p in
                        LabeledContent(p.roleName) { Text("\(p.severity ?? "") · \(p.reason ?? "")").foregroundStyle(.secondary) }
                    }
                }
                Section("Privileged bindings (\(a.privilegedBindings.count))") {
                    ForEach(a.privilegedBindings) { p in
                        LabeledContent(p.bindingName) { Text("\(p.riskLevel ?? "") · \(p.roleName ?? "")").foregroundStyle(.secondary) }
                    }
                }
                Section("Unused service accounts (\(a.unusedServiceAccounts.count))") {
                    ForEach(a.unusedServiceAccounts, id: \.self) { Text($0) }
                }
            }
        } else {
            ContentUnavailableView("Analysis unavailable", systemImage: "exclamationmark.triangle")
        }
    }
}
