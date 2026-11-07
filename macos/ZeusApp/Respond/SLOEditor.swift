import SwiftUI
import ZeusKit

/// Creates an SLO (`POST /slo/slos`). The server exposes no delete route for SLOs, so there is none here.
struct SLOEditor: View {
    let onSave: (SLOInput) async -> String?

    @State private var name = ""
    @State private var namespace = "default"
    @State private var service = ""
    @State private var sloType = "Availability"
    @State private var target = "99.9"
    @State private var days = "30"
    @State private var working = false
    @State private var failure: String?

    private var targetValue: Double? { Double(target.trimmingCharacters(in: .whitespaces)).flatMap { (0...100).contains($0) ? $0 : nil } }
    private var daysValue: Int? { Int(days.trimmingCharacters(in: .whitespaces)).flatMap { $0 > 0 ? $0 : nil } }
    private var valid: Bool {
        ![name, namespace, service].contains { $0.trimmingCharacters(in: .whitespaces).isEmpty } && targetValue != nil && daysValue != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("New SLO").font(.headline).padding()
            Form {
                TextField("Name", text: $name)
                TextField("Namespace", text: $namespace)
                TextField("Service", text: $service, prompt: Text("e.g. VirtualMachines"))
                Picker("Type", selection: $sloType) {
                    Text("Availability").tag("Availability"); Text("Error rate").tag("ErrorRate")
                }
                TextField("Target (%)", text: $target)
                TextField("Window (days)", text: $days)
            }
            .formStyle(.grouped)
            EditorFooter(saveTitle: "Create", canSave: valid, working: $working, failure: $failure) {
                await onSave(SLOInput(name: name.trimmingCharacters(in: .whitespaces), namespace: namespace.trimmingCharacters(in: .whitespaces),
                                      service: service.trimmingCharacters(in: .whitespaces), sloType: sloType,
                                      targetPercentage: targetValue ?? 0, timeWindowDays: daysValue ?? 0))
            }
        }
        .frame(width: 420)
    }
}
