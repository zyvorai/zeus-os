import Testing
@testable import ZeusKit

@Test func pollsFastWhenActiveSlowWhenIdle() {
    let b = PollBackoff()
    #expect(b.delay(appIsActive: true) == .seconds(5))
    #expect(b.delay(appIsActive: false) == .seconds(30))
}

@Test func backsOffExponentiallyThenCaps() {
    var b = PollBackoff()
    var seen: [Duration] = []
    for _ in 0..<6 { b.failed(); seen.append(b.delay(appIsActive: true)) }
    #expect(seen == [.seconds(10), .seconds(20), .seconds(40), .seconds(80), .seconds(120), .seconds(120)])
}

@Test func successResetsBackoff() {
    var b = PollBackoff()
    b.failed(); b.failed()
    b.succeeded()
    #expect(b.delay(appIsActive: true) == .seconds(5))
}

@Test func idleNeverExceedsItsOwnFloorEvenWithLowCeiling() {
    var b = PollBackoff(active: .seconds(5), idle: .seconds(30), ceiling: .seconds(10))
    b.failed()
    #expect(b.delay(appIsActive: false) == .seconds(30))     // ceiling can't push below the base
}
