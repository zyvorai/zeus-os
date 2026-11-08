import SwiftUI
import ZeusKit

/// Contains a workload's network access. Containments can be created, looked up by id, extended, released and
/// rolled back, but the server has no list call, so this screen shows the ones created or looked up this session.
/// Everything here is written from the OpenAPI document and has not been tried against a live server.
struct ContainmentsView: View {
    @Environment(AppModel.self) private var model
    let client: ZeusClient
    @State private var items: [Containment] = []
    @State private var selection: Containment.ID?
    @State private var creating = false
    @State private var lookupID = ""
    @State private var failure: String?
    @State private var pending: Pending?
    @State private var extending = false
    @State private var busy = false
    /// The server can't list containments, so the ids this Mac has created or looked up are remembered here
    /// (ids only, newest first) and re-read on open.
    @AppStorage("containments.ids") private var savedIDs = ""

    enum Pending: Identifiable {
        case release(Containment), rollBack(Containment)
        var id: String { switch self { case .release(let c): "r\(c.id)"; case .rollBack(let c): "b\(c.id)" } }
    }

    private var selected: Containment? { items.first { $0.id == selection } }

    var body: some View {
        HSplitView {
            list.frame(minWidth: 320, idealWidth: 380)
            detail.frame(minWidth: 320)
        }
        .navigationTitle("Containments")
        .task { await restore() }
        .toolbar {
            if model.canWrite { ToolbarItem { Button("Contain Workload…", systemImage: "lock.shield") { creating = true } } }
        }
        .sheet(isPresented: $creating) { ContainmentEditor { await create($0) } }
        .sheet(isPresented: $extending) {
            if let c = selected { ExtendContainmentSheet(containment: c) { await extend(c, seconds: $0) } }
        }
        .confirmationDialog(title(for: pending), isPresented: Binding(get: { pending != nil }, set: { if !$0 { pending = nil } }),
                            titleVisibility: .visible) {
            switch pending {
            case .release(let c): Button("Release", role: .destructive) { Task { await run(c) { try await client.releaseContainment(id: $0) } } }
            case .rollBack(let c): Button("Roll Back", role: .destructive) { Task { await run(c) { try await client.rollBackContainment(id: $0) } } }
            case nil: EmptyView()
            }
        } message: { Text(message(for: pending)) }
        .safeAreaInset(edge: .bottom) { if let failure { InlineError(message: failure) { self.failure = nil } } }
    }

