import SwiftUI
import AppKit
import ZeusKit

// MARK: Terminal model

/// Owns one console connection and the text it has produced.
@MainActor @Observable
final class TerminalModel {
    enum State: Equatable { case idle, connecting, connected, closed(String?) }

    private(set) var buffer = TerminalBuffer()
    private(set) var state = State.idle
    private var session: ConsoleSession?
    private var reader: Task<Void, Never>?

    var screen: String { buffer.text }

    func connect(_ open: @escaping @Sendable () async throws -> ConsoleSession) {
        disconnect()
        buffer = TerminalBuffer()
        state = .connecting
        reader = Task { [weak self] in
            do {
                let s = try await open()
                guard let self, !Task.isCancelled else { s.close(); return }
                self.session = s
                self.state = .connected
                for await event in s.events {
                    guard !Task.isCancelled else { return }   // a newer connect() owns the state now
                    switch event {
                    case .output(let d): self.buffer.feed(d)
                    case .closed(let why): self.state = .closed(why)
                    }
                }
                if !Task.isCancelled, self.state == .connected { self.state = .closed(nil) }
            } catch is CancellationError {
            } catch where Task.isCancelled {
            } catch ZeusError.server(let status, let message) where status == 403 {
                self?.state = .closed(message.isEmpty ? "Your role or console policy doesn't allow this session." : message)
            } catch {
                self?.state = .closed("Couldn't open the console.")
            }
        }
    }

    func disconnect() {
        reader?.cancel(); reader = nil
        session?.close(); session = nil
        if state == .connected || state == .connecting { state = .closed(nil) }
    }

    func send(_ text: String) {
        guard let session, state == .connected else { return }
        Task { try? await session.send(text) }
    }

    func clear() { buffer.clear() }
}

// MARK: Terminal view

struct TerminalScreen: View {
    let model: TerminalModel
    @FocusState private var focused: Bool

    var body: some View {
        ScrollView {
            Text(model.screen + (model.state == .connected ? "\u{2588}" : ""))
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
        }
        .defaultScrollAnchor(.bottom)
        .background(Color.black)
        .foregroundStyle(Color(white: 0.9))
        .focusable()
        .focused($focused)
        .focusEffectDisabled()
        .onKeyPress(phases: [.down, .repeat]) { press in
            guard model.state == .connected, let key = Self.map(press) else { return .ignored }
            if press.modifiers.contains(.command) { return .ignored }
            guard let out = TerminalInput.encode(key, control: press.modifiers.contains(.control)) else { return .ignored }
            model.send(out)
            return .handled
        }
        .onPasteCommand(of: [.plainText]) { providers in
            for p in providers {
                _ = p.loadObject(ofClass: NSString.self) { s, _ in
                    if let s = s as? String { Task { @MainActor in model.send(s) } }
                }
            }
        }
        .onAppear { focused = true }
        .accessibilityLabel("Terminal")
    }

    private static func map(_ p: KeyPress) -> TerminalKey? {
        switch p.key {
        case .return: .enter
        case .delete: .backspace
        case .deleteForward: .delete
        case .tab: .tab
        case .escape: .escape
        case .upArrow: .up
        case .downArrow: .down
        case .leftArrow: .left
        case .rightArrow: .right
        case .home: .home
        case .end: .end
        default: p.characters.isEmpty ? nil : .character(p.characters)
        }
    }
}

private struct StatusLabel: View {
    let state: TerminalModel.State
    var body: some View {
        switch state {
        case .idle: Label("Not connected", systemImage: "circle")
        case .connecting: Label("Connecting", systemImage: "circle.dotted")
        case .connected: Label("Connected", systemImage: "circle.fill").foregroundStyle(.green)
        case .closed(let why): Label(why ?? "Disconnected", systemImage: "xmark.circle").foregroundStyle(.secondary)
        }
    }
}

// MARK: Serial console (sheet from the machine inspector)

struct SerialConsoleSheet: View {
    let vm: VM
    let client: ZeusClient
    @Environment(\.dismiss) private var dismiss
    @State private var model = TerminalModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Serial Console: \(vm.name)").font(.headline)
                StatusLabel(state: model.state).font(.callout)
                Spacer()
                Button("Clear") { model.clear() }
                Button("Reconnect") { connect() }
                    .disabled(model.state == .connecting || model.state == .connected)
                Button("Done") { dismiss() }.keyboardShortcut(.cancelAction)
            }
            .padding(10)
            Divider()
            TerminalScreen(model: model)
        }
        .frame(minWidth: 720, minHeight: 440)
        .task { connect() }
        .onDisappear { model.disconnect() }
    }

    private func connect() { model.connect { try await client.openSerialConsole(of: vm) } }
}

/// Console entry points for one machine, placed in the machine inspector.
struct VMConsoleButtons: View {
    let vm: VM
    let client: ZeusClient
    @Environment(AppModel.self) private var model
    @Environment(\.openURL) private var openURL
    @State private var serial = false
    @State private var graphical = false

