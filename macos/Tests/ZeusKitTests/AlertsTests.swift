import Testing
import Foundation
@testable import ZeusKit

private let alertJSON = #"""
[{"id":"a1","rule_id":"r1","rule_name":"High CPU","resource_name":"db-01","namespace":"prod","current_value":93.5,"threshold_value":90.0,"severity":"critical","fired_at":"2026-11-07T05:53:06.048904269+00:00","acknowledged":false,"dedup_key":"r1/db-01/prod","count":3,"last_seen":"2026-11-07T06:01:00Z"},
 {"id":"a2","rule_id":"r2","rule_name":"Disk","resource_name":"web-01","namespace":"prod","current_value":1,"threshold_value":2,"severity":"mystery","fired_at":"2026-11-07T05:00:00.5+00:00","acknowledged":true,"dedup_key":"k","count":1,"last_seen":"2026-11-07T05:00:00+00:00"}]
"""#

@Test func decodesAlertsWithNanosecondAndPlainTimestamps() throws {
    let a = try JSONDecoder().decode([FiredAlert].self, from: Data(alertJSON.utf8))
    #expect(a.count == 2)
    #expect(a[0].ruleName == "High CPU" && a[0].count == 3 && !a[0].acknowledged)
    #expect(a[0].lastSeen > a[0].firedAt)                 // "…06.048904269+00:00" and "…06:01:00Z" both parse
    #expect(a[1].acknowledged)
}

@Test func severityOrdersCriticalFirstAndKeepsUnknown() throws {
    let a = try JSONDecoder().decode([FiredAlert].self, from: Data(alertJSON.utf8))
    #expect(a[0].severityRank == 0)
    #expect(a[1].severityRank == 3)                       // unknown severity: sorted last, not dropped
}

@Test func emptyAlertListDecodes() throws {
    #expect(try JSONDecoder().decode([FiredAlert].self, from: Data("[]".utf8)).isEmpty)
}

@Test func zeusDateAcceptsAllFractionLengths() {
    for s in ["2026-11-07T05:53:06Z", "2026-11-07T05:53:06.5+00:00", "2026-11-07T05:53:06.048+00:00",
              "2026-11-07T05:53:06.048904269+00:00"] {
        #expect(ZeusDate.parse(s) != nil, "\(s)")
    }
    #expect(ZeusDate.parse("nope") == nil)
}

@Test func acknowledgeRequestIsAuthenticatedPOSTWithEncodedID() throws {
    let a = try JSONDecoder().decode([FiredAlert].self, from: Data(alertJSON.utf8))[0]
    let c = ZeusClient(baseURL: URL(string: "https://z.example")!, token: "t")
    let r = try c.request(ZeusClient.acknowledgePath(a), method: "POST")
    #expect(r.httpMethod == "POST")
    #expect(r.url?.absoluteString == "https://z.example/api/v1/alerts/a1/acknowledge")
    #expect(r.value(forHTTPHeaderField: "Authorization") == "Bearer t")
    #expect(r.httpBody == nil)
    #expect(ZeusClient.segment("a/b c") == "a%2Fb%20c")
}
