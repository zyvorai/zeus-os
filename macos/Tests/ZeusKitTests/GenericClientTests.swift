import Testing
import Foundation
@testable import ZeusKit

@Test func jsonValueRoundTripsAndNavigates() throws {
    let json = #"{"a":[1,"x",null,true],"b":{"c":2.5}}"#
    let v = try JSONDecoder().decode(JSONValue.self, from: Data(json.utf8))
    #expect(v["a"]?[0]?.number == 1)
    #expect(v["a"]?[1]?.string == "x")
    #expect(v["a"]?[2] == .null)
    #expect(v["a"]?[3]?.bool == true)
    #expect(v["b"]?["c"]?.number == 2.5)
    #expect(v["a"]?[0]?.string == "1")            // whole numbers print without ".0"
    let again = try JSONDecoder().decode(JSONValue.self, from: JSONEncoder().encode(v))
    #expect(again == v)
}

@Test func listingAcceptsArrayOrItemsObject() throws {
    let a = try JSONDecoder().decode(Listing<String>.self, from: Data(#"["x","y"]"#.utf8))
    let b = try JSONDecoder().decode(Listing<String>.self, from: Data(#"{"items":["x","y"],"total":2}"#.utf8))
    #expect(a.items == ["x", "y"] && b.items == a.items)
}

@Test func genericPathEncodesEachSegment() {
    #expect(ZeusClient.path(["vms", "a/b", "c d", "disks"]) == "vms/a%2Fb/c%20d/disks")
}

@Test func requestEncodesAnyEncodableBodyAsJSON() throws {
    struct Body: Encodable { let replicas: Int }
    let c = ZeusClient(baseURL: URL(string: "https://zeus.test/base")!, token: "t")
    let r = try c.request("vms/x", method: "PUT", body: Body(replicas: 2))
    #expect(r.httpMethod == "PUT")
    #expect(r.url?.absoluteString == "https://zeus.test/base/api/v1/vms/x")
    #expect(r.value(forHTTPHeaderField: "Content-Type") == "application/json")
    #expect(String(data: r.httpBody ?? Data(), encoding: .utf8) == #"{"replicas":2}"#)
}
