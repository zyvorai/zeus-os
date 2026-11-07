import SwiftUI
import ZeusKit

extension Destination {
    static let observe: [Destination] = [
        Destination("Logs", symbol: "text.alignleft", group: "Observe") { LogsView(client: $0) },
        Destination("Events", symbol: "waveform.path.ecg", group: "Observe") { EventsView(client: $0) },
        Destination("Topology", symbol: "point.3.connected.trianglepath.dotted", group: "Observe") { TopologyView(client: $0) },
        Destination("APM", symbol: "speedometer", group: "Observe") { APMView(client: $0) },
        Destination("AI Center", symbol: "sparkles", group: "Observe") { AICenterView(client: $0) },
        Destination("Chaos", symbol: "bolt.trianglebadge.exclamationmark", group: "Observe") { ChaosView(client: $0) },
    ]
}
