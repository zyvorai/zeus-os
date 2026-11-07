import Foundation

/// Read-only access to the delivery, operator, catalog and platform add-on endpoints whose schemas the spec
/// leaves open. Responses stay `JSONValue`; sensitive fields (webhook URLs, secrets, CA bundles, tokens) are
/// dropped at decode time so they never reach a view.
extension JSONValue {
    /// Key fragments (lowercased) whose values are removed wherever they appear in the tree.
    static let tailSensitiveFragments = ["url", "secret", "token", "password", "cabundle", "ca_bundle", "credential", "authorization", "headers"]

    /// A copy with every object key containing a sensitive fragment removed, recursively.
    public func scrubbed() -> JSONValue {
        switch self {
        case .object(let o):
            .object(o.filter { k, _ in
                let l = k.lowercased()
                return !Self.tailSensitiveFragments.contains { l.contains($0) }
            }.mapValues { $0.scrubbed() })
        case .array(let a): .array(a.map { $0.scrubbed() })
        default: self
        }
    }

    /// The list a response carries: a bare array, or an object's `items` array. Nil for a single-record response.
    public var tailRows: [JSONValue]? {
        if let a = array { return a }
        return self["items"]?.array
    }
}

extension ZeusClient {
    /// GET any path and return the scrubbed JSON, whatever its shape (list, wrapped list or single record).
    public func tailValue(_ path: [String]) async throws -> JSONValue {
        let v: JSONValue = try await send(Self.path(path))
        return v.scrubbed()
    }
}
