import SwiftUI
import ZeusKit

/// Read-only detail sections for the machine inspector: disks, guest network/OS, recent changes.
/// Each section loads on its own so one failing endpoint doesn't blank the others.
struct VMDetailSections: View {
    let vm: VM
    let client: ZeusClient
    @State private var disks: Loader<[VMDisk]>
    @State private var guest: Loader<GuestInfo>
    @State private var changes: Loader<VMChanges>

    init(vm: VM, client: ZeusClient) {
        self.vm = vm; self.client = client
        _disks = State(initialValue: Loader { try await client.disks(of: vm) })
        _guest = State(initialValue: Loader { try await client.guestInfo(of: vm) })
        _changes = State(initialValue: Loader { try await client.changes(of: vm) })
    }

    var body: some View {
        Group {
            Section("Guest") { SectionBody(loader: guest) { g in GuestRows(info: g) } }
            Section("Disks") {
                SectionBody(loader: disks) { list in
                    if list.isEmpty { Text("No disks.").foregroundStyle(.secondary) }
                    ForEach(list) { DiskRow(disk: $0) }
                }
            }
            Section("Recent changes") {
                SectionBody(loader: changes) { c in
                    if c.changes.isEmpty { Text("No recorded changes.").foregroundStyle(.secondary) }
                    ForEach(c.changes.prefix(10)) { ChangeRow(change: $0) }
                }
            }
        }
        .task { disks.start(polling: false); guest.start(polling: false); changes.start(polling: false) }
        .onDisappear { disks.stop(); guest.stop(); changes.stop() }
    }
}

/// Compact loading / failure / content switch for one inspector section.
private struct SectionBody<T: Sendable, Content: View>: View {
    let loader: Loader<T>
    @ViewBuilder var content: (T) -> Content

    var body: some View {
        if let v = loader.value { content(v) }
        else if case .failed(let m) = loader.phase {
            HStack {
                Text(m).font(.callout).foregroundStyle(.secondary)
                Spacer()
                Button("Retry") { Task { await loader.reload() } }.buttonStyle(.borderless)
            }
        } else { ProgressView().controlSize(.small) }
    }
}

private struct GuestRows: View {
    let info: GuestInfo
    var body: some View {
        if info.agentConnected {
            LabeledContent("Hostname", value: info.hostname ?? "—")
            LabeledContent("OS", value: [info.osName, info.osVersion].compactMap { $0 }.joined(separator: " ").nilIfEmpty ?? "—")
            LabeledContent("Kernel", value: info.kernelVersion ?? "—")
            LabeledContent("Architecture", value: info.architecture ?? "—")
        } else {
            Label("Guest agent not connected. OS details appear once it reports in.", systemImage: "info.circle")
                .font(.callout).foregroundStyle(.secondary)
        }
        ForEach(info.interfaces) { i in
            LabeledContent(i.name ?? "Interface") {
                VStack(alignment: .trailing) {
                    Text(i.ipAddresses.isEmpty ? "No address" : i.ipAddresses.joined(separator: ", ")).textSelection(.enabled)
                    if let mac = i.mac { Text(mac).font(.caption.monospaced()).foregroundStyle(.secondary).textSelection(.enabled) }
                }
            }
        }
    }
}

private struct DiskRow: View {
    let disk: VMDisk
    var body: some View {
        LabeledContent {
            VStack(alignment: .trailing) {
                Text([disk.size, disk.status].compactMap { $0 }.joined(separator: " · "))
                Text([disk.diskType, disk.bus, disk.accessMode, disk.storageClass].compactMap { $0 }.joined(separator: " · "))
                    .font(.caption).foregroundStyle(.secondary)
            }
        } label: {
            Label(disk.name, systemImage: disk.isCDROM == true ? "opticaldisc" : "internaldrive")
        }
    }
}

private struct ChangeRow: View {
    let change: VMChange
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(change.description ?? change.changeType ?? "Change")
            Text([change.timestamp.flatMap { try? Date.ISO8601FormatStyle().parse($0) }?.formatted(date: .abbreviated, time: .shortened) ?? change.timestamp,
                  change.source].compactMap { $0 }.joined(separator: " · "))
                .font(.caption).foregroundStyle(.secondary)
        }
    }
}

private extension String { var nilIfEmpty: String? { isEmpty ? nil : self } }
