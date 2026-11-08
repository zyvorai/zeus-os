import Testing
import Foundation
@testable import ZeusKit

@Suite(.serialized) struct ContainmentTests {
    @Test func createBodyAndPath() throws {
        let c = ZeusClient(baseURL: URL(string: "https://zeus.test")!)
        let r = ContainmentRequest(targetID: "vm:default/web-01", profile: .internetLock, reason: "ir-7",
                                   durationSeconds: 600, connectionBehavior: .blockNew, preserve: ["10.0.0.1"])
        let req = try c.request("/api/v1/containments", method: "POST", body: r)
        let obj = try JSONSerialization.jsonObject(with: req.httpBody!) as! [String: Any]
        #expect((obj["target"] as? [String: String])?["id"] == "vm:default/web-01")
        #expect(obj["profile"] as? String == "internet-lock")
        #expect(obj["duration_seconds"] as? Int == 600 && obj["connection_behavior"] as? String == "block-new")
        #expect(obj["preserve"] as? [String] == ["10.0.0.1"])
    }

    @Test func validation() {
        #expect(ContainmentRequest(targetID: " ", profile: .fullIsolation).problem() != nil)
        #expect(ContainmentRequest(targetID: "vm:a/b", profile: .custom).problem() != nil)
        #expect(ContainmentRequest(targetID: "vm:a/b", profile: .custom, customMode: "x").problem() == nil)
        #expect(ContainmentRequest(targetID: "vm:a/b", profile: .lateralLock, durationSeconds: 0).problem() != nil)
        #expect(ContainmentRequest(targetID: "vm:a/b", profile: .lateralLock).problem() == nil)
    }

    @Test func decodesRecord() throws {
        let json = #"{"id":"c1","workload_id":"vm:default/web-01","profile":"internet-lock","backend":"cilium","desired_state":"active","actual_state":"released","events":[{"at":"t","kind":"applied","detail":"ok"}]}"#
        let c = try JSONDecoder().decode(Containment.self, from: Data(json.utf8))
        #expect(c.id == "c1" && c.events?.count == 1 && !c.isLive)
    }

    @Test func idsAreEncoded() throws {
        #expect(ZeusClient.path(["containments", "a/b", "release"]) == "containments/a%2Fb/release")
    }
}
