import SwiftUI
import AppKit
import ZeusKit

// MARK: Model

/// Owns one RFB session and the latest framebuffer image. Input goes out as RFB key and pointer events.
@MainActor @Observable
final class VNCModel {
    enum State: Equatable { case idle, connecting, connected, closed(String?) }

    private(set) var state = State.idle
    private(set) var image: CGImage?
    private(set) var size = CGSize.zero
    private(set) var desktopName = ""
    private var session: RFBSession?
    private var reader: Task<Void, Never>?

    func connect(_ open: @escaping @Sendable () async throws -> RFBSession) {
        disconnect()
        image = nil
        state = .connecting
        reader = Task { [weak self] in
            do {
                let s = try await open()
                guard let self, !Task.isCancelled else { await s.close(); return }
                self.session = s
                for await event in s.events {
                    switch event {
                    case .ready(let name, let w, let h):
                        self.desktopName = name; self.size = CGSize(width: w, height: h); self.state = .connected
                    case .frame(let fb, _): self.image = Self.makeImage(fb)
                    case .bell: NSSound.beep()
                    case .closed(let why): self.state = .closed(why)
                    }
                }
                if self.state == .connected || self.state == .connecting { self.state = .closed(nil) }
            } catch is CancellationError {
            } catch ZeusError.server(let status, let message) where status == 403 {
                self?.state = .closed(message.isEmpty ? "Your role or console policy doesn't allow this session." : message)
            } catch {
                self?.state = .closed("Couldn't open the console.")
            }
        }
    }

    func disconnect() {
        reader?.cancel(); reader = nil
        if let s = session { Task { await s.close() } }
        session = nil
        if state == .connected || state == .connecting { state = .closed(nil) }
    }

    func key(_ keysym: UInt32, down: Bool) {
        guard let session, state == .connected else { return }
        Task { await session.sendKey(keysym: keysym, down: down) }
    }

    func pointer(buttons: UInt8, x: Int, y: Int) {
        guard let session, state == .connected else { return }
        Task { await session.sendPointer(buttons: buttons, x: x, y: y) }
    }

    func sendCtrlAltDelete() {
        for (k, down) in [(RFBKeysym.controlL, true), (RFBKeysym.altL, true), (RFBKeysym.delete, true),
                          (RFBKeysym.delete, false), (RFBKeysym.altL, false), (RFBKeysym.controlL, false)] {
            key(k, down: down)
        }
    }

    private static func makeImage(_ fb: RFBFramebuffer) -> CGImage? {
        guard let provider = CGDataProvider(data: Data(fb.pixels) as CFData) else { return nil }
        let info = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue
        return CGImage(width: fb.width, height: fb.height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: fb.width * 4,
                       space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: info), provider: provider,
                       decode: nil, shouldInterpolate: true, intent: .defaultIntent)
    }
}

// MARK: AppKit view

final class VNCNSView: NSView {
    var onKey: ((UInt32, Bool) -> Void)?
    var onPointer: ((UInt8, Int, Int) -> Void)?
    var framebufferSize = CGSize.zero
    private var buttons: UInt8 = 0
    private var pressed: [UInt16: UInt32] = [:]   // keyCode -> keysym sent on key down
    private var modifiersDown = Set<UInt16>()

