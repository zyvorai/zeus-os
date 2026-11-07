import Testing
import Foundation
@testable import ZeusKit

@Test func decodesAuditEventsFromLiveShape() throws {
    let json = #"[{"id":"default/p.1","timestamp":"2026-11-07T13:15:22+00:00","user":"kubelet","action":"Pulled","resource_type":"Pod","resource_name":"p","namespace":"default","details":"x","result":"Normal","count":4739},{"id":"b","timestamp":"2026-11-07T13:14:19.123456789+00:00","action":"Unhealthy","result":"Warning"}]"#
    let e = try JSONDecoder().decode(Listing<AuditEvent>.self, from: Data(json.utf8)).items
    #expect(e[0].count == 4739 && !e[0].isWarning && e[0].date != nil)
    #expect(e[1].isWarning && e[1].user == nil && e[1].date != nil)
}

@Test func decodesComplianceFrameworksAndStats() throws {
    let f = #"[{"name":"pci-dss","framework_type":"PCI-DSS","version":"3.2.1","total_controls":15,"passed_controls":6,"failed_controls":9,"compliance_score":40.0,"last_scan":"2026-11-07T13:18:33.9014804+00:00"}]"#
    let r = try JSONDecoder().decode(Listing<ComplianceFramework>.self, from: Data(f.utf8)).items
    #expect(r[0].failedControls == 9 && r[0].complianceScore == 40)
    let s = try JSONDecoder().decode(AuditStats.self, from: Data(#"{"total_events":3,"by_type":{},"last_24h":3,"last_7d":3}"#.utf8))
    #expect(s.last24h == 3)
}
