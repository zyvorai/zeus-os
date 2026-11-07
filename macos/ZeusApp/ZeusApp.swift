import SwiftUI

@main
struct ZeusApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView().environment(model)
                .sheet(item: $model.trustRequest) { TrustPromptView(request: $0).environment(model) }
        }
        .defaultSize(width: 1100, height: 700)
        .commands {
            CommandGroup(after: .toolbar) {
                Button("Refresh") { Task { await model.refresh() } }
                    .keyboardShortcut("r")
            }
            CommandGroup(after: .appSettings) {
                Button("Sign Out") { model.signOut(forget: false) }
                    .keyboardShortcut("o", modifiers: [.command, .shift])
                    .disabled(model.session == nil)
            }
        }

        MenuBarExtra("Zeus", systemImage: "bolt.horizontal.circle") {
            MenuBarView().environment(model)
        }

        SwiftUI.Settings { SettingsView().environment(model) }
    }
}
