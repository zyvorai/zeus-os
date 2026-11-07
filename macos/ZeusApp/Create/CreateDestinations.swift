import SwiftUI
import ZeusKit

extension Destination {
    static let create: [Destination] = [
        Destination("Migrations", symbol: "arrow.left.arrow.right", group: "Run") { MigrationsView(client: $0) },
        Destination("Templates", symbol: "doc.on.doc", group: "Run") { TemplatesView(client: $0) },
        Destination("VM Groups", symbol: "square.stack.3d.up", group: "Run") { VMGroupsView(client: $0) },
    ]
}
