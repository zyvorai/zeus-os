import SwiftUI

@main
struct ZeusApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView().environment(model)
        }
        .defaultSize(width: 1100, height: 700)
        .commands {
            CommandGroup(after: .toolbar) {
                Button("Refresh") { Task { await model.refresh() } }
                    .keyboardShortcut("r")
            }
        }

        MenuBarExtra("Zeus", systemImage: "bolt.horizontal.circle") {
            MenuBarView().environment(model)
        }

        Settings { Text("Settings").padding() }
    }
}
