import Foundation

// Machine write actions. The contracts come from the server's OpenAPI document:
//   POST /vms                                  {yaml, auto_expose_ssh?, auto_expose_rdp?}
//   POST /templates/{ns}/{name}/instantiate    {template_id, vm_name, namespace, customize?, parameters?}
//   POST /vms/bulk                             {action, vms:[{name,namespace}], options?, operation_id?}
//   POST /vms/labels/apply                     {vms:[{name,namespace}], labels:{}, remove_labels?:[]}
// None of these is exercised against a live server; the request shapes are unit-tested.

public struct BulkActionResult: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let namespace: String
    public let success: Bool
    public let message: String
    public var id: String { "\(namespace)/\(name)" }

    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        namespace = try c.decodeIfPresent(String.self, forKey: .namespace) ?? ""
        success = try c.decodeIfPresent(Bool.self, forKey: .success) ?? false
        message = try c.decodeIfPresent(String.self, forKey: .message) ?? ""
    }
    enum CodingKeys: String, CodingKey { case name, namespace, success, message }
}

public struct BulkActionResponse: Decodable, Sendable {
    public let total: Int
    public let succeeded: Int
    public let failed: Int
    public let results: [BulkActionResult]

    public init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        results = try c.decodeIfPresent([BulkActionResult].self, forKey: .results) ?? []
        total = try c.decodeIfPresent(Int.self, forKey: .total) ?? results.count
        succeeded = try c.decodeIfPresent(Int.self, forKey: .succeeded) ?? results.filter(\.success).count
        failed = try c.decodeIfPresent(Int.self, forKey: .failed) ?? results.filter { !$0.success }.count
    }
    enum CodingKeys: String, CodingKey { case total, succeeded, failed, results }

    public var failures: [BulkActionResult] { results.filter { !$0.success } }
}

struct VMTargetBody: Encodable { let name: String; let namespace: String }
struct BulkBody: Encodable { let action: String; let vms: [VMTargetBody] }
struct ApplyLabelsBody: Encodable {
    let vms: [VMTargetBody]
    let labels: [String: String]
    let removeLabels: [String]?
    enum CodingKeys: String, CodingKey { case vms, labels, removeLabels = "remove_labels" }
}
struct CreateVMBody: Encodable { let yaml: String }
struct InstantiateBody: Encodable {
    struct Customize: Encodable {
        let diskSizeGi: Double?
        enum CodingKeys: String, CodingKey { case diskSizeGi = "disk_size_gi" }
    }
    let templateId: String
    let vmName: String
    let namespace: String
    let customize: Customize?
    enum CodingKeys: String, CodingKey { case templateId = "template_id", vmName = "vm_name", namespace, customize }
}

public struct NamespaceInfo: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public let status: String?
    public var id: String { name }
}

/// `GET /instance-preferences`.
public struct InstancePreferenceInfo: Decodable, Sendable, Identifiable, Hashable {
    public let name: String
    public var id: String { name }
}

extension ZeusClient {
    public func namespaces() async throws -> [NamespaceInfo] { try await list("namespaces") }
    public func instancePreferences() async throws -> [InstancePreferenceInfo] { try await list("instance-preferences") }

    /// Runs `action` over every machine, sequentially on the server. A failure for one machine does not
    /// stop the rest; the response lists each machine's outcome.
    public func bulk(_ action: VMAction, on vms: [VM]) async throws -> BulkActionResponse {
        try await post("vms", "bulk", body: BulkBody(action: action.rawValue,
                                                      vms: vms.map { VMTargetBody(name: $0.name, namespace: $0.namespace) }))
    }

    /// Sets (and removes) labels on the given machines. Labels not named are left alone.
    public func applyLabels(set: [String: String], remove: [String] = [], on vms: [VM]) async throws {
        try await post("vms", "labels", "apply", body: ApplyLabelsBody(
            vms: vms.map { VMTargetBody(name: $0.name, namespace: $0.namespace) },
            labels: set, removeLabels: remove.isEmpty ? nil : remove))
    }

    /// Creates a machine from a KubeVirt `VirtualMachine` manifest.
    public func createVM(yaml: String) async throws {
        try await post("vms", body: CreateVMBody(yaml: yaml))
    }

