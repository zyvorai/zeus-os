import SwiftUI
import ZeusKit

/// Creates an email (SMTP) notification channel. This is the only channel type whose `config` the docs spell out,
/// so it is the only one offered. The SMTP password lives in a SecureField for the life of this sheet, goes out in
/// the single create request and is never stored, logged or read back (the server masks it too).
/// There is deliberately no "send test" button: that would message real people.
struct EmailChannelEditor: View {
    let onSave: (NotificationChannelInput) async -> String?

    @State private var name = ""
    @State private var host = ""
    @State private var port = ""
    @State private var security = "starttls"
    @State private var username = ""
    @State private var password = ""
    @State private var from = ""
    @State private var to = ""
    @State private var working = false
    @State private var failure: String?

    private var recipients: [String] {
        to.split(whereSeparator: { ",;\n".contains($0) }).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }
    private var portValue: Int? { Int(port.trimmingCharacters(in: .whitespaces)) }
    private var valid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !host.trimmingCharacters(in: .whitespaces).isEmpty
            && !from.trimmingCharacters(in: .whitespaces).isEmpty && !recipients.isEmpty && recipients.count <= 20
            && (port.isEmpty || portValue != nil)
            && (username.isEmpty == password.isEmpty)                     // the server wants both or neither
            && (security != "none" || (username.isEmpty && password.isEmpty))  // never sends credentials in plaintext
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("New Email Channel").font(.headline).padding()
            Form {
                TextField("Name", text: $name)
                TextField("SMTP host", text: $host)
                TextField("Port (optional)", text: $port)
                Picker("Security", selection: $security) {
                    Text("STARTTLS").tag("starttls"); Text("TLS").tag("tls"); Text("None").tag("none")
                }
                TextField("Username (optional)", text: $username)
                SecureField("Password", text: $password)
                TextField("From", text: $from, prompt: Text("zeus@example.com"))
                TextField("To (comma separated, up to 20)", text: $to)
                Text("The password is sent once and is never shown again. Zeus does not send a test message.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .formStyle(.grouped)
            EditorFooter(saveTitle: "Create", canSave: valid, working: $working, failure: $failure) {
                let cfg = EmailChannelConfig(host: host.trimmingCharacters(in: .whitespaces), port: portValue, security: security,
                                             username: username.trimmingCharacters(in: .whitespaces), password: password,
                                             from: from.trimmingCharacters(in: .whitespaces), to: recipients)
                let err = await onSave(.email(name: name.trimmingCharacters(in: .whitespaces), cfg))
                if err == nil { password = "" }
                return err
            }
        }
        .frame(width: 460)
    }
}
