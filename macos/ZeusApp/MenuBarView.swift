import SwiftUI

struct MenuBarView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if model.session == nil {
            Text("Not signed in")
        } else {
            let running = model.vms.filter { $0.status == "Running" }.count
            Text("\(running) of \(model.vms.count) machines running")
            Text("\(model.alerts?.totalActive ?? 0) active alerts")
            Divider()
            Button("Refresh") { Task { await model.refresh() } }
        }
        Divider()
        Button("Quit Zeus") { NSApplication.shared.terminate(nil) }.keyboardShortcut("q")
    }
}
