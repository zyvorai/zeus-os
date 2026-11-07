import SwiftUI
import ZeusKit

/// Create a machine. Two paths, both defined unambiguously by the server's OpenAPI document:
/// - Instance type: the app generates a small KubeVirt manifest, shows it, and sends it to `POST /vms`.
/// - Template: `POST /templates/{namespace}/{name}/instantiate`, for templates that live in a namespace.
///   Built-in templates (empty namespace) are not offered because the spec gives no address for them.
struct NewMachineSheet: View {
    let client: ZeusClient
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    private enum Source: String, CaseIterable, Identifiable {
        case instanceType = "Instance type", template = "Template"
        var id: Self { self }
    }

    @State private var source = Source.instanceType
    @State private var name = ""
    @State private var namespace = "default"
    @State private var namespaces: [String] = ["default"]
    @State private var disk = 20
    @State private var types: [InstanceTypeInfo] = []
    @State private var preferences: [InstancePreferenceInfo] = []
    @State private var templates: [VMTemplateInfo] = []
    @State private var instanceType = ""
    @State private var preference = ""
    @State private var image = ""
    @State private var templateID = ""
    @State private var loaded = false
    @State private var reviewing = false
    @State private var working = false
    @State private var failure: String?

    private var nameOK: Bool { NewMachineManifest.validName(name) }
    private var imageText: String? { image.trimmingCharacters(in: .whitespaces).isEmpty ? nil : image.trimmingCharacters(in: .whitespaces) }
    private var usable: [VMTemplateInfo] { templates.filter { !$0.isBuiltIn } }
    private var hiddenBuiltIns: Int { templates.count - usable.count }
    private var template: VMTemplateInfo? { usable.first { $0.id == templateID } }
    private var imageOK: Bool { imageText.map(NewMachineManifest.validImage) ?? true }

    private var yaml: String? {
        NewMachineManifest.yaml(name: name, namespace: namespace, instanceType: instanceType,
                                preference: preference.isEmpty ? nil : preference, diskSizeGi: disk, image: imageText)
    }

    private var ready: Bool {
        guard nameOK, !namespace.isEmpty, (1...65536).contains(disk), !working else { return false }
        switch source {
        case .instanceType: return yaml != nil
        case .template: return template != nil
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if reviewing { review } else { form }
            if let failure { InlineError(message: failure) { self.failure = nil } }
            HStack {
                if reviewing { Button("Back") { reviewing = false } }
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                if reviewing {
                    Button("Create Machine") { create() }.keyboardShortcut(.defaultAction).disabled(working)
                } else {
                    Button("Review…") { failure = nil; reviewing = true }
                        .keyboardShortcut(.defaultAction).disabled(!ready)
                }
            }.padding()
        }
        .frame(width: 540, height: 520)
        .task { await load() }
    }

    private var form: some View {
        Form {
            Text("New machine").font(.headline)
            Picker("Create from", selection: $source) {
                ForEach(Source.allCases) { Text($0.rawValue).tag($0) }
            }.pickerStyle(.segmented)
            TextField("Name", text: $name, prompt: Text("my-machine"))
            if !name.isEmpty && !nameOK {
                Text("Use lowercase letters, digits, '-' and '.', starting and ending with a letter or digit.")
                    .font(.caption).foregroundStyle(.red)
            }
            Picker("Namespace", selection: $namespace) {
                ForEach(namespaces, id: \.self) { Text($0).tag($0) }
            }
            switch source {
            case .instanceType:
                Picker("Instance type", selection: $instanceType) {
                    Text("Choose…").tag("")
                    ForEach(types) { Text(label($0)).tag($0.name) }
                }
                Picker("Preference", selection: $preference) {
                    Text("None").tag("")
                    ForEach(preferences) { Text($0.name).tag($0.name) }
                }
                TextField("Boot image (optional)", text: $image, prompt: Text("quay.io/containerdisks/fedora:latest"))
                if !imageOK { Text("That doesn't look like a registry image reference.").font(.caption).foregroundStyle(.red) }
                Stepper("Disk: \(disk) GiB", value: $disk, in: 1...2048, step: 5)
                if imageText == nil {
                    Text("Without a boot image the disk is blank; attach an OS afterwards.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            case .template:
                if loaded && usable.isEmpty {
                    Text("No namespaced templates are available.").foregroundStyle(.secondary)
                } else {
                    Picker("Template", selection: $templateID) {
                        Text("Choose…").tag("")
                        ForEach(usable) { Text("\($0.title) (\($0.namespace ?? ""))").tag($0.id) }
                    }
                    Stepper("Disk: \(disk) GiB", value: $disk, in: 1...2048, step: 5)
                }
                if hiddenBuiltIns > 0 {
                    Text("\(hiddenBuiltIns) built-in templates aren't listed: the API has no address for creating a machine from one.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
    }

    private var review: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Review").font(.headline)
            switch source {
            case .instanceType:
                Text("This manifest is sent to the server as written. The machine is created stopped.")
                    .font(.callout).foregroundStyle(.secondary)
                ScrollView { Text(yaml ?? "").font(.body.monospaced()).textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading) }
                    .padding(8).border(.separator)
            case .template:
                Form {
                    LabeledContent("Template", value: template?.title ?? "")
                    LabeledContent("Name", value: name)
                    LabeledContent("Namespace", value: namespace)
                    LabeledContent("Disk", value: "\(disk) GiB")
                }.formStyle(.grouped)
            }
        }
        .padding([.horizontal, .top])
        .frame(maxHeight: .infinity)
    }

    private func label(_ t: InstanceTypeInfo) -> String {
        "\(t.name)  (\(t.cpuCores.map(String.init) ?? "?") vCPU, \(t.memory ?? "?"))"
    }

    private func load() async {
        async let ns = try? client.namespaces()
        async let ty = try? client.instanceTypes()
        async let pr = try? client.instancePreferences()
        async let tp = try? client.templates()
        let (n, t, p, tm) = await (ns, ty, pr, tp)
        if let n, !n.isEmpty { namespaces = n.map(\.name).sorted(); if !namespaces.contains(namespace) { namespace = namespaces[0] } }
        types = t ?? []; preferences = p ?? []; templates = tm ?? []
        if t == nil { failure = "Couldn't load instance types." }
        loaded = true
    }

    private func create() {
        working = true; failure = nil
        let src = source, yamlText = yaml, tpl = template
        Task {
            do {
                switch src {
                case .instanceType:
                    guard let yamlText else { throw ZeusError.server(status: 0, message: "Invalid machine settings.") }
                    try await client.createVM(yaml: yamlText)
                case .template:
                    guard let tpl else { throw ZeusError.server(status: 0, message: "Choose a template.") }
                    try await client.instantiate(tpl, name: name, namespace: namespace, diskSizeGi: Double(disk))
                }
                _ = await model.refresh(quiet: true)
                dismiss()
            } catch ZeusError.unauthorized {
                model.signOut(forget: false); model.error = "Session expired. Sign in again."
            } catch {
                failure = describe(error, "create the machine"); working = false
            }
        }
    }
}
