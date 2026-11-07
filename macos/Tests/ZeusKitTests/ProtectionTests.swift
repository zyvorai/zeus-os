import Testing
import Foundation
@testable import ZeusKit

@Test func decodesSnapshotListWithNullError() throws {
    let json = #"[{"name":"demo-snap","namespace":"default","vm_name":"demo","age":"4d 3h","ready":true,"consistency_type":"crash_consistent","phase":"Succeeded","error":null}]"#
    let s = try JSONDecoder().decode(Listing<VMSnapshot>.self, from: Data(json.utf8)).items
    #expect(s[0].id == "default/demo-snap" && s[0].ready == true && s[0].error == nil)
}

@Test func decodesBackupOverviewWithEmptyPhase() throws {
    let json = #"{"schedules":[{"name":"daily","schedule":"0 2 * * *","included_namespaces":["a","b"],"ttl":"720h","last_backup":null,"phase":""}],"recent_backups":[],"velero_installed":true}"#
    let o = try JSONDecoder().decode(BackupOverview.self, from: Data(json.utf8))
    #expect(o.schedules[0].includedNamespaces == ["a", "b"] && o.veleroInstalled && o.recentBackups.isEmpty)
}

@Test func backupOverviewToleratesMissingKeys() throws {
    let o = try JSONDecoder().decode(BackupOverview.self, from: Data("{}".utf8))
    #expect(o.schedules.isEmpty && !o.veleroInstalled)
}

@Test func createSnapshotBodyUsesServerKeys() throws {
    let data = try JSONEncoder().encode(CreateSnapshotBody(vmName: "demo", quiesce: true))
    let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    #expect(obj?["vm_name"] as? String == "demo" && obj?["quiesce"] as? Bool == true)
}
