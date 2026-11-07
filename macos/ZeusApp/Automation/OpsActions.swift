import SwiftUI
import ZeusKit

/// One write action offered on a table row. Always shown behind `model.canWrite` and a confirmation
/// that names the target.
struct OpsAction: Identifiable {
    let id: String
    let title: String
    let symbol: String
    /// "Cancel task build-1?" — names the target.
    let confirmTitle: String
    let message: String
    let confirmLabel: String
    /// Used in error text: "Couldn't <verb>."
    let verb: String
    var destructive = false
    /// Show a comment field in the confirmation (approvals).
    var askComment = false
    let run: (String?) async throws -> Void
}

/// Confirmation (dialog, or a sheet with a comment field), execution and the inline server error for `OpsAction`s.
struct OpsActionHost: ViewModifier {
    @Binding var pending: OpsAction?
    @Binding var failure: String?
    let reload: () async -> Void
    @State private var comment = ""
    @State private var running = false

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) { if let failure { InlineError(message: failure) { self.failure = nil } } }
            .confirmationDialog(pending?.confirmTitle ?? "",
                                isPresented: Binding(get: { pending != nil && pending?.askComment == false },
                                                     set: { if !$0 { pending = nil } }),
                                titleVisibility: .visible) {
                if let a = pending {
                    Button(a.confirmLabel, role: a.destructive ? .destructive : nil) { Task { await execute(a, nil) } }
                }
            } message: { Text(pending?.message ?? "") }
            .sheet(isPresented: Binding(get: { pending?.askComment == true }, set: { if !$0 { pending = nil } })) {
                if let a = pending {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(a.confirmTitle).font(.headline)
                        Text(a.message).foregroundStyle(.secondary)
                        TextField("Comment (optional)", text: $comment, axis: .vertical).lineLimit(3...6)
                        HStack {
                            Spacer()
                            Button("Cancel", role: .cancel) { pending = nil }.keyboardShortcut(.cancelAction)
                            Button(a.confirmLabel, role: a.destructive ? .destructive : nil) {
                                let c = comment; Task { await execute(a, c) }
                            }
                            .keyboardShortcut(.defaultAction)
                        }
                    }
                    .padding(20).frame(width: 420)
                }
            }
    }

    private func execute(_ a: OpsAction, _ comment: String?) async {
        guard !running else { return }
        running = true; defer { running = false }
        pending = nil; self.comment = ""
        do { try await a.run(comment); failure = nil }
        catch { failure = describe(error, a.verb) }
        await reload()
    }
}

extension View {
    func opsActions(pending: Binding<OpsAction?>, failure: Binding<String?>,
                    reload: @escaping () async -> Void) -> some View {
        modifier(OpsActionHost(pending: pending, failure: failure, reload: reload))
    }
}

/// Builders for the actions on the automation screens.
enum OpsActions {
    private static let terminalTask: Set<String> = ["completed", "succeeded", "success", "failed", "cancelled", "canceled", "error"]
    private static let resolvedApproval: Set<String> = ["approved", "rejected", "auto_approved", "cancelled", "canceled", "expired"]

    static func task(_ t: OpsTask, client: ZeusClient) -> [OpsAction] {
        guard !terminalTask.contains((t.status ?? "").lowercased()) else { return [] }
        let name = t.taskType ?? t.id
        return [OpsAction(id: "cancel", title: "Cancel Task…", symbol: "xmark.circle",
                          confirmTitle: "Cancel task \(name)?",
                          message: "Task \(t.id) will be asked to stop. Work already done isn't undone.",
                          confirmLabel: "Cancel Task", verb: "cancel the task", destructive: true) { _ in try await client.cancelTask(t) }]
    }

    static func scheduled(_ o: ScheduledOperation, client: ZeusClient) -> [OpsAction] {
        let name = o.name ?? o.id
        return [OpsAction(id: "delete", title: "Delete…", symbol: "trash",
                          confirmTitle: "Delete scheduled operation \(name)?",
                          message: "It will no longer run. This can't be undone.",
                          confirmLabel: "Delete", verb: "delete the scheduled operation", destructive: true) { _ in try await client.deleteScheduledOperation(o) }]
    }

    static func workflow(_ w: Workflow, client: ZeusClient) -> [OpsAction] {
        guard w.enabled != false else { return [] }
        let name = w.name ?? w.id
        return [OpsAction(id: "run", title: "Run Now…", symbol: "play.fill",
                          confirmTitle: "Run workflow \(name)?",
                          message: "Starts one run with no input. Its steps take effect on the cluster.",
                          confirmLabel: "Run", verb: "run the workflow") { _ in try await client.triggerWorkflow(w) }]
    }

    static func approval(_ a: ChangeApproval, client: ZeusClient) -> [OpsAction] {
        guard !resolvedApproval.contains((a.status ?? "").lowercased()) else { return [] }
        let target = [a.targetNamespace, a.targetVm].compactMap { $0 }.joined(separator: "/")
        let what = "\(a.action ?? "change") on \(target.isEmpty ? a.id : target)"
        return [
            OpsAction(id: "approve", title: "Approve…", symbol: "checkmark.circle",
                      confirmTitle: "Approve \(what)?",
                      message: "Requested by \(a.requester ?? "unknown"). The decision and comment are recorded.",
                      confirmLabel: "Approve", verb: "approve the change", askComment: true) { c in
                try await client.resolveChangeApproval(a, .approved, comment: c) },
            OpsAction(id: "reject", title: "Reject…", symbol: "xmark.circle",
                      confirmTitle: "Reject \(what)?",
                      message: "Requested by \(a.requester ?? "unknown"). The decision and comment are recorded.",
                      confirmLabel: "Reject", verb: "reject the change", destructive: true, askComment: true) { c in
                try await client.resolveChangeApproval(a, .rejected, comment: c) },
        ]
    }
}
