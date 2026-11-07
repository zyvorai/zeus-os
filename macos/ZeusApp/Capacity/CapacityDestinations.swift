import SwiftUI
import ZeusKit

extension Destination {
    static let capacityDepth: [Destination] = [
        Destination("Capacity", symbol: "chart.line.uptrend.xyaxis", group: "Observe") { CapacityView(client: $0) },
        Destination("Optimization", symbol: "lightbulb", group: "Cost") { OptimizationView(client: $0) },
        Destination("FinOps", symbol: "banknote", group: "Cost") { FinOpsView(client: $0) },
    ]
}
