import Foundation
import Security

/// Minimal generic-password Keychain wrapper. Errors are surfaced, never swallowed,
/// so callers can decide whether to degrade to "not remembered".
public struct KeychainStore: Sendable {
    public enum Failure: Error, Equatable { case status(OSStatus) }

    public let service: String
    public init(service: String = "dev.zyvor.zeus") { self.service = service }

    private func query(_ account: String) -> [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service,
         kSecAttrAccount as String: account]
    }

    public func set(_ value: String, for account: String) throws {
        let data = Data(value.utf8)
        var status = SecItemUpdate(query(account) as CFDictionary,
                                   [kSecValueData as String: data] as CFDictionary)
        if status == errSecItemNotFound {
            var add = query(account)
            add[kSecValueData as String] = data
            add[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            status = SecItemAdd(add as CFDictionary, nil)
        }
        guard status == errSecSuccess else { throw Failure.status(status) }
    }

    public func get(_ account: String) throws -> String? {
        var q = query(account)
        q[kSecReturnData as String] = true
        q[kSecMatchLimit as String] = kSecMatchLimitOne
        var out: CFTypeRef?
        let status = SecItemCopyMatching(q as CFDictionary, &out)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = out as? Data else { throw Failure.status(status) }
        return String(data: data, encoding: .utf8)
    }

    public func remove(_ account: String) throws {
        let status = SecItemDelete(query(account) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw Failure.status(status) }
    }
}
