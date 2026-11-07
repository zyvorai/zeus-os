import Foundation

/// One sample from `/metrics/vms/{ns}/{name}/history`. Every measurement is optional:
/// the server sends `null` while rates are still warming up or a VM is stopped.
public struct MetricPoint: Decodable, Sendable, Identifiable, Hashable {
    public var id: Date { timestamp }
    public let timestamp: Date
    public let cpuUsagePercent: Double?
    public let memoryUsagePercent: Double?
    public let memoryUsageBytes: Double?
    public let networkRxBytesPerSec: Double?
    public let networkTxBytesPerSec: Double?
    public let diskReadBytesPerSec: Double?
    public let diskWriteBytesPerSec: Double?

    enum CodingKeys: String, CodingKey {
        case timestamp
        case cpuUsagePercent = "cpu_usage_percent"
        case memoryUsagePercent = "memory_usage_percent"
        case memoryUsageBytes = "memory_usage_bytes"
        case networkRxBytesPerSec = "network_rx_bytes_per_sec"
        case networkTxBytesPerSec = "network_tx_bytes_per_sec"
        case diskReadBytesPerSec = "disk_read_bytes_per_sec"
        case diskWriteBytesPerSec = "disk_write_bytes_per_sec"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let raw = try c.decode(String.self, forKey: .timestamp)
        guard let date = ZeusDate.parse(raw) else {
            throw DecodingError.dataCorruptedError(forKey: .timestamp, in: c,
                                                   debugDescription: "Unrecognised timestamp \(raw)")
        }
        timestamp = date
        cpuUsagePercent = try c.decodeIfPresent(Double.self, forKey: .cpuUsagePercent)
        memoryUsagePercent = try c.decodeIfPresent(Double.self, forKey: .memoryUsagePercent)
        memoryUsageBytes = try c.decodeIfPresent(Double.self, forKey: .memoryUsageBytes)
        networkRxBytesPerSec = try c.decodeIfPresent(Double.self, forKey: .networkRxBytesPerSec)
        networkTxBytesPerSec = try c.decodeIfPresent(Double.self, forKey: .networkTxBytesPerSec)
        diskReadBytesPerSec = try c.decodeIfPresent(Double.self, forKey: .diskReadBytesPerSec)
        diskWriteBytesPerSec = try c.decodeIfPresent(Double.self, forKey: .diskWriteBytesPerSec)
    }
}

public struct VMMetricsHistory: Decodable, Sendable {
    public let dataPoints: [MetricPoint]
    enum CodingKeys: String, CodingKey { case dataPoints = "data_points" }
}

/// `/metrics/cluster`: measured usage (not resource requests, which `/cluster/metrics` reports).
public struct ClusterMetrics: Codable, Sendable {
    public let cpuUsagePercent: Double
    public let memoryUsagePercent: Double
    public let usedCpuCores: Double
    public let totalCpuCores: Double
    public let usedMemoryBytes: Double
    public let totalMemoryBytes: Double
    public let totalVms: Int
    public let runningVms: Int
    public let totalNodes: Int
    public let readyNodes: Int

    enum CodingKeys: String, CodingKey {
        case cpuUsagePercent = "cpu_usage_percent"
        case memoryUsagePercent = "memory_usage_percent"
        case usedCpuCores = "used_cpu_cores"
        case totalCpuCores = "total_cpu_cores"
        case usedMemoryBytes = "used_memory_bytes"
        case totalMemoryBytes = "total_memory_bytes"
        case totalVms = "total_vms"
        case runningVms = "running_vms"
        case totalNodes = "total_nodes"
        case readyNodes = "ready_nodes"
    }
}

public struct NodeMetrics: Codable, Sendable, Identifiable, Hashable {
    public var id: String { nodeName }
    public let nodeName: String
    public let cpuUsagePercent: Double?
    public let memoryUsagePercent: Double?
    public let podCount: Int?
    public let vmCount: Int?
    public let status: String?

    enum CodingKeys: String, CodingKey {
        case nodeName = "node_name"
        case cpuUsagePercent = "cpu_usage_percent"
        case memoryUsagePercent = "memory_usage_percent"
        case podCount = "pod_count"
        case vmCount = "vm_count"
        case status
    }
}

public enum MetricsRange: String, CaseIterable, Sendable, Identifiable {
    case quarterHour = "15m", hour = "1h", sixHours = "6h"
    public var id: String { rawValue }
    public var minutes: Int { switch self { case .quarterHour: 15; case .hour: 60; case .sixHours: 360 } }
    /// Aim for ~90 points so charts stay light, never finer than the 15s scrape.
    public var intervalSeconds: Int { max(15, minutes * 60 / 90) }
}
