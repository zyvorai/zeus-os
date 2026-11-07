import SwiftUI
import ZeusKit

// Read-only screens for the platform, admin, licensing, ACL, search and integration endpoints.
// Every free-form response goes through `ZeusClient.tailJSON`, which drops secret-looking keys and values.

extension Destination {
    static let tailPlatform: [Destination] = [
        Destination("Platform Admin", symbol: "gearshape.2", group: "Platform") { PlatformAdminView(client: $0) },
        Destination("Licensing & Onboarding", symbol: "checkmark.seal", group: "Platform") { LicensingOnboardingView(client: $0) },
        Destination("ACLs & Search", symbol: "magnifyingglass", group: "Platform") { ACLSearchView(client: $0) },
        Destination("Integrations", symbol: "puzzlepiece.extension", group: "Platform") { IntegrationsView(client: $0) },
    ]
}

/// One read-only JSON endpoint.
struct TailSource: Identifiable, Hashable {
    let title: String
    let path: [String]
    var id: String { title }
}

/// Shows one source: an array as a searchable table, an object as an outline.
struct TailSourceView: View {
    @State private var loader: Loader<JSONValue>
    let emptyTitle: String

    init(client: ZeusClient, source: TailSource) {
        emptyTitle = "No \(source.title.lowercased())"
        _loader = State(initialValue: Loader { try await client.tailJSON(source.path) })
    }

    var body: some View {
        LoadStateView(loader: loader) { value in
            if let rows = value.array {
                JSONTable(rows: rows, emptyTitle: emptyTitle, emptyDescription: "The server returned an empty list.")
            } else {
                List { JSONOutline(value: value) }
            }
        }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}

// MARK: Platform Admin

struct PlatformStatusData: Sendable { let stats: ServerStats?; let preflight: PlatformPreflight? }

struct PlatformStatusView: View {
    @State private var loader: Loader<PlatformStatusData>
    init(client: ZeusClient) {
        _loader = State(initialValue: Loader {
            async let s = try? client.serverStats()
            async let p = try? client.platformPreflight()
            return await PlatformStatusData(stats: s, preflight: p)
        })
    }

    private func flag(_ v: Bool?, _ yes: String, _ no: String) -> some View {
        Label(v == nil ? "Unknown" : (v! ? yes : no), systemImage: v == true ? "checkmark.circle.fill" : "circle")
            .foregroundStyle(v == true ? .green : .secondary)
    }

