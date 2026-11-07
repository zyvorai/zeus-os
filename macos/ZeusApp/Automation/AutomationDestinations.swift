import SwiftUI
import ZeusKit

extension Destination {
    static let automation: [Destination] = [
        Destination("Tasks", symbol: "checklist", group: "Automate") { TasksView(client: $0) },
        Destination("Workflows", symbol: "point.3.connected.trianglepath.dotted", group: "Automate") { WorkflowsView(client: $0) },
        Destination("Helm", symbol: "helm", group: "Deliver") { HelmView(client: $0) },
        Destination("GitOps", symbol: "arrow.triangle.branch", group: "Deliver") { GitOpsView(client: $0) },
        Destination("Delivery", symbol: "shippingbox", group: "Deliver") { DeliveryView(client: $0) },
    ]
}
