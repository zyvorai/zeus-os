import SwiftUI
import ZeusKit

private struct Reloadable<Body: View>: ViewModifier {
    let title: String
    let reload: () async -> Void
    let start: () -> Void
    let stop: () -> Void
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await reload() } } } }
            .task { start() }
            .onDisappear { stop() }
    }
}

private extension View {
    func screen<T: Sendable>(_ title: String, _ loader: Loader<T>) -> some View {
        modifier(Reloadable<EmptyView>(title: title, reload: { await loader.reload() }, start: { loader.start() }, stop: { loader.stop() }))
    }
}

private func status(_ on: Bool, _ yes: String, _ no: String) -> some View {
    Label(on ? yes : no, systemImage: on ? "checkmark.circle.fill" : "circle").foregroundStyle(on ? .green : .secondary)
}

// MARK: Users and sessions

struct UsersData: Sendable { let users: [AuthUser]; let sessions: [AuthSession]; let sso: SSOStatus? }

struct UsersView: View {
    @State private var loader: Loader<UsersData>
    @State private var sort = [KeyPathComparator(\AuthSession.createdSort, order: .reverse)]

    init(client: ZeusClient) {
        _loader = State(initialValue: Loader {
            async let u = client.authUsers()
            async let s = try? client.authSessions()
            async let sso = try? client.ssoStatus()
            return try await UsersData(users: u, sessions: await s ?? [], sso: await sso)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { data in
            VStack(spacing: 0) {
                if let s = data.sso {
                    HStack(spacing: 16) {
                        Text("Auth mode: \(s.mode ?? "unknown")")
                        status(s.oidcConfigured, "OIDC configured", "OIDC not configured")
                        status(s.ldapConfigured, "LDAP configured", "LDAP not configured")
                        status(s.webauthnEnabled, "WebAuthn on (\(s.webauthnCredentials))", "WebAuthn off")
                        Spacer()
                    }.font(.callout).padding()
                }
                Table(data.users) {
                    TableColumn("User", value: \.username)
                    TableColumn("Role") { Text($0.role ?? "—") }
                }.frame(maxHeight: 180)
                Text("Active sessions (\(data.sessions.count))").font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading).padding([.horizontal, .top])
                if data.sessions.isEmpty {
                    ContentUnavailableView("No sessions", systemImage: "person.badge.clock")
                } else {
                    Table(data.sessions.sorted(using: sort), sortOrder: $sort) {
                        TableColumn("Subject") { Text($0.subject ?? "—") }
                        TableColumn("Role") { Text($0.role ?? "—") }
                        TableColumn("Started", value: \.createdSort) { s in
                            if let d = s.created { Text(d, format: .dateTime.month().day().hour().minute()) } else { Text("—") }
                        }
                        TableColumn("Session") { Text($0.sessionId.prefix(8)).monospaced() }
                    }
                }
            }
        }
        .screen("Users & Sessions", loader)
    }
}

// MARK: API tokens

struct APITokensView: View {
    @State private var loader: Loader<[APIToken]>
    init(client: ZeusClient) { _loader = State(initialValue: Loader { try await client.apiTokens() }) }

    var body: some View {
        LoadStateView(loader: loader) { tokens in
            if tokens.isEmpty {
                ContentUnavailableView("No API tokens", systemImage: "key",
                                       description: Text("Token values are never shown in this app."))
            } else {
                Table(tokens) {
                    TableColumn("Name") { Text($0.name ?? $0.id) }
                    TableColumn("Scopes") { Text($0.scopes.isEmpty ? "—" : $0.scopes.joined(separator: ", ")).lineLimit(1) }
                    TableColumn("Created") { Text($0.createdAt ?? "—") }
                    TableColumn("Last used") { Text($0.lastUsedAt ?? "never") }
                    TableColumn("Expires") { Text($0.expiresAt ?? "—") }
                }
            }
        }
        .screen("API Tokens", loader)
    }
}

// MARK: Fleet

struct FleetView: View {
    @State private var loader: Loader<FleetData>
    init(client: ZeusClient) { _loader = State(initialValue: Loader { try await client.fleet() }) }

    var body: some View {
        LoadStateView(loader: loader) { data in
            VStack(spacing: 0) {
                if let s = data.stats {
                    Text("\(s.totalClusters ?? data.clusters.count) clusters · \(s.connectedClusters ?? 0) connected · \(s.failingClusters ?? 0) failing · \(s.totalNodes ?? 0) nodes · \(s.totalVMs ?? 0) VMs")
                        .font(.callout).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading).padding()
                }
                if data.clusters.isEmpty {
                    ContentUnavailableView("No clusters", systemImage: "square.stack.3d.up")
                } else {
                    Table(data.clusters) {
                        TableColumn("Cluster") { Text($0.name + (($0.isLocal ?? false) ? " (local)" : "")) }
                        TableColumn("Status") { Text($0.status ?? "—") }
                        TableColumn("Version") { Text($0.version ?? "—") }
                        TableColumn("Region") { Text($0.region ?? "—") }
                        TableColumn("Nodes") { Text("\($0.readyNodes ?? 0)/\($0.nodes ?? 0)") }
                        TableColumn("VMs") { Text("\($0.runningVMs ?? 0)/\($0.vms ?? 0)") }
                        TableColumn("CPU") { Text($0.cpuCores.map { String(format: "%.0f", $0) } ?? "—") }
                        TableColumn("Memory") { Text($0.memoryGB.map { String(format: "%.0f GB", $0) } ?? "—") }
                        TableColumn("Health") { Text($0.healthScore.map { String(format: "%.0f", $0) } ?? "—").help($0.healthReason ?? "") }
                    }
                }
            }
        }
        .screen("Fleet", loader)
    }
}

