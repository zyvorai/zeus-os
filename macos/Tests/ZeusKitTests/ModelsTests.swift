import Testing
import Foundation
@testable import ZeusKit

@Test func decodesVMPageWithNulls() throws {
    let json = #"{"items":[{"name":"batch-01","namespace":"demo-vms","status":"Stopped","node":null,"age":"12d 14h","tags":["app=batch"],"ip_address":null,"disk_count":1,"memory_gi":0.125,"security_score":50}]}"#
    let page = try JSONDecoder().decode(Page<VM>.self, from: Data(json.utf8))
    #expect(page.items[0].id == "demo-vms/batch-01")
    #expect(page.items[0].node == nil)
    #expect(page.items[0].memoryGi == 0.125)
}

@Test func decodesAlertStats() throws {
    let json = #"{"total_active":0,"critical":0,"warning":0,"info":0,"acknowledged":0,"by_namespace":{}}"#
    let s = try JSONDecoder().decode(AlertStats.self, from: Data(json.utf8))
    #expect(s.totalActive == 0)
}
