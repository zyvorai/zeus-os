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

private func vm(_ ns: String, _ name: String, _ status: String = "Running") -> VM {
    try! JSONDecoder().decode(VM.self, from: Data(#"{"name":"\#(name)","namespace":"\#(ns)","status":"\#(status)"}"#.utf8))
}

@Test func actionPathEncodesSegments() {
    #expect(ZeusClient.actionPath(.stop, vm("demo-vms", "db-01")) == "vms/demo-vms/db-01/stop")
    #expect(ZeusClient.actionPath(.start, vm("a/b", "c d")) == "vms/a%2Fb/c%20d/start")
}

@Test func actionBuildsAuthenticatedPOST() throws {
    let c = ZeusClient(baseURL: URL(string: "https://z.example")!, token: "t")
    let r = try c.request(ZeusClient.actionPath(.restart, vm("ns", "n")), method: "POST")
    #expect(r.httpMethod == "POST")
    #expect(r.url?.absoluteString == "https://z.example/api/v1/vms/ns/n/restart")
    #expect(r.value(forHTTPHeaderField: "Authorization") == "Bearer t")
}

@Test func actionAvailability() {
    #expect(VMAction.start.isAvailable(for: "Stopped"))
    #expect(!VMAction.start.isAvailable(for: "Running"))
    #expect(VMAction.stop.isAvailable(for: "Running"))
    #expect(!VMAction.stop.isAvailable(for: "Starting"))
}

@Test func needsAttentionExcludesAcknowledged() throws {
    let json = #"{"total_active":5,"critical":1,"warning":4,"info":0,"acknowledged":2}"#
    let s = try JSONDecoder().decode(AlertStats.self, from: Data(json.utf8))
    #expect(s.needsAttention == 3)
    let odd = #"{"total_active":1,"critical":0,"warning":1,"info":0,"acknowledged":3}"#
    #expect(try JSONDecoder().decode(AlertStats.self, from: Data(odd.utf8)).needsAttention == 0)
}