// MARK: Nodes and hosts

struct NodesData: Sendable { let nodes: [ClusterNode]; let host: HostInfo?; let connections: [HypervisorConnection] }

struct NodesView: View {
    @State private var loader: Loader<NodesData>
    init(client: ZeusClient) {
        _loader = State(initialValue: Loader {
            async let n = client.clusterNodes()
            async let h = try? client.hostInfo()
            async let c = try? client.hypervisorConnections()
            return try await NodesData(nodes: n, host: await h, connections: await c ?? [])
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { data in
            VStack(spacing: 0) {
                Table(data.nodes) {
                    TableColumn("Node", value: \.name)
                    TableColumn("Status") { Text($0.status ?? "—") }
                    TableColumn("Roles") { Text($0.roles.joined(separator: ", ")) }
                    TableColumn("Scheduling") { n in
                        Label(n.schedulable == false ? "Cordoned" : "Schedulable",
                              systemImage: n.schedulable == false ? "nosign" : "checkmark.circle")
                            .foregroundStyle(n.schedulable == false ? .orange : .primary)
                    }
                    TableColumn("Version") { Text($0.version ?? "—") }
                    TableColumn("CPU") { Text($0.cpuCapacity ?? "—") }
                    TableColumn("Memory") { n in
                        Text(n.memoryBytes.map { Measurement(value: $0, unit: UnitInformationStorage.bytes).formatted(.byteCount(style: .memory)) } ?? "—")
                    }
                    TableColumn("Age") { Text($0.age ?? "—") }
                }
                Form {
                    if let h = data.host {
                        Section("Host the control plane runs on") {
                            LabeledContent("Hostname", value: h.hostname ?? "—")
                            LabeledContent("OS", value: h.osPrettyName ?? "—")
                            LabeledContent("Kernel", value: h.kernelVersion ?? "—")
                            LabeledContent("CPU", value: "\(h.cpuModel ?? "—") (\(h.cpuCores ?? 0) cores)")
                            LabeledContent("Hardware", value: [h.systemVendor, h.productName].compactMap { $0 }.joined(separator: " "))
                            LabeledContent("BIOS", value: [h.biosVendor, h.biosVersion].compactMap { $0 }.joined(separator: " "))
                        }
                    }
                    Section("Hypervisor connections") {
                        if data.connections.isEmpty { Text("None configured").foregroundStyle(.secondary) }
                        ForEach(data.connections) { Text([$0.name, $0.kind, $0.status].compactMap { $0 }.joined(separator: " · ")) }
                    }
                }.formStyle(.grouped)
            }
        }
        .screen("Nodes & Hosts", loader)
    }
}

// MARK: Platform

struct PlatformData: Sendable {
    let plugins: [PluginInfo]; let destinations: [LogDestination]; let rules: [LogShipRule]; let maintenance: MaintenanceData?
}

struct PlatformView: View {
    @State private var loader: Loader<PlatformData>
    init(client: ZeusClient) {
        _loader = State(initialValue: Loader {
            async let p = try? client.plugins()
            async let d = try? client.logDestinations()
            async let r = try? client.logShipRules()
            async let m = try? client.maintenanceWindows()
            return await PlatformData(plugins: p ?? [], destinations: d ?? [], rules: r ?? [], maintenance: m)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { data in
            Form {
                Section("Plugins") {
                    if data.plugins.isEmpty { Text("No plugins installed").foregroundStyle(.secondary) }
                    ForEach(data.plugins) { p in
                        LabeledContent(p.displayName ?? p.id) {
                            VStack(alignment: .trailing) {
                                Text("\(p.enabled == false ? "Disabled" : "Enabled") · v\(p.version ?? "?") · \(p.deliveryCount ?? 0) deliveries")
                                if let r = p.disabledReason, !r.isEmpty { Text(r).font(.caption).foregroundStyle(.orange) }
                            }
                        }
                    }
                }
                Section("Log shipping destinations") {
                    if data.destinations.isEmpty { Text("None configured").foregroundStyle(.secondary) }
                    ForEach(data.destinations) { d in
                        LabeledContent(d.name ?? d.id) { Text("\(d.kind ?? "—") · \(d.enabled == false ? "off" : "on") · \(d.url ?? "")") }
                    }
                }
                Section("Log shipping rules") {
                    if data.rules.isEmpty { Text("No rules reporting status").foregroundStyle(.secondary) }
                    ForEach(data.rules) { r in
                        LabeledContent(r.ruleId) {
                            Text("\(r.linesShipped ?? 0) lines" + ((r.lastError ?? "").isEmpty ? "" : " · \(r.lastError ?? "")"))
                        }
                    }
                }
                Section("Maintenance windows") {
                    if let n = data.maintenance?.note { Text(n).font(.callout).foregroundStyle(.secondary) }
                    if data.maintenance?.windows.isEmpty ?? true { Text("No windows defined").foregroundStyle(.secondary) }
                    ForEach(data.maintenance?.windows ?? []) { w in
                        LabeledContent(w.name ?? w.id) { Text("\(w.startTime ?? "—") to \(w.endTime ?? "—")") }
                    }
                }
            }.formStyle(.grouped)
        }
        .screen("Platform", loader)
    }
}
