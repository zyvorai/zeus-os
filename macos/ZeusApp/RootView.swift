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

enum SidebarGroup: String, CaseIterable, Identifiable {
    case run = "Run", observe = "Observe", protect = "Protect", cost = "Cost", secure = "Secure"
    var id: String { rawValue }
}

enum Section_: String, CaseIterable, Identifiable {
    case overview = "Overview", machines = "Machines", alerts = "Alerts"
    case snapshots = "Snapshots", backups = "Backups", cost = "Cost"
    case audit = "Audit", compliance = "Compliance"
    var id: String { rawValue }
    var group: SidebarGroup {
        switch self { case .overview, .machines: .run; case .alerts: .observe; case .snapshots, .backups: .protect; case .cost: .cost; case .audit, .compliance: .secure }
    }
    var symbol: String {
        switch self { case .overview: "gauge.with.dots.needle.50percent"; case .machines: "server.rack"; case .alerts: "bell"; case .snapshots: "camera.on.rectangle"; case .backups: "externaldrive.badge.timemachine"; case .cost: "dollarsign.circle"; case .audit: "list.bullet.clipboard"; case .compliance: "checkmark.shield" }
    }
}

struct MainView: View {
    @Environment(AppModel.self) private var model
    @State private var selection: Section_? = .overview

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(SidebarGroup.allCases) { group in
                    let items = Section_.allCases.filter { $0.group == group }
                    if !items.isEmpty {
                        Section(group.rawValue) {
                            ForEach(items) { s in
                                Label(s.rawValue, systemImage: s.symbol)
                                    .badge(s == .alerts ? (model.alerts?.needsAttention ?? 0) : 0)
                                    .tag(s)
                            }
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 190, ideal: 220, max: 300)
            .safeAreaInset(edge: .bottom) { AccountFooter() }
        } detail: {
            switch selection ?? .overview {
            case .overview: OverviewView()
            case .machines: MachinesView()
            case .alerts: AlertsView()
            case .snapshots: if let c = model.client { SnapshotsView(client: c).id(ObjectIdentifier(c)) }
            case .audit: if let c = model.client { AuditView(client: c).id(ObjectIdentifier(c)) }
            case .compliance: if let c = model.client { ComplianceView(client: c).id(ObjectIdentifier(c)) }
            case .cost: if let c = model.client { CostView(client: c).id(ObjectIdentifier(c)) }
            case .backups: if let c = model.client { BackupsView(client: c).id(ObjectIdentifier(c)) }
            }
        }
        .toolbar {
            ToolbarItem(placement: .status) { LiveStatusView() }
            ToolbarItem { Button("Refresh", systemImage: "arrow.clockwise") { Task { await model.refresh() } } }
            ToolbarItem { Button("Sign Out", systemImage: "rectangle.portrait.and.arrow.right") { model.signOut() } }
        }
    }
}

/// Which server and user this window is signed in as, with the role, at the foot of the sidebar.
struct AccountFooter: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if let p = model.active {
            VStack(alignment: .leading, spacing: 2) {
                Text(p.name).font(.callout.weight(.medium)).lineLimit(1)
                Text("\(p.username) · \(model.session?.role ?? "viewer")")
                    .font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14).padding(.vertical, 10)
            .accessibilityElement(children: .combine)
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
