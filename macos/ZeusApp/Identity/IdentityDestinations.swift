import SwiftUI
import ZeusKit

extension Destination {
    static let identity: [Destination] = [
        Destination("Users & Sessions", symbol: "person.2", group: "Identity") { UsersView(client: $0) },
        Destination("API Tokens", symbol: "key", group: "Identity") { APITokensView(client: $0) },
        Destination("Fleet", symbol: "square.stack.3d.up", group: "Platform") { FleetView(client: $0) },
        Destination("Nodes & Hosts", symbol: "cpu", group: "Platform") { NodesView(client: $0) },
        Destination("Platform", symbol: "gearshape.2", group: "Platform") { PlatformView(client: $0) },
    ]
}
