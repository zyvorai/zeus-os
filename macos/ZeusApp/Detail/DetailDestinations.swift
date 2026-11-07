import SwiftUI
import ZeusKit

extension Destination {
    static let detail: [Destination] = [
        Destination("Host Detail", symbol: "cpu.fill", group: "Platform") { HostDetailView(client: $0) },
        Destination("Workflow Runs", symbol: "play.circle", group: "Automation") { WorkflowRunsView(client: $0) },
        Destination("SLO Budgets", symbol: "target", group: "Respond") { SLOBudgetsView(client: $0) },
        Destination("RBAC", symbol: "person.badge.key", group: "Identity") { RBACView(client: $0) },
        Destination("Policies & Scans", symbol: "checklist", group: "Secure") {
            RowListsView(title: "Policies & Scans", client: $0, lists: [
                RowList(id: "scan-policies", label: "Image scan policies", path: ["image-scanning", "policies"]),
                RowList(id: "scan-registries", label: "Image scan registries", path: ["image-scanning", "registries"]),
                RowList(id: "scan-exceptions", label: "Image scan exceptions", path: ["image-scanning", "exceptions"]),
                RowList(id: "compliance-policies", label: "Compliance policies", path: ["compliance", "policies"]),
                RowList(id: "compliance-reports", label: "Compliance reports", path: ["compliance", "reports"]),
                RowList(id: "gatekeeper-violations", label: "Gatekeeper violations", path: ["opa-gatekeeper", "violations"]),
            ])
        },
        Destination("Mesh & Services", symbol: "point.3.connected.trianglepath.dotted", group: "Network") {
            RowListsView(title: "Mesh & Services", client: $0, lists: [
                RowList(id: "mesh-vs", label: "Virtual services", path: ["mesh", "virtualservices"]),
                RowList(id: "mesh-gw", label: "Gateways", path: ["mesh", "gateways"]),
                RowList(id: "mesh-dr", label: "Destination rules", path: ["mesh", "destinationrules"]),
                RowList(id: "mesh-se", label: "Service entries", path: ["mesh", "serviceentries"]),
                RowList(id: "registry", label: "Service registry", path: ["service-registry", "services"]),
                RowList(id: "svc-deps", label: "Service dependencies", path: ["service-dependencies", "services"]),
            ])
        },
        Destination("Traces", symbol: "waveform.path.ecg", group: "Observe") {
            RowListsView(title: "Traces", client: $0, lists: [
                RowList(id: "traces", label: "Traces", path: ["observability", "traces"]),
                RowList(id: "spans", label: "Spans", path: ["observability", "spans"]),
                RowList(id: "obs-services", label: "Traced services", path: ["observability", "services"]),
                RowList(id: "exporters", label: "Exporters", path: ["observability", "exporters"]),
                RowList(id: "samplers", label: "Samplers", path: ["observability", "samplers"]),
            ])
        },
    ]
}
