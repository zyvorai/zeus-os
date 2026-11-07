import SwiftUI
import ZeusKit

struct BackupData: Sendable { let overview: BackupOverview; let backups: [VMBackup]; let stats: BackupStats? }

struct BackupsView: View {
    @Environment(AppModel.self) private var model
    let client: ZeusClient
    @State private var loader: Loader<BackupData>
    @State private var restoring: VMBackup?
    @State private var failure: String?
    @State private var notice: String?
    @State private var scheduling = false

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader {
            async let o = client.backupOverview()
            async let b = client.backups()
            async let s = try? client.backupStats()
            return try await BackupData(overview: o, backups: b, stats: await s)
        })
    }

    var body: some View {
        LoadStateView(loader: loader) { data in
            List {
                Section("Summary") {
                    LabeledContent("VM backups", value: "\(data.stats?.totalBackups ?? data.backups.count)")
                    LabeledContent("Total size", value: (data.stats?.totalSizeBytes ?? 0)
                        .formatted(.byteCount(style: .file)))
                    LabeledContent("Velero", value: data.overview.veleroInstalled ? "Installed" : "Not installed")
                }
                Section("Schedules") {
                    if data.overview.schedules.isEmpty {
                        Text("No schedules").foregroundStyle(.secondary)
                    }
                    ForEach(data.overview.schedules) { s in
                        VStack(alignment: .leading, spacing: 2) {
                            HStack { Text(s.name).font(.headline); Spacer(); Text(s.schedule ?? "").monospaced().foregroundStyle(.secondary) }
                            Text(detail(s)).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                Section("VM backups") {
                    if data.backups.isEmpty { Text("No backups yet").foregroundStyle(.secondary) }
                    ForEach(data.backups) { b in
                        HStack {
                            LabeledContent("\(b.backupName) · \(b.vmName)",
                                           value: "\(b.status ?? "—") · \((b.sizeBytes ?? 0).formatted(.byteCount(style: .file)))")
                            if model.canWrite { Button("Restore…") { restoring = b } }
                        }
                    }
                }
                if !data.overview.recentBackups.isEmpty {
                    Section("Recent Velero runs") {
                        ForEach(data.overview.recentBackups) { r in
                            LabeledContent(r.name, value: r.phase ?? "—")
                        }
                    }
                }
            }
        }
        .navigationTitle("Backups")
        .toolbar {
            if model.canWrite {
                ToolbarItem { Button("New Schedule", systemImage: "calendar.badge.plus") { scheduling = true } }
            }
        }
        .sheet(isPresented: $scheduling) {
            NewVeleroScheduleSheet(client: client) { await loader.reload() }
        }
        .safeAreaInset(edge: .bottom) {
            if let failure { InlineError(message: failure) { self.failure = nil } }
            else if let notice { InlineError(message: notice) { self.notice = nil } }
        }
        .confirmationDialog(restoring.map { "Restore \($0.vmName) from \($0.backupName)?" } ?? "",
                            isPresented: Binding(get: { restoring != nil }, set: { if !$0 { restoring = nil } }),
                            titleVisibility: .visible) {
            Button("Restore", role: .destructive) { if let b = restoring { Task { await restore(b) } } }
        } message: { Text("This can replace the machine's current disks with the backed-up state.") }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }

    private func restore(_ b: VMBackup) async {
        do { try await client.restore(b); failure = nil; notice = "Restore of \(b.backupName) started." }
        catch { notice = nil; failure = describe(error, "restore the backup") }
        await loader.reload()
    }

    private func detail(_ s: BackupSchedule) -> String {
        var parts: [String] = []
        if let ns = s.includedNamespaces, !ns.isEmpty { parts.append(ns.joined(separator: ", ")) }
        if let ttl = s.ttl { parts.append("keeps \(ttl)") }
        parts.append(s.lastBackup.map { "last \($0)" } ?? "never run")
        return parts.joined(separator: " · ")
    }
}
