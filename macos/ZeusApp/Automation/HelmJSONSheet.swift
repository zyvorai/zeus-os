import SwiftUI
import ZeusKit

/// Sends a hand-written JSON body for a Helm install or upgrade. The server documents these bodies only as
/// "free-form JSON", so the app doesn't pretend to know the fields; it validates that the text is a JSON object.
struct HelmJSONSheet: View {
    let title: String
    let message: String
    let onSend: (JSONValue) async -> String?
    @Environment(\.dismiss) private var dismiss
    @State private var text = "{\n  \n}"
    @State private var failure: String?
    @State private var working = false

    var body: some View {
        VStack(spacing: 12) {
            Text(title).font(.headline)
            Text(message).font(.callout).foregroundStyle(.secondary)
            TextEditor(text: $text).font(.system(.body, design: .monospaced)).frame(minHeight: 200)
                .border(.quaternary)
            if let failure { InlineError(message: failure) { self.failure = nil } }
            HStack {
                Button("Cancel", role: .cancel) { dismiss() }
                Spacer()
                Button("Send") { Task { await send() } }.buttonStyle(.borderedProminent).disabled(working)
            }
        }
        .padding().frame(width: 480)
    }

    private func send() async {
        working = true; defer { working = false }
        do {
            let body = try ZeusClient.parseJSONObject(text)
            if let f = await onSend(body) { failure = f } else { dismiss() }
        } catch let e as BudgetValidationError { failure = e.message } catch { failure = "Invalid JSON." }
    }
}
