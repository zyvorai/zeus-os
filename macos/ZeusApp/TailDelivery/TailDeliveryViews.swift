import SwiftUI
import ZeusKit

struct TailSection: Identifiable {
    let id: String
    let label: String
    let path: [String]
    init(_ label: String, _ path: String...) { self.id = path.joined(separator: "/"); self.label = label; self.path = path }
}

/// A picker over several read-only endpoints. List responses show as a searchable table with a record
/// inspector; single-record responses (status, stats, graphs) show as an outline. Server refusals such as
/// "not configured" are shown verbatim rather than as a generic failure.
struct TailSectionsView: View {
    let title: String
    let client: ZeusClient
    let sections: [TailSection]
    @State private var selected: String
    @State private var value: JSONValue?
    @State private var failure: String?

    init(title: String, client: ZeusClient, sections: [TailSection]) {
        self.title = title; self.client = client; self.sections = sections
        _selected = State(initialValue: sections[0].id)
    }

    private var current: TailSection { sections.first { $0.id == selected } ?? sections[0] }

    private func load() async {
        value = nil; failure = nil
        do {
            value = try await client.tailValue(current.path)
        } catch is CancellationError {
        } catch ZeusError.server(let status, let message) {
            failure = status == 403 ? "Your role can't view this." : (message.isEmpty ? "The server returned \(status)." : message)
        } catch {
            failure = "Couldn't load. Check the connection and try again."
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Section", selection: $selected) { ForEach(sections) { Text($0.label).tag($0.id) } }
                .pickerStyle(.menu).labelsHidden().padding()
            Group {
                if let failure {
                    ContentUnavailableView("Unavailable", systemImage: "exclamationmark.triangle", description: Text(failure))
                } else if let value {
                    if let rows = value.tailRows {
                        JSONTable(rows: rows, emptyTitle: "Nothing here",
                                  emptyDescription: "The server returned no \(current.label.lowercased()).")
                    } else {
                        List { JSONOutline(value: value) }
                    }
                } else {
                    ProgressView().controlSize(.large)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle(title)
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await load() } } } }
        .task(id: selected) { await load() }
    }
}
