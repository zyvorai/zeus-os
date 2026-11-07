import SwiftUI
import ZeusKit

/// Sidebar order is the order of this list; groups appear in order of first use.
/// To add an area: create `static let yours: [Destination]` in your own file and add it here.
extension Destination {
    static let all: [Destination] = core + protect + cost + secure + storage + respond + secureDepth + capacityDepth + automation

    static let core: [Destination] = [
        Destination("Overview", symbol: "gauge.with.dots.needle.50percent", group: "Run") { _ in AnyView(OverviewView()) },
        Destination("Machines", symbol: "server.rack", group: "Run") { _ in AnyView(MachinesView()) },
        Destination("Alerts", symbol: "bell", group: "Observe") { _ in AnyView(AlertsView()) },
    ]

    static let protect: [Destination] = [
        Destination("Snapshots", symbol: "camera.on.rectangle", group: "Protect") { SnapshotsView(client: $0) },
        Destination("Backups", symbol: "externaldrive.badge.timemachine", group: "Protect") { BackupsView(client: $0) },
    ]

    static let cost: [Destination] = [
        Destination("Cost", symbol: "dollarsign.circle", group: "Cost") { CostView(client: $0) },
    ]

    static let secure: [Destination] = [
        Destination("Audit", symbol: "list.bullet.clipboard", group: "Secure") { AuditView(client: $0) },
        Destination("Compliance", symbol: "checkmark.shield", group: "Secure") { ComplianceView(client: $0) },
    ]

    static let storage: [Destination] = [
        Destination("Storage", symbol: "externaldrive", group: "Storage") { StorageView(client: $0) },
        Destination("DR Plans", symbol: "arrow.triangle.2.circlepath", group: "Storage") { DRPlansView(client: $0) },
        Destination("Velero", symbol: "shippingbox", group: "Storage") { VeleroView(client: $0) },
        Destination("Disks & Images", symbol: "opticaldisc", group: "Storage") { DisksAndImagesView(client: $0) },
    ]
}
