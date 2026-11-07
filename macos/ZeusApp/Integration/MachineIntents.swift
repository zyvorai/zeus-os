import AppIntents
import ZeusKit

/// Builds a client from the Keychain-backed profile (the default server if set, else the first saved one
/// that still has a token). Nothing is cached or faked: no signed-in server means the intent throws.
enum IntentSession {
    enum Failure: Error, CustomLocalizedStringResourceConvertible {
        case notSignedIn, notFound(String), forbidden, failed
        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .notSignedIn: "Open Zeus and sign in with \"Remember in Keychain\" first."
            case .notFound(let n): "No machine named \(n) was found."
            case .forbidden: "Your role can't change machines."
            case .failed: "The server couldn't be reached or refused the request."
            }
        }
    }

    static func client() throws -> ZeusClient {
        let store = ProfileStore()
        for p in Prefs.defaultFirst(store.load()) {
            if let token = store.token(for: p) {
                return ZeusClient(baseURL: p.url, token: token, pinnedFingerprint: p.pinnedFingerprint)
            }
        }
        throw Failure.notSignedIn
    }

    static func vms() async throws -> [VM] {
        do { return try await client().vms() }
        catch let e as Failure { throw e }
        catch { throw Failure.failed }
    }
}

struct MachineEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Machine"
    static let defaultQuery = MachineQuery()

    let id: String                         // "namespace/name"
    let name: String
    let namespace: String
    let status: String

    init(_ vm: VM) { id = vm.id; name = vm.name; namespace = vm.namespace; status = vm.status }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(namespace) · \(status)")
    }
}

struct MachineQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [MachineEntity] {
        try await IntentSession.vms().filter { identifiers.contains($0.id) }.map(MachineEntity.init)
    }
    func entities(matching string: String) async throws -> [MachineEntity] {
        try await IntentSession.vms().filter { $0.name.localizedCaseInsensitiveContains(string) }.map(MachineEntity.init)
    }
    func suggestedEntities() async throws -> [MachineEntity] {
        try await IntentSession.vms().map(MachineEntity.init)
    }
}

/// Resolves the entity against the live list (it may have been deleted since Shortcuts saved it).
private func power(_ action: VMAction, _ machine: MachineEntity) async throws {
    let client = try IntentSession.client()
    guard let vm = try await IntentSession.vms().first(where: { $0.id == machine.id }) else {
        throw IntentSession.Failure.notFound(machine.name)
    }
    do { try await client.perform(action, on: vm) }
    catch ZeusError.server(let status, _) where status == 403 { throw IntentSession.Failure.forbidden }
    catch { throw IntentSession.Failure.failed }
}

struct StartMachineIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Machine"
    static let description = IntentDescription("Starts a stopped machine.")
    @Parameter(title: "Machine") var machine: MachineEntity
    static var parameterSummary: some ParameterSummary { Summary("Start \(\.$machine)") }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await power(.start, machine)
        return .result(dialog: "Start requested for \(machine.name).")
    }
}

struct StopMachineIntent: AppIntent {
    static let title: LocalizedStringResource = "Stop Machine"
    static let description = IntentDescription("Stops a running machine after you confirm.")
    @Parameter(title: "Machine") var machine: MachineEntity
    static var parameterSummary: some ParameterSummary { Summary("Stop \(\.$machine)") }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await requestConfirmation(result: .result(dialog: "Stop \(machine.name)?"))
        try await power(.stop, machine)
        return .result(dialog: "Stop requested for \(machine.name).")
    }
}

struct RestartMachineIntent: AppIntent {
    static let title: LocalizedStringResource = "Restart Machine"
    static let description = IntentDescription("Restarts a machine after you confirm.")
    @Parameter(title: "Machine") var machine: MachineEntity
    static var parameterSummary: some ParameterSummary { Summary("Restart \(\.$machine)") }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await requestConfirmation(result: .result(dialog: "Restart \(machine.name)?"))
        try await power(.restart, machine)
        return .result(dialog: "Restart requested for \(machine.name).")
    }
}

struct MachineStatusIntent: AppIntent {
    static let title: LocalizedStringResource = "Get Machine Status"
    static let description = IntentDescription("Reads a machine's current status from the server.")
    @Parameter(title: "Machine") var machine: MachineEntity
    static var parameterSummary: some ParameterSummary { Summary("Get status of \(\.$machine)") }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        guard let vm = try await IntentSession.vms().first(where: { $0.id == machine.id }) else {
            throw IntentSession.Failure.notFound(machine.name)
        }
        return .result(value: vm.status, dialog: "\(vm.name) is \(vm.status).")
    }
}

struct ZeusShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: MachineStatusIntent(), phrases: ["Get machine status in \(.applicationName)"],
                    shortTitle: "Machine Status", systemImageName: "server.rack")
        AppShortcut(intent: StartMachineIntent(), phrases: ["Start a machine in \(.applicationName)"],
                    shortTitle: "Start Machine", systemImageName: "play.circle")
    }
}
