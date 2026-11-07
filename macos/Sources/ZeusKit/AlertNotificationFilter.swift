import Foundation

/// Decides which polled alerts deserve a banner. The first list seen only primes the filter, so alerts that
/// were already firing when the app connected never notify. Afterwards an alert notifies once, by id, and only
/// if it is unacknowledged and critical or warning.
public struct AlertNotificationFilter: Sendable {
    private var seen: Set<String> = []
    private var primed = false

    public init() {}

    public mutating func reset() { seen = []; primed = false }

    public mutating func newAlerts(in list: [FiredAlert]) -> [FiredAlert] {
        defer { seen.formUnion(list.map(\.id)); primed = true }
        guard primed else { return [] }
        return list.filter { a in
            !seen.contains(a.id) && !a.acknowledged && ["critical", "warning"].contains(a.severity.lowercased())
        }.sorted { $0.severityRank < $1.severityRank }
    }
}
