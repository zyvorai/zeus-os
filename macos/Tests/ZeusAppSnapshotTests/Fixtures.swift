import Foundation
import SwiftUI
import ZeusKit
@testable import ZeusApp

/// Hand-written fixture data for design review. Fictional hosts and names only: never a live server,
/// never real credentials.
@MainActor
enum Fixtures {
    static func decode<T: Decodable>(_ type: T.Type, _ json: String) -> T {
        try! JSONDecoder().decode(T.self, from: Data(json.utf8))
    }

    static let vms: [VM] = decode([VM].self, #"""
    [{"name":"api-gateway-01","namespace":"production","status":"Running","node":"node-a","age":"42d","memory_gi":8,"security_score":92},
     {"name":"billing-db","namespace":"production","status":"Running","node":"node-b","age":"118d","memory_gi":32,"security_score":71},
     {"name":"build-runner-3","namespace":"ci","status":"Stopped","node":"node-c","age":"9d","memory_gi":16,"security_score":55},
     {"name":"legacy-reports","namespace":"staging","status":"Migrating","node":"node-a","age":"301d","memory_gi":4},
     {"name":"cache-warm-02","namespace":"production","status":"Starting","node":null,"age":"2m"},
     {"name":"ml-notebook","namespace":"research","status":"ErrorUnschedulable","node":null,"age":"5h","memory_gi":64,"security_score":38},
     {"name":"vpn-edge","namespace":"production","status":"Paused","node":"node-b","age":"77d","memory_gi":2,"security_score":88}]
    """#)

    static let alertList: [FiredAlert] = decode([FiredAlert].self, #"""
    [{"id":"a1","rule_name":"High CPU","resource_name":"billing-db","namespace":"production","current_value":93.5,"threshold_value":90,"severity":"critical","fired_at":"2026-11-08T05:53:06Z","acknowledged":false,"count":3,"last_seen":"2026-11-08T06:01:00Z"},
     {"id":"a2","rule_name":"Disk nearly full","resource_name":"ml-notebook","namespace":"research","current_value":88.2,"threshold_value":85,"severity":"warning","fired_at":"2026-11-08T04:10:00Z","acknowledged":false,"count":12,"last_seen":"2026-11-08T06:01:00Z"},
     {"id":"a3","rule_name":"Backup older than 24h","resource_name":"legacy-reports","namespace":"staging","current_value":31,"threshold_value":24,"severity":"warning","fired_at":"2026-11-07T22:00:00Z","acknowledged":true,"count":1,"last_seen":"2026-11-08T06:00:00Z"},
     {"id":"a4","rule_name":"Certificate expires soon","resource_name":"api-gateway-01","namespace":"production","current_value":12,"threshold_value":14,"severity":"info","fired_at":"2026-11-06T09:00:00Z","acknowledged":false,"count":2,"last_seen":"2026-11-08T06:00:00Z"}]
    """#)

    static let alertStats = decode(AlertStats.self,
        #"{"total_active":4,"critical":1,"warning":2,"info":1,"acknowledged":1}"#)

    static let cluster = decode(ClusterMetrics.self, #"""
    {"cpu_usage_percent":62.4,"memory_usage_percent":81.3,"used_cpu_cores":19.97,"total_cpu_cores":32,
     "used_memory_bytes":104857600000,"total_memory_bytes":128849018880,"total_vms":7,"running_vms":4,"total_nodes":3,"ready_nodes":3}
    """#)

    static let nodes: [NodeMetrics] = decode([NodeMetrics].self, #"""
    [{"node_name":"node-a","cpu_usage_percent":71.2,"memory_usage_percent":64,"pod_count":38,"vm_count":3,"status":"Ready"},
     {"node_name":"node-b","cpu_usage_percent":93.4,"memory_usage_percent":88.1,"pod_count":51,"vm_count":2,"status":"Ready"},
     {"node_name":"node-c","cpu_usage_percent":12,"memory_usage_percent":30.5,"pod_count":9,"vm_count":1,"status":"NotReady"}]
    """#)

    static let profiles = [
        ServerProfile(name: "Production", url: URL(string: "https://zeus.example.test")!, username: "alice", role: "admin"),
        ServerProfile(name: "Lab", url: URL(string: "https://lab.example.test:8443")!, username: "alice", role: "viewer"),
    ]

    /// A signed-in model with fixture data and no client, so nothing can reach a network.
    static func signedInModel(role: String = "admin") -> AppModel {
        let m = AppModel()
        m.profiles = profiles
        m.active = profiles[0]
        m.session = LoginResponse(token: "fixture", username: "alice", role: role, tenantIds: [], expiresIn: 0)
        m.vms = vms; m.alerts = alertStats; m.alertList = alertList; m.cluster = cluster; m.nodes = nodes
        m.lastUpdated = .now.addingTimeInterval(-5); m.liveState = .live
        return m
    }

    static func signedOutModel(error: String? = nil) -> AppModel {
        let m = AppModel()
        m.profiles = profiles; m.error = error
        return m
    }

    static let jsonRows: [JSONValue] = decode([JSONValue].self, #"""
    [{"name":"nightly-backup","namespace":"production","status":"Succeeded","schedule":"0 2 * * *","retention":"30d","last_run":"2026-11-08T02:00:00Z"},
     {"name":"weekly-full","namespace":"production","status":"Running","schedule":"0 3 * * 0","retention":"90d","last_run":"2026-11-02T03:00:00Z"},
     {"name":"staging-daily","namespace":"staging","status":"Failed","schedule":"30 1 * * *","retention":"7d","last_run":"2026-11-08T01:30:00Z"}]
    """#)
}