    var body: some View {
        Group {
            Button("Serial Console…", systemImage: "terminal") { serial = true }
                .disabled(vm.status != "Running" || !model.canWrite)
                .help(model.canWrite ? "Open the serial console" : "Your role is read-only")
            Button("Graphical Console…", systemImage: "display.and.arrow.down") { graphical = true }
                .disabled(vm.status != "Running" || !model.canWrite)
                .help(model.canWrite ? "Open the graphical console (can send keyboard and mouse input)" : "Your role is read-only")
            Button("Graphical Console in Browser", systemImage: "display") {
                if let url = client.graphicalConsoleURL(for: vm) { openURL(url) }
            }
            .disabled(vm.status != "Running")
        }
        .sheet(isPresented: $serial) { SerialConsoleSheet(vm: vm, client: client) }
        .sheet(isPresented: $graphical) { GraphicalConsoleSheet(vm: vm, client: client) }
    }
}

// MARK: Pod terminal

struct PodTerminalView: View {
    let client: ZeusClient
    @State private var pods = Loader<[PodSummary]> { [] }
    @State private var selection: PodSummary.ID?
    @State private var container = ""
    @State private var search = ""
    @State private var model = TerminalModel()
    @Environment(AppModel.self) private var app

    private var selected: PodSummary? { pods.value?.first { $0.id == selection } }

    var body: some View {
        HSplitView {
            LoadStateView(loader: pods) { all in
                List(all.filter { search.isEmpty || $0.id.localizedCaseInsensitiveContains(search) },
                     selection: $selection) { p in
                    VStack(alignment: .leading) {
                        Text(p.name)
                        Text("\(p.namespace) · \(p.status ?? "—")").font(.caption).foregroundStyle(.secondary)
                    }
                    .opacity(p.shellAvailable == false ? 0.5 : 1)
                }
                .searchable(text: $search)
            }
            .frame(minWidth: 240, idealWidth: 280, maxWidth: 400)

            VStack(spacing: 0) {
                HStack {
                    if let p = selected {
                        Text(p.id).font(.headline)
                        if let cs = p.containers, cs.count > 1 {
                            Picker("Container", selection: $container) {
                                ForEach(cs, id: \.self) { Text($0).tag($0) }
                            }.fixedSize()
                        }
                    } else {
                        Text("Select a pod").foregroundStyle(.secondary)
                    }
                    StatusLabel(state: model.state).font(.callout)
                    Spacer()
                    Button("Clear") { model.clear() }
                    Button(model.state == .connected ? "Disconnect" : "Connect") { toggle() }
                        .disabled(selected == nil || !app.canWrite || selected?.shellAvailable == false)
                }
                .padding(10)
                if !app.canWrite {
                    Text("Your role is read-only, so terminals are disabled.").font(.footnote).foregroundStyle(.secondary)
                }
                Divider()
                TerminalScreen(model: model)
            }
            .frame(minWidth: 400)
        }
        .navigationTitle("Pod Terminal")
        .task { pods = Loader { try await client.pods() }; pods.start(polling: false) }
        .onChange(of: selection) { model.disconnect(); container = selected?.containers?.first ?? "" }
        .onDisappear { model.disconnect(); pods.stop() }
    }

    private func toggle() {
        if model.state == .connected { model.disconnect(); return }
        guard let p = selected else { return }
        let c = container.isEmpty ? (p.containers?.first ?? "") : container
        model.connect { try client.openPodTerminal(namespace: p.namespace, pod: p.name, container: c) }
    }
}

// MARK: Access requests and JIT grants (read-only)

struct ConsoleAccessData: Sendable { let requests: [ConsoleAccessRequest]; let grants: [ConsoleJitGrant] }

struct ConsoleAccessView: View {
    let client: ZeusClient
    @State private var loader: Loader<ConsoleAccessData>

    init(client: ZeusClient) {
        self.client = client
        _loader = State(initialValue: Loader {
            async let r = client.consoleAccessRequests()
            async let g = client.consoleJitGrants()
            return try await ConsoleAccessData(requests: r, grants: g)
        })
    }

    private func when(_ s: String) -> Text {
        if let d = zeusDate(s) { Text(d, format: .dateTime.month().day().hour().minute()) } else { Text(s) }
    }

    var body: some View {
        LoadStateView(loader: loader) { data in
            VStack(spacing: 0) {
                GroupBox("Access requests") {
                    if data.requests.isEmpty {
                        Text("No console access requests.").foregroundStyle(.secondary).frame(maxWidth: .infinity, minHeight: 60)
                    } else {
                        Table(data.requests) {
                            TableColumn("User", value: \.user)
                            TableColumn("Machine") { Text("\($0.namespace)/\($0.vmName)") }
                            TableColumn("Mode", value: \.mode).width(60)
                            TableColumn("Status") { Text($0.status.capitalized + ($0.breakGlass == true ? " (break-glass)" : "")) }
                            TableColumn("Reason", value: \.reason)
                            TableColumn("Approved by") { Text($0.approvedBy ?? "—") }
                            TableColumn("Requested") { when($0.createdAt) }
                        }
                    }
                }
                GroupBox("JIT grants") {
                    if data.grants.isEmpty {
                        Text("No just-in-time grants.").foregroundStyle(.secondary).frame(maxWidth: .infinity, minHeight: 60)
                    } else {
                        Table(data.grants) {
                            TableColumn("User", value: \.user)
                            TableColumn("Machine") { Text("\($0.namespace)/\($0.vmName)") }
                            TableColumn("Mode", value: \.mode).width(60)
                            TableColumn("Granted by", value: \.createdBy)
                            TableColumn("Expires") { when($0.expiresAt) }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Console Access")
        .toolbar { ToolbarItem { Button("Reload", systemImage: "arrow.clockwise") { Task { await loader.reload() } } } }
        .task { loader.start() }
        .onDisappear { loader.stop() }
    }
}