    /// Creates a machine from a template that lives in a namespace. Built-in templates (empty namespace) are
    /// not addressable by this path, so they are refused here rather than guessing at an address.
    public func instantiate(_ template: VMTemplateInfo, name: String, namespace: String, diskSizeGi: Double?) async throws {
        guard let tns = template.namespace, !tns.isEmpty else {
            throw ZeusError.server(status: 0, message: "Built-in templates can't be instantiated from here.")
        }
        try await post("templates", tns, template.name, "instantiate", body: InstantiateBody(
            templateId: template.id, vmName: name, namespace: namespace,
            customize: diskSizeGi.map { InstantiateBody.Customize(diskSizeGi: $0) }))
    }
}

/// Tags on a machine are `key=value` strings (`VM.tags`).
public enum VMLabels {
    public static func parse(_ tags: [String]?) -> [(key: String, value: String)] {
        (tags ?? []).map { t in
            if let i = t.firstIndex(of: "=") { return (String(t[..<i]), String(t[t.index(after: i)...])) }
            return (t, "")
        }
    }

    /// Kubernetes label key (optionally prefixed) and value rules, simplified.
    public static func validKey(_ k: String) -> Bool {
        k.wholeMatch(of: /([a-z0-9]([-a-z0-9.]{0,251}[a-z0-9])?\/)?[A-Za-z0-9]([-A-Za-z0-9_.]{0,61}[A-Za-z0-9])?/) != nil
    }
    public static func validValue(_ v: String) -> Bool {
        v.isEmpty || v.wholeMatch(of: /[A-Za-z0-9]([-A-Za-z0-9_.]{0,61}[A-Za-z0-9])?/) != nil
    }
}

/// Builds the KubeVirt manifest for a new machine from an instance type and preference. The app shows this
/// text to the user before sending it, so what is created is what they saw.
public enum NewMachineManifest {
    public static func validName(_ s: String) -> Bool {
        s.wholeMatch(of: /[a-z0-9]([-a-z0-9.]{0,251}[a-z0-9])?/) != nil
    }

    /// Names that come from the server end up unquoted in YAML, so only plain identifier characters pass.
    static func plain(_ s: String) -> Bool { s.wholeMatch(of: /[A-Za-z0-9][-A-Za-z0-9_.]*/) != nil }

    /// A registry image such as `quay.io/containerdisks/fedora:latest`, with or without `docker://`.
    public static func validImage(_ s: String) -> Bool {
        s.wholeMatch(of: /(docker:\/\/)?[A-Za-z0-9][A-Za-z0-9._:\/@+-]*/) != nil
    }

    public static func yaml(name: String, namespace: String, instanceType: String, preference: String?,
                            diskSizeGi: Int, image: String?) -> String? {
        guard validName(name), validName(namespace), plain(instanceType), preference.map(plain) ?? true,
              (1...65536).contains(diskSizeGi), image.map(validImage) ?? true else { return nil }
        let source: String
        if let image {
            let ref = image.hasPrefix("docker://") ? image : "docker://\(image)"
            source = "registry:\n            url: \"\(ref)\""
        } else {
            source = "blank: {}"
        }
        var y = """
        apiVersion: kubevirt.io/v1
        kind: VirtualMachine
        metadata:
          name: \(name)
          namespace: \(namespace)
        spec:
          runStrategy: Halted
          instancetype:
            kind: VirtualMachineClusterInstancetype
            name: \(instanceType)

        """
        if let preference {
            y += "  preference:\n    kind: VirtualMachineClusterPreference\n    name: \(preference)\n"
        }
        y += """
          dataVolumeTemplates:
            - metadata:
                name: \(name)-rootdisk
              spec:
                source:
                  \(source)
                storage:
                  resources:
                    requests:
                      storage: \(diskSizeGi)Gi
          template:
            spec:
              domain:
                devices:
                  disks:
                    - name: rootdisk
                      disk:
                        bus: virtio
              volumes:
                - name: rootdisk
                  dataVolume:
                    name: \(name)-rootdisk

        """
        return y
    }
}
