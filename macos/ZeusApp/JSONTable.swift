import SwiftUI
import ZeusKit

/// A searchable table over free-form JSON rows, for the long tail of list endpoints whose shape the spec
/// leaves open. Columns are the scalar keys that appear most often (name-like keys first); selecting a row
/// opens the full record in an inspector. Screens with a known shape should still use a typed model.
struct JSONTable: View {
    let rows: [JSONValue]
    var emptyTitle = "Nothing here"
    var emptyDescription = "No items for this account."
    @State private var search = ""
    @State private var selection: Int?

    private static let nameKeys = ["name", "id", "title", "namespace", "status", "phase", "type", "kind"]

    private var columns: [String] {
        var freq: [String: Int] = [:]
        for r in rows.prefix(200) {
            for (k, v) in r.object ?? [:] where v.isScalar { freq[k, default: 0] += 1 }
        }
        let keys = freq.keys.sorted { a, b in
            let ia = Self.nameKeys.firstIndex(of: a) ?? Int.max, ib = Self.nameKeys.firstIndex(of: b) ?? Int.max
            return ia != ib ? ia < ib : (freq[a]! != freq[b]! ? freq[a]! > freq[b]! : a < b)
        }
        return Array(keys.prefix(6))
    }

    private var shown: [(index: Int, row: JSONValue)] {
        rows.enumerated().map { ($0.offset, $0.element) }.filter { _, r in
            search.isEmpty || (r.object ?? [:]).values.contains { $0.string?.localizedCaseInsensitiveContains(search) == true }
        }
    }

    var body: some View {
        Group {
            if rows.isEmpty {
                ContentUnavailableView(emptyTitle, systemImage: "tray", description: Text(emptyDescription))
            } else if shown.isEmpty {
                ContentUnavailableView.search(text: search)
            } else {
                Table(of: IndexedRow.self, selection: $selection) {
                    TableColumn("") { Text("\($0.id + 1)").foregroundStyle(.tertiary) }.width(36)
                    TableColumnForEach(columns, id: \.self) { key in
                        TableColumn(key.replacing("_", with: " ").capitalized) { Text($0.row[key]?.string ?? "—").lineLimit(1) }
                    }
                } rows: {
                    ForEach(shown, id: \.index) { TableRow(IndexedRow(id: $0.index, row: $0.row)) }
                }
            }
        }
        .searchable(text: $search, prompt: "Search")
        .inspector(isPresented: Binding(get: { selection != nil }, set: { if !$0 { selection = nil } })) {
            if let i = selection, rows.indices.contains(i) {
                List { JSONOutline(value: rows[i]) }.inspectorColumnWidth(min: 260, ideal: 340)
            }
        }
    }

    struct IndexedRow: Identifiable { let id: Int; let row: JSONValue }
}

extension JSONValue {
    var isScalar: Bool {
        switch self { case .object, .array: false; default: true }
    }
}