    var body: some View {
        LoadStateView(loader: loader) { d in
            Form {
                if let s = d.stats {
                    Section("Server") {
                        LabeledContent("Uptime", value: Duration.seconds(s.uptimeSecs ?? 0).formatted(.units(allowed: [.days, .hours, .minutes], width: .abbreviated)))
                        LabeledContent("Requests", value: "\(s.requestsTotal ?? 0)")
                        LabeledContent("Errors", value: "\(s.errorsTotal ?? 0)")
                        LabeledContent("Average latency", value: "\(Int(s.avgLatencyMs ?? 0)) ms")
                        LabeledContent("Requests per second", value: (s.requestsPerSec ?? 0).formatted(.number.precision(.fractionLength(2))))
                        LabeledContent("Active sessions", value: "\(s.activeSessions ?? 0)")
                        LabeledContent("Live WebSockets", value: "\(s.activeWs ?? 0)")
                    }
                }
                if let p = d.preflight {
                    Section("Platform preflight") {
                        LabeledContent("Velero") { flag(p.veleroInstalled, "Installed", "Not installed") }
                        LabeledContent("CSI snapshot CRDs") { flag(p.csiSnapshotCrdPresent, "Present", "Missing") }
                        LabeledContent("Snapshot controller") { flag(p.snapshotControllerReady, "Ready", "Not ready") }
                        LabeledContent("MetalLB") { flag(p.metallbApiPresent, "\(p.metallbAddressPoolCount ?? 0) pools", "Not detected") }
                        LabeledContent("Snapshot classes", value: "\(p.volumeSnapshotClassCount ?? 0)")
                        LabeledContent("Stuck snapshots", value: "\(p.stuckVolumeSnapshots ?? 0)")
                        LabeledContent("Default storage class", value: p.defaultStorageClass ?? "—")
                        LabeledContent("Default snapshot class", value: p.defaultVolumeSnapshotClass ?? "—")
                    }
                    if !p.warnings.isEmpty {
                        Section("Warnings") { ForEach(p.warnings, id: \.self) { Label($0, systemImage: "exclamationmark.triangle").foregroundStyle(.orange) } }
                    }
                    if !p.hints.isEmpty {
                        Section("Hints") { ForEach(p.hints, id: \.self) { Text($0).foregroundStyle(.secondary) } }
                    }
                }
                if d.stats == nil && d.preflight == nil {
                    ContentUnavailableView("Not available", systemImage: "lock", description: Text("Your role can't view server status."))
                }
            }.formStyle(.grouped)
        }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}

struct PlatformAdminView: View {
    let client: ZeusClient
    private static let status = "Status"
    private static let sources: [TailSource] = [
        .init(title: "Overview", path: ["dashboard", "overview"]),
        .init(title: "Infrastructure status", path: ["dashboard", "infrastructure-status"]),
        .init(title: "Client config", path: ["client-config"]),
        .init(title: "Config endpoints", path: ["configs"]),
        .init(title: "Infrastructure tree", path: ["infra", "tree"]),
        .init(title: "Host groups", path: ["host-groups"]),
        .init(title: "Provider portal", path: ["zeus", "provider", "portal"]),
        .init(title: "Migration waves", path: ["platform", "migration-waves"]),
        .init(title: "Network profiles", path: ["platform", "network-profiles"]),
        .init(title: "Protection plans", path: ["platform", "protection-plans"]),
        .init(title: "Storage profiles", path: ["platform", "storage-profiles"]),
        .init(title: "Workload profiles", path: ["platform", "workload-profiles"]),
        .init(title: "Gateway classes", path: ["gateway-api", "gateway-classes"]),
        .init(title: "Gateways", path: ["gateway-api", "gateways"]),
        .init(title: "HTTP routes", path: ["gateway-api", "http-routes"]),
    ]
    @State private var selected = PlatformAdminView.status

