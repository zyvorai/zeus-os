import Foundation

public struct ServerProfile: Codable, Sendable, Identifiable, Hashable {
    public let id: UUID
    public var name: String
    public var url: URL
    public var username: String
    /// Role seen at last sign-in, so a restored session can enable or disable write actions.
    public var role: String?

    public init(id: UUID = UUID(), name: String, url: URL, username: String, role: String? = nil) {
        self.id = id; self.name = name; self.url = url; self.username = username; self.role = role
    }
}

/// Profiles (non-secret) live in UserDefaults; session tokens live in the Keychain.
public struct ProfileStore: Sendable {
    private let keychain: KeychainStore
    private let defaultsKey = "zeus.profiles"
    nonisolated(unsafe) private let defaults: UserDefaults

    public init(keychain: KeychainStore = KeychainStore(), defaults: UserDefaults = .standard) {
        self.keychain = keychain; self.defaults = defaults
    }

    public func load() -> [ServerProfile] {
        guard let data = defaults.data(forKey: defaultsKey) else { return [] }
        return (try? JSONDecoder().decode([ServerProfile].self, from: data)) ?? []
    }

    private func save(_ profiles: [ServerProfile]) {
        defaults.set(try? JSONEncoder().encode(profiles), forKey: defaultsKey)
    }

    /// Adds or replaces (matching on URL + username) and returns the stored profile.
    @discardableResult
    public func upsert(_ profile: ServerProfile) -> ServerProfile {
        var all = load()
        if let i = all.firstIndex(where: { $0.url == profile.url && $0.username == profile.username }) {
            let kept = ServerProfile(id: all[i].id, name: profile.name, url: profile.url, username: profile.username, role: profile.role)
            all[i] = kept; save(all); return kept
        }
        all.append(profile); save(all); return profile
    }

    public func delete(_ profile: ServerProfile) {
        save(load().filter { $0.id != profile.id })
        try? keychain.remove(profile.id.uuidString)
    }

    public func token(for profile: ServerProfile) -> String? {
        (try? keychain.get(profile.id.uuidString)) ?? nil
    }

    public func setToken(_ token: String?, for profile: ServerProfile) throws {
        if let token { try keychain.set(token, for: profile.id.uuidString) }
        else { try keychain.remove(profile.id.uuidString) }
    }
}
