import SwiftUI
import ZeusKit

private func yesNo(_ b: Bool?) -> String { b.map { $0 ? "Yes" : "No" } ?? "—" }

private struct Stat: View {
    let title: String, value: String
    init(_ title: String, _ value: String) { self.title = title; self.value = value }
    var body: some View {
        VStack(alignment: .leading) {
            Text(value).font(.title2.bold()).monospacedDigit()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .padding(10).frame(minWidth: 110, alignment: .leading)
        .background(.quaternary.opacity(0.5), in: .rect(cornerRadius: 8))
    }
}

private struct Section_<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            content
        }
    }
}

private func toolbarReload<T: Sendable>(_ loader: Loader<T>) -> some ToolbarContent {
    ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } }
}

// MARK: Overview and attachments

struct NetworkOverviewData: Sendable {
    let overview: NetworkOverview?, attachments: [NetworkAttachment], policies: [K8sNetworkPolicy]
}

struct NetworkOverviewView: View {
    @State private var loader: Loader<NetworkOverviewData>

    init(client: ZeusClient) {
        _loader = State(initialValue: Loader {
            async let o = try? client.networkOverview()
            async let a = client.networkAttachments()
            async let p = client.networkPolicies()
            return try await NetworkOverviewData(overview: await o, attachments: a, policies: p)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { d in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let o = d.overview {
                        HStack {
                            Stat("Policies", "\(o.totalPolicies ?? 0)")
                            Stat("Services", "\(o.totalServices ?? 0)")
                            Stat("Exposed", "\(o.exposedServices ?? 0)")
                            Stat("Internal", "\(o.internalServices ?? 0)")
                            Stat("Isolated namespaces", "\(o.isolatedNamespaces ?? 0)")
                        }
                    }
                    Section_(title: "Network attachments") {
                        if d.attachments.isEmpty {
                            Text("No Multus network attachments defined.").foregroundStyle(.secondary)
                        } else {
                            Table(d.attachments) {
                                TableColumn("Name", value: \.name)
                                TableColumn("Namespace", value: \.namespace)
                                TableColumn("CNI") { Text($0.cniType ?? "—") }
                                TableColumn("Bridge / master") { Text($0.bridgeName ?? $0.master ?? $0.resourceName ?? "—") }
                                TableColumn("VLAN") { Text($0.vlan.map(String.init) ?? "—") }
                                TableColumn("Static addresses") { Text(($0.staticAddresses ?? []).joined(separator: ", ")) }
                                TableColumn("Age") { Text($0.age ?? "—") }
                            }.frame(minHeight: 160)
                        }
                    }
                    Section_(title: "Network policies") {
                        Table(d.policies) {
                            TableColumn("Name", value: \.name)
                            TableColumn("Namespace") { Text($0.namespace ?? "—") }
                            TableColumn("Types") { Text(($0.policyTypes ?? []).joined(separator: ", ")) }
                            TableColumn("Ingress rules") { Text("\($0.ingressRules ?? 0)") }.width(min: 90, ideal: 100)
                            TableColumn("Egress rules") { Text("\($0.egressRules ?? 0)") }.width(min: 90, ideal: 100)
                        }.frame(minHeight: 220)
                    }
                }.padding()
            }
        }
        .navigationTitle("Network")
        .toolbar { toolbarReload(loader) }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}

// MARK: Services and ingress

struct ServicesData: Sendable {
    let services: [MappedService], ingresses: [IngressInfo], pools: [IPAddressPool]
}

struct ServicesIngressView: View {
    @State private var loader: Loader<ServicesData>
    @State private var search = ""
    @State private var onlyExposed = false

