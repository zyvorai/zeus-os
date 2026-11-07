import SwiftUI
import ZeusKit

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if model.session == nil { LoginView() } else { MainView() }
    }
}

struct LoginView: View {
    @Environment(AppModel.self) private var model
    @State private var selected: ServerProfile.ID?
    @State private var name = ""
    @State private var url = "https://zeus.zyvor.dev"
    @State private var user = ""
    @State private var pass = ""
    @State private var remember = true

    var body: some View {
        Form {
            if !model.profiles.isEmpty {
                Section("Saved servers") {
                    ForEach(model.profiles) { p in
                        HStack {
                            Button { Task { await open(p) } } label: {
                                VStack(alignment: .leading) {
                                    Text(p.name); Text("\(p.username) · \(p.url.host() ?? "")").font(.caption).foregroundStyle(.secondary)
                                }
                            }.buttonStyle(.plain)
                            Spacer()
                            Button("Remove", systemImage: "trash", role: .destructive) { model.forget(p) }
                                .labelStyle(.iconOnly).buttonStyle(.borderless)
                        }
                    }
                }
            }
            Section(model.profiles.isEmpty ? "Server" : "Add or sign in") {
                TextField("Name (optional)", text: $name)
                TextField("URL", text: $url)
                TextField("Username", text: $user)
                SecureField("Password", text: $pass)
                Toggle("Remember in Keychain", isOn: $remember)
            }
            if let e = model.error { Text(e).foregroundStyle(.red) }
            if let n = model.notice { Text(n).foregroundStyle(.orange) }
            Button("Sign In") {
                guard let u = URL(string: url) else { return }
                Task { await model.signIn(name: name, url: u, username: user, password: pass, remember: remember) }
            }
            .keyboardShortcut(.defaultAction)
            .disabled(user.isEmpty || pass.isEmpty || model.isLoading)
        }
        .formStyle(.grouped)
        .frame(width: 440).padding()
        .task { if let first = model.profiles.first { await model.resume(first) } }
    }

    /// Saved token first; if it is gone or rejected, prefill the form for a password.
    private func open(_ p: ServerProfile) async {
        await model.resume(p)
        if model.session == nil { name = p.name; url = p.url.absoluteString; user = p.username }
    }
}

enum Section_: String, CaseIterable, Identifiable {
    case overview = "Overview", machines = "Machines", alerts = "Alerts"
    var id: String { rawValue }
    var symbol: String {
        switch self { case .overview: "gauge.with.dots.needle.50percent"; case .machines: "server.rack"; case .alerts: "bell" }
    }
}

struct MainView: View {
    @Environment(AppModel.self) private var model
    @State private var selection: Section_? = .overview

    var body: some View {
        NavigationSplitView {
            List(Section_.allCases, selection: $selection) { s in
                Label(s.rawValue, systemImage: s.symbol)
                    .badge(s == .alerts ? (model.alerts?.totalActive ?? 0) : 0)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 210)
        } detail: {
            switch selection ?? .overview {
            case .overview: OverviewView()
            case .machines: MachinesView()
            case .alerts: ContentUnavailableView("No active alerts", systemImage: "checkmark.seal")
            }
        }
        .toolbar {
            ToolbarItem(placement: .status) { LiveStatusView() }
            ToolbarItem { Button("Refresh", systemImage: "arrow.clockwise") { Task { await model.refresh() } } }
            ToolbarItem { Button("Sign Out", systemImage: "rectangle.portrait.and.arrow.right") { model.signOut() } }
        }
    }
}

/// "Live · updated 5 seconds ago", or an orange "Reconnecting" while polls are failing.
struct LiveStatusView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            if case .retrying = model.liveState {
                Text("Reconnecting…")
            } else if let t = model.lastUpdated {
                Text("Updated ") + Text(t, style: .relative) + Text(" ago")
            } else {
                Text("Live")
            }
        }
        .font(.caption).foregroundStyle(.secondary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(model.liveState == .live ? "Live updates on" : "Live updates reconnecting")
    }

    private var color: Color {
        switch model.liveState { case .live: .green; case .retrying: .orange; case .off: .gray }
    }
}
