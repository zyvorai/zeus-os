import SwiftUI
import ZeusKit

/// Footer shared by the Respond editors: Cancel / Save, with the server's error shown inline and the sheet kept
/// open on failure.
struct EditorFooter: View {
    @Environment(\.dismiss) private var dismiss
    let saveTitle: String
    let canSave: Bool
    @Binding var working: Bool
    @Binding var failure: String?
    let save: () async -> String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let failure { Label(failure, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange).font(.callout) }
            HStack {
                if working { ProgressView().controlSize(.small) }
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                Button(saveTitle) {
                    working = true; failure = nil
                    Task {
                        let err = await save()
                        working = false
                        if let err { failure = err } else { dismiss() }
                    }
                }
                .keyboardShortcut(.defaultAction).disabled(working || !canSave)
            }
        }
        .padding([.horizontal, .bottom])
    }
}

/// Create or edit an alerting rule. Editing sends a full replacement built from what the server returned.
struct AlertRuleEditor: View {
    let title: String
    let channels: [AlertingChannel]
    let onSave: (AlertRuleInput) async -> String?
    private let base: AlertRuleInput

    @State private var name: String
    @State private var description: String
    @State private var severity: String
    @State private var metric: String
    @State private var op: String
    @State private var threshold: String
    @State private var duration: String
    @State private var selected: Set<String>
    @State private var working = false
    @State private var failure: String?

    static let severities = ["critical", "warning", "info"]
    static let operators = [">", ">=", "<", "<=", "==", "!="]

    init(title: String, initial: AlertRuleInput?, channels: [AlertingChannel], onSave: @escaping (AlertRuleInput) async -> String?) {
        let b = initial ?? AlertRuleInput(name: "", description: "", severity: "warning",
                                          condition: .init(metric: "", operator: ">", threshold: 0, durationMinutes: 5),
                                          notificationChannels: [])
        self.title = title; self.channels = channels; self.onSave = onSave; self.base = b
        _name = State(initialValue: b.name); _description = State(initialValue: b.description)
        _severity = State(initialValue: b.severity); _metric = State(initialValue: b.condition.metric)
        _op = State(initialValue: b.condition.operator)
        _threshold = State(initialValue: initial == nil ? "" : String(b.condition.threshold))
        _duration = State(initialValue: String(b.condition.durationMinutes))
        _selected = State(initialValue: Set(b.notificationChannels))
    }

    private var thresholdValue: Double? { Double(threshold.trimmingCharacters(in: .whitespaces)) }
    private var durationValue: Int? { Int(duration.trimmingCharacters(in: .whitespaces)).flatMap { $0 >= 0 ? $0 : nil } }
    private var valid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !metric.trimmingCharacters(in: .whitespaces).isEmpty
            && thresholdValue != nil && durationValue != nil
    }
    private var channelIDs: [String] {
        var ids = channels.map(\.channelId)
        for s in selected.sorted() where !ids.contains(s) { ids.append(s) }     // keep ids the list doesn't know
        return ids
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(title).font(.headline).padding()
            Form {
                TextField("Name", text: $name)
                TextField("Description", text: $description)
                Picker("Severity", selection: $severity) {
                    ForEach(Self.severities + (Self.severities.contains(severity) ? [] : [severity]), id: \.self) { Text($0.capitalized).tag($0) }
                }
                TextField("Metric", text: $metric, prompt: Text("e.g. cpu"))
                Picker("Operator", selection: $op) {
                    ForEach(Self.operators + (Self.operators.contains(op) ? [] : [op]), id: \.self) { Text($0).tag($0) }
                }
                TextField("Threshold", text: $threshold)
                TextField("For (minutes)", text: $duration)
                Section("Notify") {
                    if channelIDs.isEmpty { Text("No channels are defined.").foregroundStyle(.secondary) }
                    ForEach(channelIDs, id: \.self) { id in
                        Toggle(channels.first { $0.channelId == id }?.name ?? id, isOn: Binding(
                            get: { selected.contains(id) },
                            set: { if $0 { selected.insert(id) } else { selected.remove(id) } }))
                    }
                }
                if !base.condition.filters.isEmpty {
                    Text("Existing filters on this rule are kept as they are.").font(.caption).foregroundStyle(.secondary)
                }
            }
            .formStyle(.grouped)
            EditorFooter(saveTitle: "Save", canSave: valid, working: $working, failure: $failure) {
                var input = base
                input.name = name.trimmingCharacters(in: .whitespaces); input.description = description
                input.severity = severity
                input.condition.metric = metric.trimmingCharacters(in: .whitespaces)
                input.condition.operator = op
                input.condition.threshold = thresholdValue ?? 0
                input.condition.durationMinutes = durationValue ?? 0
                input.notificationChannels = channelIDs.filter(selected.contains)
                return await onSave(input)
            }
        }
        .frame(width: 460)
    }
}