    private var list: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Look up by containment ID", text: $lookupID).textFieldStyle(.roundedBorder)
                    .onSubmit { Task { await lookup() } }
                Button("Look Up") { Task { await lookup() } }.disabled(lookupID.trimmingCharacters(in: .whitespaces).isEmpty)
            }.padding(8)
            if items.isEmpty {
                ContentUnavailableView("No containments shown", systemImage: "lock.shield",
                    description: Text("Zeus OS can't list containments. Create one, or look one up by its ID."))
            } else {
                Table(items, selection: $selection) {
                    TableColumn("Workload") { Text($0.workloadID ?? "—") }
                    TableColumn("Profile") { Text($0.profile ?? "—") }
                    TableColumn("State") { StatusBadge(status: $0.actualState ?? "unknown") }.width(min: 90, ideal: 120)
                }
            }
        }
    }

    @ViewBuilder private var detail: some View {
        if let c = selected {
            Form {
                Section("Containment") {
                    LabeledContent("ID", value: c.id)
                    LabeledContent("Workload", value: c.workloadID ?? "—")
                    LabeledContent("Profile", value: c.profile ?? "—")
                    LabeledContent("Backend", value: c.backend ?? "—")
                    LabeledContent("Desired state") { StatusBadge(status: c.desiredState ?? "unknown") }
                    LabeledContent("Actual state") { StatusBadge(status: c.actualState ?? "unknown") }
                    if let r = c.reason, !r.isEmpty { LabeledContent("Reason", value: r) }
                    if let b = c.connectionBehavior { LabeledContent("Connections", value: b) }
                    if let e = c.expiresAt { LabeledContent("Auto-releases", value: e) }
                }
                if let events = c.events, !events.isEmpty {
                    Section("Events") {
                        ForEach(Array(events.enumerated()), id: \.offset) { _, e in
                            VStack(alignment: .leading) {
                                Text(e.kind ?? "event").font(.callout.weight(.medium))
                                Text(e.detail ?? "").font(.caption).foregroundStyle(.secondary)
                                Text(e.at ?? "").font(.caption2).foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
                if model.canWrite {
                    Section {
                        HStack {
                            Button("Refresh", systemImage: "arrow.clockwise") { Task { await reload(c) } }
                            Button("Change Duration…", systemImage: "timer") { extending = true }.disabled(!c.isLive)
                            Spacer()
                            Button("Roll Back…", systemImage: "arrow.uturn.backward") { pending = .rollBack(c) }.disabled(busy)
                            Button("Release…", systemImage: "lock.open", role: .destructive) { pending = .release(c) }
                                .disabled(busy || !c.isLive)
                        }
                    }
                }
            }
            .formStyle(.grouped)
        } else {
            ContentUnavailableView("Select a containment", systemImage: "sidebar.right")
        }
    }

    private func title(for p: Pending?) -> String {
        switch p {
        case .release(let c): "Release \(c.workloadID ?? c.id)?"
        case .rollBack(let c): "Roll back \(c.workloadID ?? c.id)?"
        case nil: ""
        }
    }

    private func message(for p: Pending?) -> String {
        switch p {
        case .release: "The workload's network access is restored."
        case .rollBack: "Undoes what the containment changed on the backend."
        case nil: ""
        }
    }

    private func remember(_ c: Containment) {
        if let i = items.firstIndex(where: { $0.id == c.id }) { items[i] = c } else { items.insert(c, at: 0) }
        selection = c.id
        savedIDs = Self.encode(Self.merged([c.id], into: Self.decode(savedIDs)))
    }

    /// Re-reads remembered containments. One the server no longer has (404) is dropped from the list.
    private func restore() async {
        guard items.isEmpty else { return }
        var keep: [String] = []
        for id in Self.decode(savedIDs) {
            do { let c = try await client.containment(id: id); items.append(c); keep.append(id) }
            catch ZeusError.server(let status, _) where status == 404 { }
            catch { keep.append(id) }
        }
        savedIDs = Self.encode(keep)
    }

    static func decode(_ s: String) -> [String] { s.split(separator: "\n").map(String.init) }
    static func encode(_ ids: [String]) -> String { ids.joined(separator: "\n") }
    /// New ids go first; duplicates are removed; the list is capped so it can't grow forever.
    static func merged(_ new: [String], into old: [String], limit: Int = 50) -> [String] {
        var seen = Set<String>()
        return Array((new + old).filter { seen.insert($0).inserted }.prefix(limit))
    }

    private func create(_ r: ContainmentRequest) async -> String? {
        do { remember(try await client.createContainment(r)); failure = nil; return nil }
        catch { return describe(error, "contain workloads") }
    }

    private func lookup() async {
        let id = lookupID.trimmingCharacters(in: .whitespaces)
        guard !id.isEmpty else { return }
        do { remember(try await client.containment(id: id)); failure = nil; lookupID = "" }
        catch { failure = describe(error, "look up that containment") }
    }

    private func reload(_ c: Containment) async {
        do { remember(try await client.containment(id: c.id)); failure = nil }
        catch { failure = describe(error, "refresh the containment") }
    }

    private func run(_ c: Containment, _ call: (String) async throws -> Containment) async {
        busy = true; defer { busy = false }
        do { remember(try await call(c.id)); failure = nil }
        catch { failure = describe(error, "change the containment") }
    }

    private func extend(_ c: Containment, seconds: Int) async -> String? {
        do { remember(try await client.updateContainment(id: c.id, durationSeconds: seconds)); return nil }
        catch { return describe(error, "change the duration") }
    }
}

/// Create form. The destructive part is the confirmation text: containing a workload cuts its network.
struct ContainmentEditor: View {
    let onSave: (ContainmentRequest) async -> String?
    @Environment(\.dismiss) private var dismiss
    @State private var target = ""
    @State private var profile = ContainmentProfile.internetLock
    @State private var behavior = ConnectionBehavior.blockNew
    @State private var customMode = ""
    @State private var reason = ""
    @State private var minutes = ""
    @State private var preserve = ""
    @State private var confirming = false
    @State private var failure: String?
    @State private var working = false

    private var request: ContainmentRequest {
        ContainmentRequest(targetID: target.trimmingCharacters(in: .whitespaces), profile: profile,
                           reason: reason.isEmpty ? nil : reason,
                           durationSeconds: Int(minutes.trimmingCharacters(in: .whitespaces)).map { $0 * 60 },
                           customMode: profile == .custom ? customMode : nil, connectionBehavior: behavior,
                           preserve: preserve.split(whereSeparator: { ",\n".contains($0) })
                               .map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty })
    }
    private var minutesInvalid: Bool { !minutes.isEmpty && Int(minutes.trimmingCharacters(in: .whitespaces)) == nil }

    var body: some View {
        VStack(spacing: 0) {
            Text("Contain a Workload").font(.headline).padding()
            Form {
                TextField("Workload", text: $target, prompt: Text("vm:default/web-01"))
                Picker("Profile", selection: $profile) { ForEach(ContainmentProfile.allCases) { Text($0.rawValue).tag($0) } }
                if profile == .custom { TextField("Custom mode", text: $customMode) }
                Picker("Existing connections", selection: $behavior) { ForEach(ConnectionBehavior.allCases) { Text($0.rawValue).tag($0) } }
                TextField("Auto-release after (minutes, optional)", text: $minutes)
                TextField("Keep reachable (comma-separated, optional)", text: $preserve)
                TextField("Reason (optional)", text: $reason)
                if let failure { InlineError(message: failure) { self.failure = nil } }
            }
            .formStyle(.grouped)
            HStack {
                Button("Cancel", role: .cancel) { dismiss() }
                Spacer()
                Button("Contain…") {
                    if let p = request.problem() { failure = p } else if minutesInvalid { failure = "Minutes must be a whole number." }
                    else { confirming = true }
                }
                .buttonStyle(.borderedProminent).disabled(working)
            }.padding()
        }
        .frame(width: 520)
        .confirmationDialog("Contain \(target)?", isPresented: $confirming, titleVisibility: .visible) {
            Button("Contain", role: .destructive) { Task { await save() } }
        } message: { Text("This cuts the workload's network access according to the \(profile.rawValue) profile.") }
    }

    private func save() async {
        working = true; defer { working = false }
        if let f = await onSave(request) { failure = f } else { dismiss() }
    }
}

struct ExtendContainmentSheet: View {
    let containment: Containment
    let onSave: (Int) async -> String?
    @Environment(\.dismiss) private var dismiss
    @State private var minutes = ""
    @State private var failure: String?

    var body: some View {
        VStack(spacing: 12) {
            Text("Change Duration").font(.headline)
            Text("Sets the auto-release window, counted from now.").font(.callout).foregroundStyle(.secondary)
            TextField("Minutes from now", text: $minutes).frame(width: 220)
            if let failure { InlineError(message: failure) { self.failure = nil } }
            HStack {
                Button("Cancel", role: .cancel) { dismiss() }
                Spacer()
                Button("Save") {
                    guard let m = Int(minutes.trimmingCharacters(in: .whitespaces)), m > 0 else {
                        failure = "Enter a whole number of minutes, more than zero."; return
                    }
                    Task { if let f = await onSave(m * 60) { failure = f } else { dismiss() } }
                }.buttonStyle(.borderedProminent)
            }
        }
        .padding().frame(width: 360)
    }
}
