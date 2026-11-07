import SwiftUI
import ZeusKit

extension Destination {
    static let tailSched: [Destination] = [
        Destination("Placement", symbol: "square.grid.3x3.topleft.filled", group: "Scheduling") { SchedScreen(client: $0, feeds: SchedFeed.placement) },
        Destination("Classes & Budgets", symbol: "list.number", group: "Scheduling") { SchedScreen(client: $0, feeds: SchedFeed.classesAndBudgets) },
        Destination("Quotas & Governance", symbol: "gauge.with.dots.needle.33percent", group: "Scheduling") { SchedScreen(client: $0, feeds: SchedFeed.quotasAndGovernance) },
        Destination("Autoscaling", symbol: "arrow.up.and.down.circle", group: "Scheduling") { SchedScreen(client: $0, feeds: SchedFeed.autoscaling) },
        Destination("Devices & Hosts", symbol: "cpu", group: "Scheduling") { SchedScreen(client: $0, feeds: SchedFeed.devicesAndHosts) },
    ]
}