    override var acceptsFirstResponder: Bool { true }
    override var isFlipped: Bool { true }

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        layer?.contentsGravity = .resizeAspect
        addTrackingArea(NSTrackingArea(rect: .zero, options: [.mouseMoved, .activeInKeyWindow, .inVisibleRect], owner: self))
    }
    required init?(coder: NSCoder) { fatalError() }

    func setImage(_ image: CGImage?) { layer?.contents = image }

    // The framebuffer is drawn aspect-fit; map view points back to framebuffer pixels.
    private func framebufferPoint(_ event: NSEvent) -> (Int, Int)? {
        guard framebufferSize.width > 0, framebufferSize.height > 0, bounds.width > 0, bounds.height > 0 else { return nil }
        let p = convert(event.locationInWindow, from: nil)
        let scale = min(bounds.width / framebufferSize.width, bounds.height / framebufferSize.height)
        let w = framebufferSize.width * scale, h = framebufferSize.height * scale
        let x = (p.x - (bounds.width - w) / 2) / scale
        let y = (p.y - (bounds.height - h) / 2) / scale
        return (Int(min(max(x, 0), framebufferSize.width - 1)), Int(min(max(y, 0), framebufferSize.height - 1)))
    }

    private func sendPointer(_ e: NSEvent, extra: UInt8 = 0) {
        guard let (x, y) = framebufferPoint(e) else { return }
        onPointer?(buttons | extra, x, y)
    }

    private func setButton(_ bit: UInt8, _ down: Bool, _ e: NSEvent) {
        if down { buttons |= bit } else { buttons &= ~bit }
        sendPointer(e)
    }

    override func mouseDown(with e: NSEvent) { window?.makeFirstResponder(self); setButton(1, true, e) }
    override func mouseUp(with e: NSEvent) { setButton(1, false, e) }
    override func otherMouseDown(with e: NSEvent) { setButton(2, true, e) }
    override func otherMouseUp(with e: NSEvent) { setButton(2, false, e) }
    override func rightMouseDown(with e: NSEvent) { setButton(4, true, e) }
    override func rightMouseUp(with e: NSEvent) { setButton(4, false, e) }
    override func mouseMoved(with e: NSEvent) { sendPointer(e) }
    override func mouseDragged(with e: NSEvent) { sendPointer(e) }
    override func rightMouseDragged(with e: NSEvent) { sendPointer(e) }
    override func otherMouseDragged(with e: NSEvent) { sendPointer(e) }

    override func scrollWheel(with e: NSEvent) {
        let dy = e.scrollingDeltaY
        guard dy != 0 else { return }
        let bit: UInt8 = dy > 0 ? 8 : 16   // wheel up / down
        sendPointer(e, extra: bit)
        sendPointer(e)
    }

    override func keyDown(with e: NSEvent) {
        let ctrl = e.modifierFlags.contains(.control)
        let keysym = RFBKeysym.special(keyCode: e.keyCode)
            ?? RFBKeysym.keysym(forCharacters: (ctrl ? e.charactersIgnoringModifiers : e.characters) ?? "")
        guard let keysym else { return }
        pressed[e.keyCode] = keysym
        onKey?(keysym, true)
    }

    override func keyUp(with e: NSEvent) {
        guard let keysym = pressed.removeValue(forKey: e.keyCode) else { return }
        onKey?(keysym, false)
    }

    override func flagsChanged(with e: NSEvent) {
        guard let keysym = RFBKeysym.modifier(keyCode: e.keyCode) else { return }
        if modifiersDown.remove(e.keyCode) != nil { onKey?(keysym, false) }
        else { modifiersDown.insert(e.keyCode); onKey?(keysym, true) }
    }

    /// Lets go of everything held, so a lost focus doesn't leave a key stuck in the guest.
    func releaseAll() {
        for (_, keysym) in pressed { onKey?(keysym, false) }
        pressed.removeAll()
        for code in modifiersDown { if let k = RFBKeysym.modifier(keyCode: code) { onKey?(k, false) } }
        modifiersDown.removeAll()
        if buttons != 0 { buttons = 0 }
    }

    override func resignFirstResponder() -> Bool { releaseAll(); return super.resignFirstResponder() }
    override func viewDidMoveToWindow() { if window != nil { window?.makeFirstResponder(self) } }
}

struct VNCView: NSViewRepresentable {
    let model: VNCModel

    func makeNSView(context: Context) -> VNCNSView {
        let v = VNCNSView(frame: .zero)
        v.onKey = { k, d in model.key(k, down: d) }
        v.onPointer = { b, x, y in model.pointer(buttons: b, x: x, y: y) }
        return v
    }

    func updateNSView(_ v: VNCNSView, context: Context) {
        v.framebufferSize = model.size
        v.setImage(model.image)
    }
}

// MARK: Sheet

struct GraphicalConsoleSheet: View {
    let vm: VM
    let client: ZeusClient
    @Environment(\.dismiss) private var dismiss
    @State private var model = VNCModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Graphical Console: \(vm.name)").font(.headline)
                status.font(.callout)
                Spacer()
                Button("Ctrl+Alt+Del") { model.sendCtrlAltDelete() }.disabled(model.state != .connected)
                Button("Reconnect") { connect() }.disabled(model.state == .connecting || model.state == .connected)
                Button("Done") { dismiss() }.keyboardShortcut(.cancelAction)
            }
            .padding(10)
            Divider()
            VNCView(model: model)
                .overlay { if model.state == .connecting { ProgressView() } }
                .accessibilityLabel("Graphical console")
        }
        .frame(minWidth: 800, minHeight: 560)
        .task { connect() }
        .onDisappear { model.disconnect() }
    }

    @ViewBuilder private var status: some View {
        switch model.state {
        case .idle: Label("Not connected", systemImage: "circle")
        case .connecting: Label("Connecting", systemImage: "circle.dotted")
        case .connected: Label("Connected", systemImage: "circle.fill").foregroundStyle(.green)
        case .closed(let why): Label(why ?? "Disconnected", systemImage: "xmark.circle").foregroundStyle(.secondary)
        }
    }

    private func connect() { model.connect { try await client.openGraphicalConsole(of: vm) } }
}
