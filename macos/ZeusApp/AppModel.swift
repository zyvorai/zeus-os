import SwiftUI
import ZeusKit

@MainActor @Observable
final class AppModel {
    private let store = ProfileStore()

    var profiles: [ServerProfile] = []
    var active: ServerProfile?
    var session: LoginResponse?
    var client: ZeusClient?
    var vms: [VM] = []
    var alerts: AlertStats?
    var error: String?
    var notice: String?
    var isLoading = false

    var canWrite: Bool { session?.role == "editor" || session?.role == "admin" }

    init() { profiles = store.load() }

    /// Try the saved token for a profile; on rejection forget it so the user signs in again.
    func resume(_ profile: ServerProfile) async {
        guard let token = store.token(for: profile) else { return }
        isLoading = true; defer { isLoading = false }
        let c = ZeusClient(baseURL: profile.url, token: token)
        do {
            _ = try await c.alertStats()          // cheap authenticated probe
            client = c; active = profile
            session = LoginResponse(token: token, username: profile.username, role: profile.role ?? "viewer",
                                    tenantIds: [], expiresIn: 0)
            error = nil
            await refresh()
        } catch ZeusError.unauthorized {
            try? store.setToken(nil, for: profile)
        } catch {
            self.error = "Couldn't reach \(profile.url.host() ?? "server")."
        }
    }

    func signIn(name: String, url: URL, username: String, password: String, remember: Bool) async {
        isLoading = true; defer { isLoading = false }
        do {
            let anon = ZeusClient(baseURL: url)
            let s = try await anon.login(username: username, password: password)
            let profile = store.upsert(ServerProfile(name: name.isEmpty ? (url.host() ?? "Server") : name,
                                                     url: url, username: username, role: s.role))
            if remember {
                do { try store.setToken(s.token, for: profile) }
                catch { notice = "Signed in, but couldn't save to the Keychain." }
            }
            profiles = store.load(); active = profile
            session = s; client = anon.withToken(s.token); error = nil
            await refresh()
        } catch ZeusError.unauthorized {
            error = "Wrong username or password."
        } catch {
            self.error = "Couldn't reach \(url.host() ?? "server")."
        }
    }

    func forget(_ profile: ServerProfile) {
        store.delete(profile); profiles = store.load()
        if active == profile { signOut(forget: false) }
    }

    func signOut(forget: Bool = true) {
        if forget, let p = active { try? store.setToken(nil, for: p) }
        session = nil; client = nil; active = nil; vms = []; alerts = nil
    }

    func refresh() async {
        guard let client else { return }
        do {
            async let v = client.vms()
            async let a = client.alertStats()
            (vms, alerts) = try await (v, a)
            error = nil
        } catch ZeusError.unauthorized {
            if let p = active { try? store.setToken(nil, for: p) }
            signOut(forget: false); error = "Session expired. Sign in again."
        } catch { self.error = "Refresh failed." }
    }
}
