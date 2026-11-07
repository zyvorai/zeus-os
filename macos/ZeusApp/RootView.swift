import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if model.session == nil { LoginView() } else { MainView() }
    }
}

struct LoginView: View {
    @Environment(AppModel.self) private var model
    @State private var url = "https://zeus.zyvor.dev"
    @State private var user = ""
    @State private var pass = ""

    var body: some View {
        Form {
            Section("Server") { TextField("URL", text: $url).textContentType(.URL) }
            Section("Account") {
                TextField("Username", text: $user)
                SecureField("Password", text: $pass)
            }
            if let e = model.error { Text(e).foregroundStyle(.red) }
            Button("Sign In") {
                guard let u = URL(string: url) else { return }
                Task { await model.signIn(url: u, username: user, password: pass) }
            }
            .keyboardShortcut(.defaultAction)
            .disabled(user.isEmpty || pass.isEmpty || model.isLoading)
        }
        .formStyle(.grouped)
        .frame(width: 420).padding()
    }
}

enum Section_: String, CaseIterable, Identifiable {
    case machines = "Machines", alerts = "Alerts"
    var id: String { rawValue }
    var symbol: String { self == .machines ? "server.rack" : "bell" }
}

struct MainView: View {
    @Environment(AppModel.self) private var model
    @State private var selection: Section_? = .machines

    var body: some View {
        NavigationSplitView {
            List(Section_.allCases, selection: $selection) { s in
                Label(s.rawValue, systemImage: s.symbol)
                    .badge(s == .alerts ? (model.alerts?.totalActive ?? 0) : 0)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 210)
        } detail: {
            switch selection ?? .machines {
            case .machines: MachinesView()
            case .alerts: ContentUnavailableView("No active alerts", systemImage: "checkmark.seal")
            }
        }
        .toolbar {
            ToolbarItem { Button("Refresh", systemImage: "arrow.clockwise") { Task { await model.refresh() } } }
            ToolbarItem { Button("Sign Out", systemImage: "rectangle.portrait.and.arrow.right") { model.signOut() } }
        }
    }
}
