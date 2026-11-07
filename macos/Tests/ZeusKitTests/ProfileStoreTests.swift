import Testing
import Foundation
@testable import ZeusKit

private func freshStore() -> ProfileStore {
    let suite = "zeus.test.\(UUID().uuidString)"
    return ProfileStore(keychain: KeychainStore(service: suite), defaults: UserDefaults(suiteName: suite)!)
}

@Test func upsertDedupesByURLAndUser() {
    let s = freshStore()
    let url = URL(string: "https://a.example")!
    let first = s.upsert(ServerProfile(name: "A", url: url, username: "bob"))
    let second = s.upsert(ServerProfile(name: "Renamed", url: url, username: "bob"))
    #expect(first.id == second.id)
    #expect(s.load().count == 1)
    #expect(s.load()[0].name == "Renamed")
}

@Test func deleteRemovesProfile() {
    let s = freshStore()
    let p = s.upsert(ServerProfile(name: "A", url: URL(string: "https://a.example")!, username: "u"))
    s.delete(p)
    #expect(s.load().isEmpty)
}
