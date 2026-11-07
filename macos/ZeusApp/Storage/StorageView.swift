import SwiftUI
import ZeusKit

private func gi(_ v: Double?) -> String { v.map { "\($0.formatted(.number.precision(.fractionLength(0...1)))) Gi" } ?? "—" }

struct StorageData: Sendable {
    let overview: StorageOverview?
    let classes: [StorageClass]
    let claims: [StorageClaim]
    let volumes: [StorageVolume]
}

/// Read-only storage explorer: capacity, storage classes, claims and volumes.
struct StorageView: View {
    let client: ZeusClient
    @State private var loader: Loader<StorageData>
    @State private var tab = Tab.claims
    @State private var search = ""

    enum Tab: String, CaseIterable, Identifiable { case claims = "Claims", volumes = "Volumes", classes = "Classes"; var id: String { rawValue } }

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader {
            async let o = try? client.storageOverview()
            async let c = client.storageClasses()
            async let p = client.storageClaims()
            async let v = client.storageVolumes()
            return try await StorageData(overview: await o, classes: c, claims: p, volumes: v)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { data in
            VStack(spacing: 0) {
                if let o = data.overview { capacity(o) }
                Picker("Show", selection: $tab) { ForEach(Tab.allCases) { Text($0.rawValue).tag($0) } }
                    .pickerStyle(.segmented).labelsHidden().padding(.horizontal).padding(.bottom, 8)
                switch tab {
                case .claims: claims(data.claims)
                case .volumes: volumes(data.volumes)
                case .classes: classes(data.classes)
                }
            }
        }
        .navigationTitle("Storage")
        .searchable(text: $search, prompt: "Search storage")
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }

    private func matches(_ fields: String?...) -> Bool {
        search.isEmpty || fields.contains { $0?.localizedCaseInsensitiveContains(search) == true }
    }

    private func capacity(_ o: StorageOverview) -> some View {
        let pct = (o.utilizationPercent ?? 0) / 100
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Capacity").font(.headline)
                Spacer()
                Text("\(gi(o.usedGi)) of \(gi(o.totalGi)) provisioned").foregroundStyle(.secondary)
            }
            ProgressView(value: min(max(pct, 0), 1)).tint(pct >= 0.9 ? .orange : .accentColor)
            Text("\(o.boundVolumes ?? 0) of \(o.totalVolumes ?? 0) volumes bound · \(o.pendingPVCs ?? 0) claims pending · \(o.storageClasses ?? 0) classes. Capacity is provisioned, not used, space.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding()
    }

    @ViewBuilder private func claims(_ all: [StorageClaim]) -> some View {
        let rows = all.filter { matches($0.name, $0.namespace, $0.storageClass) }
        Table(rows) {
            TableColumn("Name", value: \.name)
            TableColumn("Namespace", value: \.namespace)
            TableColumn("Status") { Text($0.status ?? "—") }
            TableColumn("Class") { Text($0.storageClass ?? "—") }
            TableColumn("Size") { Text(gi($0.requestedGi)) }
            TableColumn("Access") { Text(($0.accessModes ?? []).joined(separator: ", ")) }
        }
        .overlay { if rows.isEmpty { ContentUnavailableView("No claims", systemImage: "externaldrive") } }
    }

    @ViewBuilder private func volumes(_ all: [StorageVolume]) -> some View {
        let rows = all.filter { matches($0.name, $0.claim, $0.storageClass) }
        Table(rows) {
            TableColumn("Volume", value: \.name)
            TableColumn("Claim") { Text($0.claim ?? "—") }
            TableColumn("Status") { Text($0.status ?? "—") }
            TableColumn("Class") { Text($0.storageClass ?? "—") }
            TableColumn("Size") { Text(gi($0.capacityGi)) }
            TableColumn("Reclaim") { Text($0.reclaimPolicy ?? "—") }
        }
        .overlay { if rows.isEmpty { ContentUnavailableView("No volumes", systemImage: "externaldrive") } }
    }

    @ViewBuilder private func classes(_ all: [StorageClass]) -> some View {
        let rows = all.filter { matches($0.name, $0.provisioner) }
        Table(rows) {
            TableColumn("Name") { Text($0.name + ($0.isDefault == true ? " (default)" : "")) }
            TableColumn("Provisioner") { Text($0.provisioner ?? "—") }
            TableColumn("Reclaim") { Text($0.reclaimPolicy ?? "—") }
            TableColumn("Binding") { Text($0.volumeBindingMode ?? "—") }
            TableColumn("Expandable") { Text($0.allowVolumeExpansion == true ? "Yes" : "No") }
        }
        .overlay { if rows.isEmpty { ContentUnavailableView("No storage classes", systemImage: "externaldrive") } }
    }
}

