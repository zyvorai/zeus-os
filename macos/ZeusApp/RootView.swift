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
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Image(systemName: "bolt.horizontal.circle.fill")
                    .font(.system(size: 48)).foregroundStyle(.tint)
                Text("Zeus").font(.largeTitle.weight(.semibold))
                Text("Sign in to your server").font(.callout).foregroundStyle(.secondary)
            }
            .padding(.top, 24).accessibilityElement(children: .combine)
            form
        }
        .frame(width: 440)
        .task { if let first = model.profiles.first { await model.resume(first) } }
    }

    private var form: some View {
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
            if let e = model.error {
                Label(e, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.red)
            }
            if let n = model.notice {
                Label(n, systemImage: "info.circle.fill").foregroundStyle(.orange)
            }
            HStack {
                if model.isLoading { ProgressView().controlSize(.small) }
                Spacer()
                Button("Sign In") {
                    guard let u = URL(string: url) else { return }
                    Task { await model.signIn(name: name, url: u, username: user, password: pass, remember: remember) }
                }
                .buttonStyle(.borderedProminent).controlSize(.large)
                .keyboardShortcut(.defaultAction)
                .disabled(user.isEmpty || pass.isEmpty || model.isLoading)
            }
        }
        .formStyle(.grouped)
    }

    /// Saved token first; if it is gone or rejected, prefill the form for a password.
    private func open(_ p: ServerProfile) async {
        await model.resume(p)
        if model.session == nil { name = p.name; url = p.url.absoluteString; user = p.username }
    }
}

/// One sidebar entry. Areas contribute their own lists (see `Destinations.swift` and the per-area
/// `*Destinations.swift` files) and `Destination.all` concatenates them, so adding a screen never
/// touches a shared enum.
struct Destination: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let group: String
    let content: @MainActor (AppModel) -> AnyView

    init(_ title: String, symbol: String, group: String, id: String? = nil,
         content: @escaping @MainActor (AppModel) -> AnyView) {
        self.id = id ?? title; self.title = title; self.symbol = symbol; self.group = group; self.content = content
    }

    /// Screens that need a signed-in client. Rebuilt when the server changes so no state leaks across servers.
    init<V: View>(_ title: String, symbol: String, group: String, id: String? = nil,
                  view: @escaping @MainActor (ZeusClient) -> V) {
        self.init(title, symbol: symbol, group: group, id: id) { model in
            guard let c = model.client else { return AnyView(EmptyView()) }
            return AnyView(view(c).id(ObjectIdentifier(c)))
        }
    }
}

struct MainView: View {
    @Environment(AppModel.self) private var model
    @State private var selection: Destination.ID? = "Overview"
    @State private var filter = ""
    @AppStorage("sidebar.collapsed") private var collapsedRaw = ""

    private var collapsed: Set<String> { Set(collapsedRaw.split(separator: ",").map(String.init)) }

    private func setExpanded(_ group: String, _ expanded: Bool) {
        var c = collapsed
        if expanded { c.remove(group) } else { c.insert(group) }
        collapsedRaw = c.sorted().joined(separator: ",")
    }

    /// Groups in order of first use, limited to entries matching the filter.
    private var groups: [(name: String, items: [Destination])] { groups(matching: filter) }

    private func groups(matching filter: String) -> [(name: String, items: [Destination])] {
        var order: [String] = []
        for d in Destination.all where !order.contains(d.group) { order.append(d.group) }
        return order.compactMap { g in
            let items = Destination.all.filter { $0.group == g &&
                (filter.isEmpty || $0.title.localizedCaseInsensitiveContains(filter)
                 || g.localizedCaseInsensitiveContains(filter)) }
            return items.isEmpty ? nil : (g, items)
        }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(groups, id: \.name) { group in
                    Section(group.name, isExpanded: Binding(
                        get: { !filter.isEmpty || !collapsed.contains(group.name) },
                        set: { setExpanded(group.name, $0) })) {
                        ForEach(group.items) { d in
                            Label(d.title, systemImage: d.symbol)
                                .badge(d.id == "Alerts" ? (model.alerts?.needsAttention ?? 0) : 0)
                                .tag(d.id)
                        }
                    }
                }
            }
            .searchable(text: $filter, placement: .sidebar, prompt: "Filter")
            .overlay { if groups.isEmpty { ContentUnavailableView.search(text: filter) } }
            .navigationSplitViewColumnWidth(min: 190, ideal: 220, max: 300)
            .safeAreaInset(edge: .bottom) { AccountFooter() }
        } detail: {
            (Destination.all.first { $0.id == selection } ?? Destination.all[0]).content(model)
        }
        .toolbar {
            ToolbarItem(placement: .status) { LiveStatusView() }
            ToolbarItem { Button("Refresh", systemImage: "arrow.clockwise") { Task { await model.refresh() } }.help("Refresh (⌘R)") }
            ToolbarSpacer(.fixed)       // keep Sign Out apart from the everyday Refresh
            ToolbarItem { Button("Sign Out", systemImage: "rectangle.portrait.and.arrow.right") { model.signOut() }.help("Sign out and forget this session") }
        }
        .background { sectionShortcuts }
    }

    /// ⌘1…⌘9 jump to the first nine screens in sidebar order.
    private var sectionShortcuts: some View {
        ForEach(Array(groups(matching: "").flatMap(\.items).prefix(9).enumerated()), id: \.element.id) { i, d in
            Button(d.title) { selection = d.id }
                .keyboardShortcut(KeyEquivalent(Character("\(i + 1)")), modifiers: .command)
                .frame(width: 0, height: 0).opacity(0).accessibilityHidden(true)
        }
    }
}

/// Which server and user this window is signed in as, with the role, at the foot of the sidebar.
struct AccountFooter: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if let p = model.active {
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.fill").font(.title2).foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(p.name).font(.callout.weight(.medium)).lineLimit(1)
                        Text("\(p.username) · \(model.session?.role ?? "viewer")")
                            .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .accessibilityElement(children: .combine)
            }
            .background(.bar)
        }
    }
}

/// "Live · updated 5 seconds ago", or an orange "Reconnecting" while polls are failing.
struct LiveStatusView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        HStack(spacing: 6) {
            if case .retrying = model.liveState {
                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
            } else {
                Circle().fill(color).frame(width: 8, height: 8)
            }
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
