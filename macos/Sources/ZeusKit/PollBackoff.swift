import Foundation

/// Pure scheduling policy for the live-update loop: poll fast while the app is in front,
/// slowly in the background, and back off exponentially (capped) while the server is failing.
public struct PollBackoff: Sendable, Equatable {
    public let active: Duration
    public let idle: Duration
    public let ceiling: Duration
    public private(set) var failures = 0

    public init(active: Duration = .seconds(5), idle: Duration = .seconds(30), ceiling: Duration = .seconds(120)) {
        self.active = active; self.idle = idle; self.ceiling = ceiling
    }

    public mutating func succeeded() { failures = 0 }
    public mutating func failed() { failures = min(failures + 1, 10) }

    public func delay(appIsActive: Bool) -> Duration {
        let base = appIsActive ? active : idle
        return min(base * (1 << failures), max(ceiling, base))
    }
}
