import SwiftUI
import ZeusKit

extension Destination {
    static let network: [Destination] = [
        Destination("Network", symbol: "network", group: "Network") { NetworkOverviewView(client: $0) },
        Destination("Services & Ingress", symbol: "point.3.connected.trianglepath.dotted", group: "Network") { ServicesIngressView(client: $0) },
        Destination("Cilium", symbol: "hexagon", group: "Network") { CiliumView(client: $0) },
        Destination("VM Shield", symbol: "shield.lefthalf.filled", group: "Network") { ShieldView(client: $0) },
        Destination("Containments", symbol: "lock.shield", group: "Network") { ContainmentsView(client: $0) },
        Destination("DNS & IPAM", symbol: "globe", group: "Network") { DNSIPAMView(client: $0) },
    ]
}