    var body: some View {
        Group {
            if selected == Self.status { PlatformStatusView(client: client) }
            else if let s = Self.sources.first(where: { $0.id == selected }) { TailSourceView(client: client, source: s).id(s.id) }
        }
        .navigationTitle("Platform Admin")
        .toolbar {
            ToolbarItem {
                Picker("Section", selection: $selected) {
                    Text(Self.status).tag(Self.status)
                    ForEach(Self.sources) { Text($0.title).tag($0.id) }
                }.pickerStyle(.menu)
            }
        }
    }
}

// MARK: Licensing & Onboarding

struct LicensingOnboardingData: Sendable { let license: LicensingInventory?; let onboarding: OnboardingState? }

struct LicensingOnboardingView: View {
    @State private var loader: Loader<LicensingOnboardingData>
    init(client: ZeusClient) {
        _loader = State(initialValue: Loader {
            async let l = try? client.licensingInventory()
            async let o = try? client.onboardingState()
            return await LicensingOnboardingData(license: l, onboarding: o)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { d in
            VStack(spacing: 0) {
                Form {
                    if let l = d.license {
                        Section("Windows licensing") {
                            LabeledContent("Windows machines", value: "\(l.totalWindowsVMs)")
                            LabeledContent("Guest agent connected", value: "\(l.agentConnected)")
                            LabeledContent("Activated", value: "\(l.activated)")
                            LabeledContent("KMS clients", value: "\(l.kmsClients)")
                        }
                    }
                    if let o = d.onboarding {
                        Section("Onboarding (your account)") {
                            LabeledContent("Completed tasks", value: o.completedTaskIds.isEmpty ? "None" : o.completedTaskIds.joined(separator: ", "))
                            LabeledContent("Tour", value: o.tourCompleted ? "Completed" : "Not completed")
                            LabeledContent("Banner", value: o.bannerDismissed ? "Dismissed" : "Showing")
                        }
                    }
                }.formStyle(.grouped).frame(maxHeight: d.license?.vms.isEmpty == false ? 260 : .infinity)
                if let l = d.license, !l.vms.isEmpty { JSONTable(rows: l.vms) }
            }
        }
        .navigationTitle("Licensing & Onboarding")
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}

// MARK: ACLs & Search

struct ACLSearchView: View {
    let client: ZeusClient
    @State private var mode = "Object ACLs"
    @State private var query = ""
    @State private var submitted = ""

    var body: some View {
        VStack(spacing: 0) {
            if mode == "Object ACLs" {
                TailSourceView(client: client, source: .init(title: "Object ACLs", path: ["object-acls"]))
            } else {
                TextField("Search machines, namespaces, alerts…", text: $query)
                    .textFieldStyle(.roundedBorder).padding()
                    .onSubmit { submitted = query.trimmingCharacters(in: .whitespaces) }
                if submitted.isEmpty {
                    ContentUnavailableView("Universal search", systemImage: "magnifyingglass", description: Text("Type a term and press Return."))
                } else {
                    SearchResultsView(client: client, text: submitted).id(submitted)
                }
            }
        }
        .navigationTitle("ACLs & Search")
        .toolbar {
            ToolbarItem {
                Picker("Section", selection: $mode) {
                    Text("Object ACLs").tag("Object ACLs"); Text("Universal search").tag("Universal search")
                }.pickerStyle(.segmented)
            }
        }
    }
}

private struct SearchResultsView: View {
    @State private var loader: Loader<[JSONValue]>
    init(client: ZeusClient, text: String) {
        _loader = State(initialValue: Loader { try await client.universalSearch(text) })
    }
    var body: some View {
        LoadStateView(loader: loader) { JSONTable(rows: $0, emptyTitle: "No results", emptyDescription: "Nothing matched.") }
            .task { loader.start(polling: false) }
    }
}

// MARK: Integrations

struct IntegrationsView: View {
    let client: ZeusClient
    private static let graphql = "GraphQL"
    private static let mcp = "MCP"
    private static let sources: [TailSource] = [
        .init(title: "API versions", path: ["api-versioning", "versions"]),
        .init(title: "Endpoints", path: ["api-versioning", "endpoints"]),
        .init(title: "Usage analytics", path: ["api-versioning", "usage-analytics"]),
        .init(title: "API clients", path: ["api-versioning", "clients"]),
        .init(title: "Breaking changes", path: ["api-versioning", "breaking-changes"]),
        .init(title: "Deprecation notices", path: ["api-versioning", "deprecation-notices"]),
        .init(title: "Migration guides", path: ["api-versioning", "migration-guides"]),
    ]
    @State private var selected = IntegrationsView.sources[0].id

    var body: some View {
        Group {
            if selected == Self.graphql { GraphQLView(client: client) }
            else if selected == Self.mcp {
                ContentUnavailableView("MCP", systemImage: "network", description: Text("The MCP endpoint accepts POST only, so the app doesn't query it. SCIM and its schemas are not served by this server."))
            } else if let s = Self.sources.first(where: { $0.id == selected }) { TailSourceView(client: client, source: s).id(s.id) }
        }
        .navigationTitle("Integrations")
        .toolbar {
            ToolbarItem {
                Picker("Section", selection: $selected) {
                    ForEach(Self.sources) { Text($0.title).tag($0.id) }
                    Text("GraphQL capabilities").tag(Self.graphql)
                    Text("MCP and SCIM").tag(Self.mcp)
                }.pickerStyle(.menu)
            }
        }
    }
}

private struct GraphQLView: View {
    @State private var loader: Loader<GraphQLCapabilities>
    init(client: ZeusClient) { _loader = State(initialValue: Loader { try await client.graphQLCapabilities() }) }
    var body: some View {
        LoadStateView(loader: loader) { g in
            Form {
                Section("Query fields (read-only; the app never runs queries)") {
                    ForEach(g.queryFields) { f in
                        LabeledContent(f.name) {
                            VStack(alignment: .trailing) {
                                Text(f.type).font(.body.monospaced())
                                if let s = f.summary { Text(s).font(.caption).foregroundStyle(.secondary) }
                            }
                        }
                    }
                }
                Section("Types") { Text(g.typeNames.joined(separator: ", ")).foregroundStyle(.secondary) }
            }.formStyle(.grouped)
        }
        .task { loader.start(polling: false) }
    }
}