    init(client: ZeusClient) {
        _loader = State(initialValue: Loader {
            async let s = client.serviceMap()
            async let i = client.ingresses()
            async let p = client.metallbPools()
            return try await ServicesData(services: s.services, ingresses: i, pools: p)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { d in
            let rows = d.services.filter { !onlyExposed || $0.isExposed }
                .filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) || $0.namespace.localizedCaseInsensitiveContains(search) }
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Section_(title: "Services (\(rows.count))") {
                        Table(rows) {
                            TableColumn("Name", value: \.name)
                            TableColumn("Namespace", value: \.namespace)
                            TableColumn("Type") { Text($0.serviceType ?? "—") }
                            TableColumn("Endpoints") { Text(($0.endpoints ?? []).joined(separator: ", ")).lineLimit(1) }
                            TableColumn("Health") { Text($0.healthStatus ?? "—") }.width(80)
                        }.frame(minHeight: 300)
                    }
                    Section_(title: "Ingresses") {
                        if d.ingresses.isEmpty {
                            Text("No ingresses.").foregroundStyle(.secondary)
                        } else {
                            Table(d.ingresses) {
                                TableColumn("Name", value: \.name)
                                TableColumn("Namespace", value: \.namespace)
                                TableColumn("Hosts") { Text(($0.hosts ?? []).joined(separator: ", ")) }
                                TableColumn("Class") { Text($0.ingressClass ?? "—") }
                                TableColumn("TLS") { Text(yesNo($0.tlsEnabled)) }.width(50)
                            }.frame(minHeight: 120)
                        }
                    }
                    Section_(title: "MetalLB address pools") {
                        if d.pools.isEmpty {
                            Text("No MetalLB pools.").foregroundStyle(.secondary)
                        } else {
                            Table(d.pools) {
                                TableColumn("Name", value: \.name)
                                TableColumn("Addresses") { Text(($0.addresses ?? []).joined(separator: ", ")) }
                                TableColumn("Auto-assign") { Text(yesNo($0.autoAssign)) }.width(90)
                            }.frame(minHeight: 120)
                        }
                    }
                }.padding()
            }
        }
        .navigationTitle("Services & Ingress")
        .searchable(text: $search, prompt: "Search services")
        .toolbar {
            ToolbarItem { Toggle("Exposed only", systemImage: "arrow.up.right.square", isOn: $onlyExposed) }
            toolbarReload(loader)
        }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}

// MARK: Cilium

struct CiliumData: Sendable {
    let status: CiliumStatus, encryption: CiliumEncryption?, endpoints: [CiliumEndpoint]
}

struct CiliumView: View {
    @State private var loader: Loader<CiliumData>
    @State private var search = ""

    init(client: ZeusClient) {
        _loader = State(initialValue: Loader {
            async let s = client.ciliumStatus()
            async let e = try? client.ciliumEncryption()
            async let p = client.ciliumEndpoints()
            return try await CiliumData(status: s, encryption: await e, endpoints: p)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { d in
            let rows = d.endpoints.filter {
                search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) || $0.namespace.localizedCaseInsensitiveContains(search)
                    || ($0.ip ?? "").contains(search) || $0.appLabels.contains { $0.localizedCaseInsensitiveContains(search) }
            }
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Stat("Installed", yesNo(d.status.installed))
                    Stat("Enforcement", d.status.enforcementMode ?? "—")
                    Stat("Policies", "\(d.status.policyCount ?? 0)")
                    Stat("Endpoints", "\(d.status.endpointCount ?? 0)")
                    Stat("Hubble", yesNo(d.status.hubbleAvailable))
                    if let e = d.encryption {
                        Stat("WireGuard", yesNo(e.wireguardEnabled))
                        Stat("Agents ready", "\(e.daemonsetReady ?? 0)/\(e.daemonsetDesired ?? 0)")
                    }
                }
                Table(rows) {
                    TableColumn("Endpoint", value: \.name)
                    TableColumn("Namespace", value: \.namespace)
                    TableColumn("Identity") { Text($0.identityId.map(String.init) ?? "—") }.width(70)
                    TableColumn("IP") { Text($0.ip ?? "—") }
                    TableColumn("State") { Text($0.state ?? "—") }.width(80)
                    TableColumn("Labels") { Text($0.appLabels.joined(separator: ", ")).lineLimit(1).help($0.appLabels.joined(separator: "\n")) }
                }.emptyState(rows.count, searching: !search.isEmpty, none: "No Cilium endpoints")
            }.padding()
        }
        .navigationTitle("Cilium")
        .searchable(text: $search, prompt: "Search endpoints")
        .toolbar { toolbarReload(loader) }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}

