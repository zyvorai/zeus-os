import AppKit
import SwiftUI
import Testing
import ZeusKit
@testable import ZeusApp

/// Design-review harness: renders key screens from fixtures to PNG (light and dark).
///
///     ZEUS_SNAPSHOT_DIR=/some/dir swift test --filter ZeusAppSnapshotTests
///
/// Without ZEUS_SNAPSHOT_DIR the tests do nothing, so a normal `swift test` stays fast and writes no files.
/// This needs no window server, but SwiftUI's ImageRenderer cannot draw AppKit-backed controls
/// (Table, Charts' interactive layers), which come out blank or as a placeholder.
@MainActor
struct SnapshotTests {
    static let outDir = ProcessInfo.processInfo.environment["ZEUS_SNAPSHOT_DIR"]

    func shoot<V: View>(_ name: String, size: CGSize = CGSize(width: 1100, height: 720), @ViewBuilder _ view: () -> V) throws {
        guard let dir = Self.outDir else { return }
        try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        for (scheme, label) in [(ColorScheme.light, "light"), (.dark, "dark")] {
            let content = view()
                .environment(\.colorScheme, scheme)
                .frame(width: size.width, height: size.height)
                .background(scheme == .dark ? Color(white: 0.12) : Color(white: 0.96))
            guard let png = Self.render(content, scheme: scheme, size: size) else {
                Issue.record("could not render \(name)"); continue
            }
            try png.write(to: URL(fileURLWithPath: "\(dir)/\(name)-\(label).png"))
        }
    }

    /// Hosts the view in an offscreen window and snapshots the backing view, which (unlike ImageRenderer)
    /// also draws AppKit-backed controls such as Table, Form and the sidebar List.
    static func render<V: View>(_ view: V, scheme: ColorScheme, size: CGSize) -> Data? {
        _ = NSApplication.shared
        let host = NSHostingView(rootView: view)
        host.frame = CGRect(origin: .zero, size: size)
        let window = NSWindow(contentRect: host.frame, styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
                              backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: scheme == .dark ? .darkAqua : .aqua)
        window.contentView = host
        window.setContentSize(size)
        window.orderBack(nil)
        host.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.6))   // let tables and lists populate
        host.layoutSubtreeIfNeeded()
        // Draw at 2x so text is legible when reviewing.
        guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width * 2), pixelsHigh: Int(size.height * 2),
                                         bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                         colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { return nil }
        rep.size = size
        host.cacheDisplay(in: host.bounds, to: rep)
        return rep.representation(using: .png, properties: [:])
    }

    @Test func signIn() throws {
        try shoot("signin", size: CGSize(width: 560, height: 640)) {
            LoginView().environment(Fixtures.signedOutModel(error: "Wrong username or password."))
        }
    }

    @Test func machines() throws {
        try shoot("machines") { MachinesView().environment(Fixtures.signedInModel()) }
    }

    @Test func overview() throws {
        try shoot("overview") { OverviewView().environment(Fixtures.signedInModel()) }
    }

    @Test func alerts() throws {
        try shoot("alerts") { AlertsView().environment(Fixtures.signedInModel()) }
    }

    @Test func fullWindow() throws {
        try shoot("window") { MainView().environment(Fixtures.signedInModel()) }
    }

    @Test func loaderError() async throws {
        let failed = Loader<[Int]> { throw ZeusError.transport(URLError(.notConnectedToInternet)) }
        await failed.reload()
        try shoot("loader-error", size: CGSize(width: 700, height: 420)) { LoadStateView(loader: failed) { _ in Text("data") } }
    }

    @Test func emptyState() throws {
        try shoot("empty", size: CGSize(width: 700, height: 420)) {
            JSONTable(rows: [], emptyTitle: "No snapshots", emptyDescription: "Nothing to show for this account.")
        }
    }

    @Test func jsonTable() throws {
        try shoot("jsontable", size: CGSize(width: 900, height: 420)) { JSONTable(rows: Fixtures.jsonRows) }
    }
}
