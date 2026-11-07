import SwiftUI
import ZeusKit

extension Destination {
    static let secureDepth: [Destination] = [
        Destination("Access", symbol: "person.badge.key", group: "Secure") { AccessView(client: $0) },
        Destination("Image Scanning", symbol: "shield.lefthalf.filled", group: "Secure") { ImageScanView(client: $0) },
        Destination("Policies", symbol: "checklist", group: "Secure") { PoliciesView(client: $0) },
        Destination("Network Policies", symbol: "network.badge.shield.half.filled", group: "Secure") { NetworkPoliciesView(client: $0) },
    ]
}
