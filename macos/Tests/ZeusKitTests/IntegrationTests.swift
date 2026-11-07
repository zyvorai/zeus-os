import Testing
import Foundation
@testable import ZeusKit

private func alert(_ id: String, _ sev: String, acked: Bool = false) throws -> FiredAlert {
    let j = #"{"id":"\#(id)","rule_name":"r","resource_name":"vm","namespace":"n","current_value":1,"threshold_value":0,"severity":"\#(sev)","fired_at":"2026-11-07T05:00:00Z","acknowledged":\#(acked),"count":1,"last_seen":"2026-11-07T05:00:00Z"}"#
    return try JSONDecoder().decode(FiredAlert.self, from: Data(j.utf8))
}

@Test func firstLoadNeverNotifies() throws {
    var f = AlertNotificationFilter()
    #expect(f.newAlerts(in: [try alert("a", "critical")]).isEmpty)
    #expect(f.newAlerts(in: [try alert("a", "critical")]).isEmpty)
}

@Test func notifiesOnceForNewCriticalAndWarningOnly() throws {
    var f = AlertNotificationFilter()
    _ = f.newAlerts(in: [try alert("a", "critical")])
    let list = [try alert("a", "critical"), try alert("b", "warning"), try alert("c", "info"),
                try alert("d", "critical", acked: true), try alert("e", "critical")]
    #expect(f.newAlerts(in: list).map(\.id) == ["e", "b"])   // critical first
    #expect(f.newAlerts(in: list).isEmpty)                   // deduped by id
}

@Test func resetReprimes() throws {
    var f = AlertNotificationFilter()
    _ = f.newAlerts(in: [])
    f.reset()
    #expect(f.newAlerts(in: [try alert("a", "critical")]).isEmpty)
}

@Test func pinMatchingIsNormalisedAndStrict() {
    let der = Data("cert-bytes".utf8)
    let fp = CertificatePin.fingerprint(of: der)
    #expect(fp.count == 64)
    #expect(CertificatePin.matches(pin: fp, leafDER: der))
    let colon = stride(from: 0, to: 64, by: 2).map { i -> String in
        let a = fp.index(fp.startIndex, offsetBy: i); return String(fp[a..<fp.index(a, offsetBy: 2)]).uppercased()
    }.joined(separator: ":")
    #expect(CertificatePin.matches(pin: colon, leafDER: der))
    #expect(!CertificatePin.matches(pin: fp, leafDER: Data("other".utf8)))
    #expect(!CertificatePin.matches(pin: nil, leafDER: der))
    #expect(!CertificatePin.matches(pin: "", leafDER: der))
    #expect(CertificateInfo(sha256: "abcd", subject: "s").displayFingerprint == "AB:CD")
}

@Test func pinnedFingerprintPersistsAndSurvivesUpsert() {
    let suite = "zeus.test.\(UUID().uuidString)"
    let s = ProfileStore(keychain: KeychainStore(service: suite), defaults: UserDefaults(suiteName: suite)!)
    let url = URL(string: "https://a.example")!
    s.upsert(ServerProfile(name: "A", url: url, username: "u"))
    s.upsert(ServerProfile(name: "A", url: url, username: "u", pinnedFingerprint: "ab"))
    #expect(s.load().count == 1 && s.load()[0].pinnedFingerprint == "ab")
}

@Test func oldProfilesWithoutPinStillDecode() throws {
    let j = #"[{"id":"\#(UUID().uuidString)","name":"A","url":"https://a.example","username":"u"}]"#
    #expect(try JSONDecoder().decode([ServerProfile].self, from: Data(j.utf8))[0].pinnedFingerprint == nil)
}
