import SwiftUI
import ZeusKit

extension Destination {
    static let consoles: [Destination] = [
        Destination("Pod Terminal", symbol: "terminal", group: "Consoles") { PodTerminalView(client: $0) },
        Destination("Console Access", symbol: "person.badge.key", group: "Consoles") { ConsoleAccessView(client: $0) },
    ]
}
