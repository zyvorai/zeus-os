import SwiftUI
import ZeusKit

@MainActor @Observable
final class AppModel {
    var serverURL = URL(string: "https://zeus.zyvor.dev")!
    var session: LoginResponse?
    var client: ZeusClient?
    var vms: [VM] = []
    var alerts: AlertStats?
    var error: String?
    var isLoading = false

    var canWrite: Bool { session?.role == "editor" || session?.role == "admin" }

    func signIn(url: URL, username: String, password: String) async {
        isLoading = true; defer { isLoading = false }
        do {
            let anon = ZeusClient(baseURL: url)
            let s = try await anon.login(username: username, password: password)
            serverURL = url; session = s; client = anon.withToken(s.token); error = nil
            await refresh()
        } catch ZeusError.unauthorized {
            error = "Wrong username or password."
        } catch {
            self.error = "Couldn't reach \(url.host() ?? "server")."
        }
    }

    func signOut() { session = nil; client = nil; vms = []; alerts = nil }

    func refresh() async {
        guard let client else { return }
        do {
            async let v = client.vms()
            async let a = client.alertStats()
            (vms, alerts) = try await (v, a)
            error = nil
        } catch { self.error = "Refresh failed." }
    }
}