/// Disaster-recovery plans, read-only.
struct DRPlansView: View {
    let client: ZeusClient
    @State private var loader: Loader<[DRPlan]>

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader { try await client.drPlans() })
    }

    var body: some View {
        LoadStateView(loader: loader) { plans in
            if plans.isEmpty {
                ContentUnavailableView("No DR plans", systemImage: "arrow.triangle.2.circlepath",
                                       description: Text("Plans created in Zeus OS appear here."))
            } else {
                Table(plans) {
                    TableColumn("Plan", value: \.name)
                    TableColumn("Type") { Text($0.planType ?? "—") }
                    TableColumn("Health") { Text($0.enabled == false ? "disabled" : ($0.healthStatus ?? "—")) }
                    TableColumn("Primary") { Text($0.primarySite ?? "—") }
                    TableColumn("Secondary") { Text($0.secondarySite ?? "—") }
                    TableColumn("RPO now / target") { p in
                        Text("\(p.currentRPOMinutes.map { "\($0) min" } ?? "?") / \(p.targetRPOMinutes.map { "\($0) min" } ?? "—")")
                    }
                    TableColumn("RTO target") { Text($0.targetRTOMinutes.map { "\($0) min" } ?? "—") }
                    TableColumn("Last tested") { Text($0.lastTested ?? "never") }
                }
            }
        }
        .navigationTitle("DR Plans")
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}

struct VeleroData: Sendable { let installed: Bool; let backups: [VeleroBackup]; let restores: [VeleroRestore] }

/// Velero backups and restores, read-only.
struct VeleroView: View {
    let client: ZeusClient
    @State private var loader: Loader<VeleroData>

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader {
            let overview = try await client.backupOverview()
            guard overview.veleroInstalled else { return VeleroData(installed: false, backups: [], restores: []) }
            async let b = client.veleroBackups()
            async let r = client.veleroRestores()
            return try await VeleroData(installed: true, backups: b, restores: r)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { d in
            if !d.installed {
                ContentUnavailableView("Velero isn't installed", systemImage: "externaldrive.badge.xmark",
                                       description: Text("Install Velero on the cluster to see backups and restores here."))
            } else {
                List {
                    Section("Backups") {
                        if d.backups.isEmpty { Text("No backups").foregroundStyle(.secondary) }
                        ForEach(d.backups) { b in
                            LabeledContent(b.name, value: "\(b.phase ?? "—") · \((b.sizeBytes ?? 0).formatted(.byteCount(style: .file)))")
                        }
                    }
                    Section("Restores") {
                        if d.restores.isEmpty { Text("No restores").foregroundStyle(.secondary) }
                        ForEach(d.restores) { r in
                            LabeledContent("\(r.name) from \(r.backupName ?? "—")",
                                           value: "\(r.phase ?? "—") · \(r.errors ?? 0) errors · \(r.warnings ?? 0) warnings")
                        }
                    }
                }
            }
        }
        .navigationTitle("Velero")
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}

struct DiskData: Sendable { let volumes: [DataVolume]; let images: [ContainerImage] }

/// DataVolumes and cached container images, read-only.
struct DisksAndImagesView: View {
    let client: ZeusClient
    @State private var loader: Loader<DiskData>

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader {
            async let v = client.dataVolumes()
            async let i = client.images()
            return try await DiskData(volumes: v, images: i)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { d in
            List {
                Section("DataVolumes") {
                    if d.volumes.isEmpty { Text("No DataVolumes").foregroundStyle(.secondary) }
                    ForEach(d.volumes) { v in
                        LabeledContent("\(v.name) (\(v.namespace))",
                                       value: "\(v.phase ?? "—") · \(v.size ?? "—") · \(v.sourceType ?? "—")")
                    }
                }
                Section("Images") {
                    if d.images.isEmpty { Text("No images").foregroundStyle(.secondary) }
                    ForEach(d.images) { i in
                        LabeledContent("\(i.repository ?? i.id):\(i.tag ?? "")", value: i.scanStatus ?? "—")
                    }
                }
            }
        }
        .navigationTitle("Disks & Images")
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}
