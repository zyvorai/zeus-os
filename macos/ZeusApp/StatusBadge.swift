import SwiftUI

/// A status word with an icon and a tint, so state never relies on color alone. Server status strings are
/// free-form ("Running", "ErrorUnschedulable", "Succeeded"), so this classifies by keyword and falls back
/// to a neutral icon rather than guessing.
struct StatusBadge: View {
    let status: String

    enum Kind { case good, busy, warning, bad, off, unknown }

    static func kind(of status: String) -> Kind {
        let s = status.lowercased()
        if s.contains("inactive") { return .off }
        if ["error", "fail", "crash", "unschedulable", "notready", "unhealthy", "lost"].contains(where: s.contains) { return .bad }
        if ["running", "ready", "succeed", "complete", "healthy", "active", "bound", "available"].contains(where: s.contains) { return .good }
        if ["start", "migrat", "provision", "stopping", "pending", "creating", "terminating", "restart", "wait"].contains(where: s.contains) { return .busy }
        if ["pause", "suspend", "degraded", "warn"].contains(where: s.contains) { return .warning }
        if ["stop", "halt", "off", "inactive"].contains(where: s.contains) { return .off }
        return .unknown
    }

    private var symbol: String {
        switch Self.kind(of: status) {
        case .good: "checkmark.circle.fill"
        case .busy: "clock.fill"
        case .warning: "pause.circle.fill"
        case .bad: "exclamationmark.octagon.fill"
        case .off: "stop.circle.fill"
        case .unknown: "questionmark.circle"
        }
    }

    private var tint: Color {
        switch Self.kind(of: status) {
        case .good: .green
        case .busy: .blue
        case .warning: .orange
        case .bad: .red
        case .off, .unknown: .secondary
        }
    }

    var body: some View {
        // Icon carries the tint; the text stays in primary ink so it keeps full contrast in both appearances.
        Label {
            Text(status)
        } icon: {
            Image(systemName: symbol).foregroundStyle(tint).frame(width: 16)
        }
        .lineLimit(1)
    }
}
