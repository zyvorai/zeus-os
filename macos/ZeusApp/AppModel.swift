import SwiftUI
import AppKit
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
    /// nil means "couldn't load", which is different from an empty list.
    var alertList: [FiredAlert]?
    var cluster: ClusterMetrics?
    var nodes: [NodeMetrics] = []
    var error: String?
    var notice: String?
    var isLoading = false
    var busy: Set<VM.ID> = []
    var busyAlerts: Set<FiredAlert.ID> = []
    var alertError: String?
    /// Set when a server's certificate failed validation; the root view shows a sheet to trust or refuse it.
    var trustRequest: TrustRequest?
    private var alertFilter = AlertNotificationFilter()
    private var indexedVMs: Set<String> = []

    enum LiveState: Equatable { case off, live, retrying(Int) }
    var liveState = LiveState.off
    var lastUpdated: Date?
    private var liveTask: Task<Void, Never>?
    private var isRefreshing = false

    var canWrite: Bool { session?.role == "editor" || session?.role == "admin" }

    init() {
        profiles = Prefs.defaultFirst(store.load())
        // Catch up immediately when the user comes back to the app instead of waiting out the slow idle interval.
        NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification,
                                               object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in await self?.refresh(quiet: true) }
        }
    }

    /// Try the saved token for a profile; on rejection forget it so the user signs in again.
    func resume(_ profile: ServerProfile) async {
        guard let token = store.token(for: profile) else { return }
        isLoading = true; defer { isLoading = false }
        let c = ZeusClient(baseURL: profile.url, token: token, pinnedFingerprint: profile.pinnedFingerprint)
        do {
            _ = try await c.alertStats()          // cheap authenticated probe
            client = c; active = profile
            session = LoginResponse(token: token, username: profile.username, role: profile.role ?? "viewer",
                                    tenantIds: [], expiresIn: 0)
            error = nil
            alertFilter.reset()
            await refresh()
            startLive()
        } catch ZeusError.unauthorized {
            try? store.setToken(nil, for: profile)
        } catch ZeusError.untrustedCertificate(let info) {
            trustRequest = TrustRequest(info: info, host: profile.url.host() ?? profile.name,
                                        changed: profile.pinnedFingerprint != nil) { [weak self] fp in
                guard let self else { return }
                var p = profile; p.pinnedFingerprint = fp
                await self.resume(self.store.upsert(p))
                self.profiles = Prefs.defaultFirst(self.store.load())
            }
        } catch {
            self.error = "Couldn't reach \(profile.url.host() ?? "server")."
        }
    }

    func signIn(name: String, url: URL, username: String, password: String, remember: Bool,
                trusting pin: String? = nil) async {
        isLoading = true; defer { isLoading = false }
        let pin = pin ?? store.load().first { $0.url == url && $0.username == username }?.pinnedFingerprint
        do {
            let anon = ZeusClient(baseURL: url, pinnedFingerprint: pin)
            let s = try await anon.login(username: username, password: password)
            let profile = store.upsert(ServerProfile(name: name.isEmpty ? (url.host() ?? "Server") : name,
                                                     url: url, username: username, role: s.role,
                                                     pinnedFingerprint: pin))
            if remember {
                do { try store.setToken(s.token, for: profile) }
                catch { notice = "Signed in, but couldn't save to the Keychain." }
            }
            profiles = store.load(); active = profile
            session = s; client = anon.withToken(s.token); error = nil
            alertFilter.reset()
            await refresh()
            startLive()
        } catch ZeusError.unauthorized {
            error = "Wrong username or password."
        } catch ZeusError.untrustedCertificate(let info) {
            trustRequest = TrustRequest(info: info, host: url.host() ?? "server", changed: pin != nil) { [weak self] fp in
                await self?.signIn(name: name, url: url, username: username, password: password,
                                   remember: remember, trusting: fp)
            }
        } catch {
            self.error = "Couldn't reach \(url.host() ?? "server")."
        }
    }

    /// Sends a power action, then polls until the machine's status changes (max ~30s).
    func perform(_ action: VMAction, on vm: VM) async {
        guard canWrite, let client, !busy.contains(vm.id) else { return }
        busy.insert(vm.id); defer { busy.remove(vm.id) }
        do {
            try await client.perform(action, on: vm)
            for _ in 0..<10 {
                try? await Task.sleep(for: .seconds(3))
                await refresh()
                if let now = vms.first(where: { $0.id == vm.id }), now.status != vm.status { break }
            }
            error = nil
        } catch ZeusError.server(let status, let message) where status == 403 {
            error = message.isEmpty ? "Your role can't \(action.rawValue) machines." : message
        } catch ZeusError.unauthorized {
            signOut(forget: false); error = "Session expired. Sign in again."
        } catch {
            self.error = "Couldn't \(action.rawValue) \(vm.name)."
        }
    }

    /// Acknowledges each alert in turn and reports partial failure. An alert that vanished (404) or was
    /// already handled isn't an error worth shouting about; the refresh afterwards shows the truth.
    func acknowledge(_ targets: [FiredAlert]) async {
        await act(on: targets.filter { !$0.acknowledged }, verb: "acknowledge") { try await $0.acknowledge($1) }
    }

    /// Resolves each alert (acknowledged or not) with the same partial-failure handling as `acknowledge`.
    func resolve(_ targets: [FiredAlert]) async {
        await act(on: targets, verb: "resolve") { try await $0.resolve($1) }
    }

    private func act(on targets: [FiredAlert], verb: String,
                     _ call: (ZeusClient, FiredAlert) async throws -> Void) async {
        let todo = targets.filter { !busyAlerts.contains($0.id) }
        guard canWrite, let client, !todo.isEmpty else { return }
        alertError = nil
        busyAlerts.formUnion(todo.map(\.id))
        defer { busyAlerts.subtract(todo.map(\.id)) }
        var failed = 0
        for alert in todo {
            do { try await call(client, alert) }
            catch ZeusError.unauthorized { signOut(forget: false); error = "Session expired. Sign in again."; return }
            catch ZeusError.server(let status, let message) where status == 403 {
                alertError = message.isEmpty ? "Your role can't \(verb) alerts." : message
                break
            }
            catch ZeusError.server(let status, _) where status == 404 { }
            catch { failed += 1 }
        }
        if failed > 0 && alertError == nil {
            alertError = failed == todo.count ? "Couldn't \(verb) the selected alerts."
                                              : "Couldn't \(verb) \(failed) of \(todo.count) alerts."
        }
        await refresh(quiet: true)
    }

    func forget(_ profile: ServerProfile) {
        store.delete(profile); profiles = store.load()
        if active == profile { signOut(forget: false) }
    }

    func signOut(forget: Bool = true) {
        if forget, let p = active { try? store.setToken(nil, for: p) }
        liveTask?.cancel(); liveTask = nil
        session = nil; client = nil; active = nil
        alertFilter.reset(); SpotlightIndexer.clear(); indexedVMs = []
        vms = []; alerts = nil; alertList = nil; alertError = nil; busyAlerts = []; cluster = nil; nodes = []
        liveState = .off; lastUpdated = nil; busy = []
    }

    /// Polls for as long as a session exists: quickly while the app is in front, slowly behind,
    /// and with backoff while the server is failing. Runs at model level so the menu bar extra
    /// stays current with no window open.
    private func startLive() {
        liveTask?.cancel()
        liveState = .live
        liveTask = Task { [weak self] in
            var interval = Prefs.pollSeconds
            var backoff = PollBackoff(active: .seconds(interval), idle: .seconds(max(30, interval)))
            while !Task.isCancelled {
                if Prefs.pollSeconds != interval {
                    interval = Prefs.pollSeconds
                    backoff = PollBackoff(active: .seconds(interval), idle: .seconds(max(30, interval)))
                }
                try? await Task.sleep(for: backoff.delay(appIsActive: NSApplication.shared.isActive))
                guard !Task.isCancelled, let self, self.client != nil else { return }
                if await self.refresh(quiet: true) { backoff.succeeded() } else { backoff.failed() }
                guard self.client != nil else { return }          // signed out during the request
                self.liveState = backoff.failures == 0 ? .live : .retrying(backoff.failures)
            }
        }
    }

    /// Returns whether the refresh succeeded. `quiet` leaves `error` alone so background polling
    /// doesn't wipe (or spam) messages about the user's own actions; auth loss is always reported.
    @discardableResult
    func refresh(quiet: Bool = false) async -> Bool {
        guard let client, !isRefreshing else { return false }
        isRefreshing = true; defer { isRefreshing = false }
        do {
            async let v = client.vms()
            async let a = client.alertStats()
            async let c = try? client.clusterMetrics()     // optional: don't fail the refresh over these
            async let n = try? client.nodeMetrics()
            async let l = try? client.alerts()
            let (newVMs, newAlerts) = try await (v, a)
            let (newCluster, newNodes, newList) = await (c, n ?? [], l)
            guard self.client === client else { return false }   // signed out or switched server mid-flight
            vms = newVMs; alerts = newAlerts; alertList = newList; cluster = newCluster; nodes = newNodes
            lastUpdated = .now
            if let newList { NotificationService.shared.notify(alertFilter.newAlerts(in: newList), server: active?.name) }
            let ids = Set(newVMs.map(\.id))
            if ids != indexedVMs { indexedVMs = ids; SpotlightIndexer.index(newVMs, server: active?.name ?? "Zeus") }
            if !quiet { error = nil }
            return true
        } catch ZeusError.unauthorized {
            guard self.client === client else { return false }
            if let p = active { try? store.setToken(nil, for: p) }
            signOut(forget: false); error = "Session expired. Sign in again."
            return false
        } catch {
            if !quiet && self.client === client { self.error = "Refresh failed." }
            return false
        }
    }
}
