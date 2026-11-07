import SwiftUI
import ZeusKit

/// Logs explorer: pick a namespace and pod, read the tail, filter by level and text.
/// Log text can be sensitive; it is shown only, never stored or sent anywhere else.
struct LogsView: View {
    let client: ZeusClient
    @State private var namespace = "default"
    @State private var sources: [LogSource] = []
    @State private var selected: LogSource.ID?
    @State private var lines: [LogLine] = []
    @State private var stats: LogStats?
    @State private var tail = 200
    @State private var level = "all"
    @State private var search = ""
    @State private var error: String?
    @State private var loading = false

    private var source: LogSource? { sources.first { $0.id == selected } }

    private var shown: [LogLine] {
        lines.filter { level == "all" || $0.level.hasPrefix(level) }
            .filter { search.isEmpty || $0.raw.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Namespace", text: $namespace).frame(width: 160).onSubmit { Task { await loadSources() } }
                Picker("Pod", selection: $selected) {
                    Text("Choose a pod").tag(LogSource.ID?.none)
                    ForEach(sources) { Text($0.name).tag(Optional($0.id)) }
                }.frame(maxWidth: 360)
                Picker("Lines", selection: $tail) { ForEach([100, 200, 500, 1000], id: \.self) { Text("\($0)").tag($0) } }.frame(width: 120)
                Picker("Level", selection: $level) {
                    Text("All").tag("all"); Text("Errors").tag("error"); Text("Warnings").tag("warn"); Text("Info").tag("info")
                }.pickerStyle(.segmented).frame(width: 260)
                Spacer()
                if loading { ProgressView().controlSize(.small) }
            }.padding()
            if let s = stats {
                Text("\(s.totalPods ?? 0) pods · \(s.podsWithErrors ?? 0) with errors · error rate \(s.errorRatePercent ?? 0, specifier: "%.1f")% in the last \(s.totalLogLines ?? 0) lines")
                    .font(.callout).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
            }
            Divider().padding(.top, 8)
            if let error {
                ContentUnavailableView("Couldn't load logs", systemImage: "exclamationmark.triangle", description: Text(error))
            } else if source == nil {
                ContentUnavailableView("Choose a pod", systemImage: "text.alignleft",
                                       description: Text(sources.isEmpty ? "No pods found in this namespace." : "Pick a pod to read its recent logs."))
            } else if shown.isEmpty {
                ContentUnavailableView(lines.isEmpty ? "No log lines" : "No matches", systemImage: "text.alignleft")
            } else {
                Table(shown) {
                    TableColumn("Time") { l in
                        if let d = l.timestamp { Text(d, format: .dateTime.hour().minute().second()) } else { Text("") }
                    }.width(min: 70, ideal: 80)
                    TableColumn("Level") { l in
                        Text(l.level).foregroundStyle(l.level.hasPrefix("err") ? .red : l.level.hasPrefix("warn") ? .orange : .secondary)
                    }.width(min: 60, ideal: 70)
                    TableColumn("Message") { l in Text(l.message).font(.system(.body, design: .monospaced)).lineLimit(2).textSelection(.enabled).help(l.raw) }
                }
            }
        }
        .navigationTitle("Logs")
        .searchable(text: $search, prompt: "Filter lines")
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loadLogs() } } } }
        .task { await loadSources() }
        .task(id: "\(selected ?? "")|\(tail)") { await loadLogs() }
    }

    private func loadSources() async {
        error = nil
        async let st = try? client.logStats(namespace: namespace)
        do { sources = try await client.logSources(namespace: namespace) } catch { self.error = "Check the namespace and your access."; sources = [] }
        stats = await st
        if source == nil { selected = sources.first?.id }
    }

    private func loadLogs() async {
        guard let source else { lines = []; return }
        loading = true; defer { loading = false }
        do {
            let p = try await client.podLogs(namespace: namespace, pod: source.name, container: source.container, tail: tail)
            lines = p.logs.enumerated().map { LogLine(id: $0.offset, raw: $0.element) }.reversed()
            error = nil
        } catch { self.error = "Couldn't read this pod's logs." }
    }
}
