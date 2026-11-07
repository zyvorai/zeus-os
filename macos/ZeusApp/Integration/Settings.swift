import SwiftUI
import ZeusKit

/// UserDefaults-backed preferences shared by the Settings scene, the poller and the intents.
enum Prefs {
    static let notificationsKey = "zeus.notifications"
    static let pollKey = "zeus.pollSeconds"
    static let defaultServerKey = "zeus.defaultProfileID"

    static var notificationsEnabled: Bool { UserDefaults.standard.bool(forKey: notificationsKey) }

    static var pollSeconds: Int {
        let v = UserDefaults.standard.integer(forKey: pollKey)
        return [5, 10, 30, 60].contains(v) ? v : 5
    }

    static var defaultProfileID: UUID? {
        UserDefaults.standard.string(forKey: defaultServerKey).flatMap(UUID.init)
    }

    /// The default server first, so the sign-in screen resumes it.
    static func defaultFirst(_ profiles: [ServerProfile]) -> [ServerProfile] {
        guard let id = defaultProfileID, let i = profiles.firstIndex(where: { $0.id == id }) else { return profiles }
        var p = profiles; p.insert(p.remove(at: i), at: 0); return p
    }
}

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @AppStorage(Prefs.notificationsKey) private var notifications = false
    @AppStorage(Prefs.pollKey) private var poll = 5
    @AppStorage(Prefs.defaultServerKey) private var defaultServer = ""
    @State private var confirmForget = false

    var body: some View {
        Form {
            Section("Updates") {
                Picker("Refresh every", selection: $poll) {
                    Text("5 seconds").tag(5); Text("10 seconds").tag(10)
                    Text("30 seconds").tag(30); Text("1 minute").tag(60)
                }
                Text("While the app is in front. In the background it never polls faster than every 30 seconds.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Notifications") {
                Toggle("Notify about new critical and warning alerts", isOn: $notifications)
                    .onChange(of: notifications) { _, on in
                        if on { Task { if await !NotificationService.shared.requestAuthorization() { notifications = false } } }
                    }
                Text("Alerts already firing when you connect, and acknowledged alerts, never notify.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Server") {
                Picker("Default server", selection: $defaultServer) {
                    Text("First saved").tag("")
                    ForEach(model.profiles) { Text($0.name).tag($0.id.uuidString) }
                }
                Text("Opened automatically at launch.").font(.caption).foregroundStyle(.secondary)
                Button("Sign Out and Forget All Servers…", role: .destructive) { confirmForget = true }
                    .disabled(model.profiles.isEmpty && model.session == nil)
            }
        }
        .formStyle(.grouped)
        .frame(width: 460).padding()
        .confirmationDialog("Forget every saved server?", isPresented: $confirmForget) {
            Button("Sign Out and Forget", role: .destructive) { model.signOutAndForgetAll(); defaultServer = "" }
        } message: { Text("Saved servers, their Keychain tokens and trusted certificates are removed from this Mac.") }
    }
}

extension AppModel {
    func signOutAndForgetAll() {
        signOut(forget: true)
        for p in profiles { forget(p) }
    }
}
