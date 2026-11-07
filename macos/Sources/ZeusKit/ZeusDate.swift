import Foundation

enum ZeusDate {
    /// Server timestamps are RFC 3339 with 0 to 9 fractional digits ("…06.048904269+00:00").
    /// Foundation's parser is strict about fraction length, so trim to milliseconds first.
    static func parse(_ s: String) -> Date? {
        let trimmed = s.replacing(/\.(\d{3})\d+/) { ".\($0.1)" }
        if let d = try? Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse(trimmed) { return d }
        return try? Date.ISO8601FormatStyle().parse(trimmed)
    }
}
