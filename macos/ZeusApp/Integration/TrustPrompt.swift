import SwiftUI
import ZeusKit

/// A server presented a certificate the system doesn't trust and that isn't the pinned one.
struct TrustRequest: Identifiable {
    let id = UUID()
    let info: CertificateInfo
    let host: String
    /// True when a certificate was pinned before: the server's certificate changed.
    let changed: Bool
    let retry: @MainActor (String) async -> Void
}

struct TrustPromptView: View {
    @Environment(AppModel.self) private var model
    let request: TrustRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(request.changed ? "Certificate changed" : "Untrusted certificate", systemImage: "exclamationmark.shield")
                .font(.title2.bold())
            Text(request.changed
                 ? "\(request.host) now presents a different certificate than the one you trusted. Only continue if you expect this."
                 : "\(request.host) presented a certificate this Mac doesn't trust, often a self-signed one. Compare the fingerprint with your server before trusting it.")
            Form {
                LabeledContent("Subject", value: request.info.subject)
                LabeledContent("SHA-256") {
                    Text(request.info.displayFingerprint).font(.system(.caption, design: .monospaced)).textSelection(.enabled)
                }
            }.formStyle(.grouped)
            Text("Trusting pins this exact certificate for this server only. Other certificates are still rejected.")
                .font(.caption).foregroundStyle(.secondary)
            HStack {
                Spacer()
                Button("Don't Trust", role: .cancel) { model.trustRequest = nil }.keyboardShortcut(.cancelAction)
                Button("Trust Certificate") {
                    model.trustRequest = nil
                    Task { await request.retry(request.info.sha256) }
                }.keyboardShortcut(.defaultAction)
            }
        }
        .padding().frame(width: 480)
    }
}
