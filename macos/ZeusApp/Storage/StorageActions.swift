import SwiftUI
import ZeusKit

/// Footer shared by the form sheets: server error inline, Cancel and a submit button that names the action.
private struct SheetFooter: View {
    let title: String
    let canSubmit: Bool
    let error: String?
    let busy: Bool
    let cancel: () -> Void
    let submit: () -> Void
    var body: some View {
        if let error { Label(error, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange) }
        HStack {
            Spacer()
            Button("Cancel", role: .cancel, action: cancel).keyboardShortcut(.cancelAction)
            Button(title, action: submit).keyboardShortcut(.defaultAction).disabled(!canSubmit || busy)
        }
    }
}

/// Create a PersistentVolumeClaim (`POST /storage/claims`).
struct NewClaimSheet: View {
    @Environment(\.dismiss) private var dismiss
    let client: ZeusClient
    let classes: [StorageClass]
    let onDone: () async -> Void
    @State private var name = ""
    @State private var namespace = ""
    @State private var sizeGi = 10
    @State private var storageClass = ""
    @State private var error: String?
    @State private var busy = false

    private var valid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && !namespace.trimmingCharacters(in: .whitespaces).isEmpty && sizeGi > 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("New volume claim").font(.headline)
            Form {
                TextField("Name", text: $name)
                TextField("Namespace", text: $namespace)
                Stepper("Size: \(sizeGi) Gi", value: $sizeGi, in: 1...100_000)
                Picker("Storage class", selection: $storageClass) {
                    Text("Cluster default").tag("")
                    ForEach(classes) { Text($0.name).tag($0.name) }
                }
            }
            Text("Creates a ReadWriteOnce claim. Storage is provisioned on the cluster.").font(.caption).foregroundStyle(.secondary)
            SheetFooter(title: "Create Claim", canSubmit: valid, error: error, busy: busy, cancel: { dismiss() }) {
                busy = true
                Task {
                    defer { busy = false }
                    do {
                        try await client.createClaim(name: name.trimmingCharacters(in: .whitespaces),
                                                     namespace: namespace.trimmingCharacters(in: .whitespaces),
                                                     sizeGi: Double(sizeGi), storageClass: storageClass)
                        await onDone(); dismiss()
                    } catch { self.error = describe(error, "create the claim") }
                }
            }
        }
        .padding(20).frame(width: 420)
    }
}

/// Grow a claim (`POST /namespaces/{ns}/pvcs/{name}/resize`). Shrinking is refused here and by Kubernetes.
struct ResizeClaimSheet: View {
    @Environment(\.dismiss) private var dismiss
    let client: ZeusClient
    let claim: StorageClaim
    let onDone: () async -> Void
    @State private var sizeGi: Int
    @State private var error: String?
    @State private var busy = false
    @State private var confirming = false

    init(client: ZeusClient, claim: StorageClaim, onDone: @escaping () async -> Void) {
        self.client = client; self.claim = claim; self.onDone = onDone
        _sizeGi = State(initialValue: Int((claim.requestedGi ?? 0).rounded(.up)) + 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resize \(claim.namespace)/\(claim.name)").font(.headline)
            Stepper("New size: \(sizeGi) Gi", value: $sizeGi, in: 1...100_000)
            Text("Currently \((claim.requestedGi ?? 0).formatted(.number.precision(.fractionLength(0...1)))) Gi. Claims can only grow, and only when their storage class allows expansion.")
                .font(.caption).foregroundStyle(.secondary)
            SheetFooter(title: "Resize…", canSubmit: ZeusClient.isGrowth(of: claim, toGi: sizeGi), error: error,
                        busy: busy, cancel: { dismiss() }) { confirming = true }
        }
        .padding(20).frame(width: 420)
        .confirmationDialog("Grow \(claim.namespace)/\(claim.name) to \(sizeGi) Gi?", isPresented: $confirming, titleVisibility: .visible) {
            Button("Grow Claim") {
                busy = true
                Task {
                    defer { busy = false }
                    do { try await client.resizeClaim(claim, toGi: sizeGi); await onDone(); dismiss() }
                    catch { self.error = describe(error, "resize the claim") }
                }
            }
        } message: { Text("This can't be undone: a claim can't be shrunk afterwards.") }
    }
}

/// Create a Velero backup schedule (`POST /velero/schedules`).
struct NewVeleroScheduleSheet: View {
    @Environment(\.dismiss) private var dismiss
    let client: ZeusClient
    let onDone: () async -> Void
    @State private var name = ""
    @State private var cron = "0 2 * * *"
    @State private var namespaces = ""
    @State private var ttlDays = 30
    @State private var error: String?
    @State private var busy = false
    @State private var confirming = false

    private var included: [String] {
        namespaces.split(whereSeparator: { $0 == "," || $0 == " " }).map(String.init)
    }
    private var valid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && cron.split(separator: " ").count == 5 && !included.isEmpty && ttlDays > 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("New backup schedule").font(.headline)
            Form {
                TextField("Name", text: $name)
                TextField("Cron (5 fields)", text: $cron).monospaced()
                TextField("Namespaces (comma separated)", text: $namespaces)
                Stepper("Keep for \(ttlDays) days", value: $ttlDays, in: 1...3650)
            }
            SheetFooter(title: "Create…", canSubmit: valid, error: error, busy: busy, cancel: { dismiss() }) { confirming = true }
        }
        .padding(20).frame(width: 440)
        .confirmationDialog("Create Velero schedule \(name)?", isPresented: $confirming, titleVisibility: .visible) {
            Button("Create Schedule") {
                busy = true
                Task {
                    defer { busy = false }
                    do {
                        try await client.createVeleroSchedule(VeleroScheduleBody(
                            name: name.trimmingCharacters(in: .whitespaces), schedule: cron, includedNamespaces: included,
                            ttlHours: ttlDays * 24))
                        await onDone(); dismiss()
                    } catch { self.error = describe(error, "create the schedule") }
                }
            }
        } message: { Text("Backs up \(included.joined(separator: ", ")) on \(cron), keeping each for \(ttlDays) days.") }
    }
}

extension OpsActions {
    static func volumeSnapshot(_ s: VolumeSnapshot, client: ZeusClient) -> [OpsAction] {
        [OpsAction(id: "delete", title: "Delete…", symbol: "trash",
                   confirmTitle: "Delete volume snapshot \(s.namespace)/\(s.name)?",
                   message: "The snapshot can no longer be used to restore. This can't be undone.",
                   confirmLabel: "Delete", verb: "delete the volume snapshot", destructive: true) { _ in
            try await client.deleteVolumeSnapshot(s) }]
    }
}