// MARK: PacketWolf shield

struct ShieldData: Sendable { let status: PacketWolfStatus?, vms: [ShieldVM] }

struct ShieldView: View {
    @State private var loader: Loader<ShieldData>

    init(client: ZeusClient) {
        _loader = State(initialValue: Loader {
            async let s = try? client.packetWolfStatus()
            async let v = client.shieldVMs()
            return try await ShieldData(status: await s, vms: v.vms)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { d in
            VStack(alignment: .leading, spacing: 12) {
                if let s = d.status {
                    HStack {
                        Stat("Configured", yesNo(s.configured))
                        Stat("Reachable", yesNo(s.reachable))
                        Stat("Authorized", yesNo(s.apiAuthorized))
                    }
                    if s.configured == false, let m = s.message {
                        Text(m).font(.callout).foregroundStyle(.secondary)
                    }
                }
                if d.vms.isEmpty {
                    ContentUnavailableView("No VMs", systemImage: "shield", description: Text("No VMs reported by the shield."))
                } else {
                    Table(d.vms) {
                        TableColumn("VM", value: \.name)
                        TableColumn("Namespace", value: \.namespace)
                        TableColumn("Node") { Text($0.nodeName ?? "—") }
                        TableColumn("Guest IP") { Text($0.guestIp ?? "—") }
                        TableColumn("Visibility") { Text($0.visibility ?? "—") }
                        TableColumn("Enforcement") { Text($0.enforcement ?? "—") }
                        TableColumn("Flows") { Text($0.totalFlows.map(String.init) ?? "—") }.width(60)
                        TableColumn("Dropped") { Text($0.droppedFlows.map(String.init) ?? "—") }.width(70)
                        TableColumn("Risk") { Text($0.riskLevel ?? "—") }.width(70)
                    }
                }
            }.padding()
        }
        .navigationTitle("VM Shield")
        .toolbar { toolbarReload(loader) }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}

// MARK: DNS and IPAM

struct DNSIPAMData: Sendable { let dns: DNSOverrides?, pools: [IPAMPool] }

struct DNSIPAMView: View {
    @State private var loader: Loader<DNSIPAMData>

    init(client: ZeusClient) {
        _loader = State(initialValue: Loader {
            async let d = try? client.dnsOverrides()
            async let p = client.ipamPools()
            return try await DNSIPAMData(dns: await d, pools: p.pools)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { d in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Section_(title: "DNS overrides") {
                        if let dns = d.dns {
                            HStack {
                                Stat("Supported", yesNo(dns.supported))
                                Stat("Managed", yesNo(dns.managed))
                                Stat("Records", "\(dns.records?.count ?? 0)/\(dns.maxRecords ?? 0)")
                            }
                            if let n = dns.note { Text(n).font(.callout).foregroundStyle(.secondary) }
                        } else {
                            Text("DNS state unavailable.").foregroundStyle(.secondary)
                        }
                    }
                    Section_(title: "IPAM pools") {
                        if d.pools.isEmpty {
                            Text("No IPAM pools.").foregroundStyle(.secondary)
                        } else {
                            Table(d.pools) {
                                TableColumn("Name", value: \.name)
                                TableColumn("CIDR") { Text($0.cidr ?? "—") }
                                TableColumn("Gateway") { Text($0.gateway ?? "—") }
                                TableColumn("VLAN") { Text($0.vlan.map(String.init) ?? "—") }
                                TableColumn("Assignments") { Text("\($0.assignments?.count ?? 0)") }
                            }.frame(minHeight: 160)
                        }
                    }
                }.padding()
            }
        }
        .navigationTitle("DNS & IPAM")
        .toolbar { toolbarReload(loader) }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}
