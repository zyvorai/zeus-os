import SwiftUI
import ZeusKit

/// One screen over a group of related read-only feeds, chosen with a picker.
struct SchedScreen: View {
    let client: ZeusClient
    let feeds: [SchedFeed]
    @State private var selected: SchedFeed

    init(client: ZeusClient, feeds: [SchedFeed]) {
        self.client = client; self.feeds = feeds; _selected = State(initialValue: feeds[0])
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Feed", selection: $selected) {
                ForEach(feeds) { Text($0.title).tag($0) }
            }
            .pickerStyle(.menu).labelsHidden().frame(maxWidth: 260, alignment: .leading)
            .padding([.horizontal, .top]).frame(maxWidth: .infinity, alignment: .leading)
            SchedFeedView(client: client, feed: selected).id(selected.id)
        }
    }
}

private struct SchedFeedView: View {
    let client: ZeusClient
    let feed: SchedFeed

    var body: some View {
        switch feed.kind {
        case .json: JSONFeedView(client: client, feed: feed)
        case .priorityClasses: PriorityClassesView(client: client)
        case .pdbs: PDBsView(client: client)
        }
    }
}

private struct JSONFeedView: View {
    @State private var loader: Loader<JSONValue>
    init(client: ZeusClient, feed: SchedFeed) {
        _loader = State(initialValue: Loader { try await client.schedFeed(feed) })
    }
    var body: some View {
        LoadStateView(loader: loader) { value in
            if let rows = value.tableRows {
                JSONTable(rows: rows)
            } else {
                List { JSONOutline(value: value) }
            }
        }
        .task { loader.start() }
        .onDisappear { loader.stop() }
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
    }
}

private struct PriorityClassesView: View {
    @State private var loader: Loader<[PriorityClassInfo]>
    init(client: ZeusClient) { _loader = State(initialValue: Loader { try await client.priorityClasses() }) }
    var body: some View {
        LoadStateView(loader: loader) { items in
            if items.isEmpty {
                ContentUnavailableView("No priority classes", systemImage: "list.number")
            } else {
                Table(items) {
                    TableColumn("Name", value: \.name)
                    TableColumn("Value") { Text($0.value.map(String.init) ?? "—").monospacedDigit() }
                    TableColumn("Default") { Text($0.globalDefault == true ? "Yes" : "No") }
                    TableColumn("Preemption") { Text($0.preemptionPolicy ?? "—") }
                    TableColumn("Pods") { Text($0.usageCount.map(String.init) ?? "—").monospacedDigit() }
                    TableColumn("Description") { Text($0.description ?? "").lineLimit(1) }
                }
            }
        }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}

private struct PDBsView: View {
    @State private var loader: Loader<[PDBStatus]>
    init(client: ZeusClient) { _loader = State(initialValue: Loader { try await client.pdbStatuses() }) }
    private func unset(_ s: String?) -> String { (s == nil || s == "N/A") ? "—" : s! }
    var body: some View {
        LoadStateView(loader: loader) { items in
            if items.isEmpty {
                ContentUnavailableView("No disruption budgets", systemImage: "shield")
            } else {
                Table(items) {
                    TableColumn("Name", value: \.name)
                    TableColumn("Namespace", value: \.namespace)
                    TableColumn("Min available") { Text(unset($0.minAvailable)) }
                    TableColumn("Max unavailable") { Text(unset($0.maxUnavailable)) }
                    TableColumn("Healthy") { Text("\($0.currentHealthy ?? 0) / \($0.expectedPods ?? 0)").monospacedDigit() }
                    TableColumn("Disruptions allowed") { Text($0.disruptionsAllowed.map(String.init) ?? "—").monospacedDigit() }
                }
            }
        }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}
