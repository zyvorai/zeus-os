import SwiftUI
import ZeusKit

extension Destination {
    static let respond: [Destination] = [
        Destination("Alert Rules", symbol: "bell.badge", group: "Respond") { RulesView(client: $0) },
        Destination("Channels", symbol: "paperplane", group: "Respond") { ChannelsView(client: $0) },
        Destination("Notifications", symbol: "tray", group: "Respond") { NotificationHistoryView(client: $0) },
        Destination("SLOs", symbol: "target", group: "Respond") { SLOView(client: $0) },
        Destination("Incidents", symbol: "exclamationmark.triangle", group: "Respond") { IncidentsView(client: $0) },
        Destination("Tenancy", symbol: "building.2", group: "Respond") { TenancyView(client: $0) },
    ]
}
