import SwiftUI
import ZeusKit

struct MachinesView: View {
    @Environment(AppModel.self) private var model
    @State private var selection: VM.ID?
    @State private var search = ""
    @State private var sort = [KeyPathComparator(\VM.name)]

    private var rows: [VM] {
        model.vms.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }
            .sorted(using: sort)
    }

    var body: some View {
        Table(rows, selection: $selection, sortOrder: $sort) {
            TableColumn("Name", value: \.name)
            TableColumn("Status", value: \.status) { vm in
                Label(vm.status, systemImage: "circle.fill")
                    .foregroundStyle(vm.status == "Running" ? .green : .secondary)
            }
            TableColumn("Namespace", value: \.namespace)
            TableColumn("Node") { Text($0.node ?? "—") }
            TableColumn("Age") { Text($0.age ?? "—") }
        }
        .overlay { if rows.isEmpty { ContentUnavailableView.search(text: search) } }
        .searchable(text: $search)
        .inspector(isPresented: .constant(selection != nil)) {
            if let vm = model.vms.first(where: { $0.id == selection }) { VMInspector(vm: vm) }
        }
        .navigationTitle("Machines")
    }
}

struct VMInspector: View {
    let vm: VM
    @Environment(AppModel.self) private var model

    var body: some View {
        Form {
            LabeledContent("Name", value: vm.name)
            LabeledContent("Namespace", value: vm.namespace)
            LabeledContent("Status", value: vm.status)
            LabeledContent("Node", value: vm.node ?? "—")
            LabeledContent("Memory", value: vm.memoryGi.map { "\($0) GiB" } ?? "—")
            LabeledContent("Security", value: vm.securityScore.map(String.init) ?? "—")
            if !model.canWrite {
                Text("Your role is read-only.").font(.footnote).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .inspectorColumnWidth(min: 240, ideal: 280)
    }
}
