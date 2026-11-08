import SwiftUI
import ZeusKit

/// Loads one resource for a screen and keeps it fresh. Screens in later waves share this instead of
/// each re-implementing loading, error and refresh handling.
@MainActor @Observable
final class Loader<T: Sendable> {
    enum Phase { case idle, loading, loaded, failed(String) }

    private(set) var value: T?
    private(set) var phase = Phase.idle
    private(set) var updated: Date?
    private let fetch: @Sendable () async throws -> T
    private var task: Task<Void, Never>?

    init(_ fetch: @escaping @Sendable () async throws -> T) { self.fetch = fetch }

    /// One load. Keeps the previous value on failure so a flaky poll doesn't blank the screen.
    func reload() async {
        if value == nil { phase = .loading }
        do {
            value = try await fetch(); updated = .now; phase = .loaded
        } catch is CancellationError {
        } catch ZeusError.server(let status, let message) where status == 403 {
            phase = .failed(message.isEmpty ? "Your role can't view this." : message)
        } catch {
            phase = .failed("Couldn't load. Check the connection and try again.")
        }
    }

    /// Loads now, then keeps reloading (fast while the app is in front, slow behind, backing off on failure).
    func start(polling: Bool = true) {
        task?.cancel()
        task = Task { [weak self] in
            var backoff = PollBackoff()
            await self?.reload()
            while polling, !Task.isCancelled {
                try? await Task.sleep(for: backoff.delay(appIsActive: NSApplication.shared.isActive))
                guard !Task.isCancelled, let self else { return }
                await self.reload()
                if case .failed = self.phase { backoff.failed() } else { backoff.succeeded() }
            }
        }
    }

    func stop() { task?.cancel(); task = nil }
}

/// Standard loading / error / content switch so every screen shows failures the same honest way.
struct LoadStateView<T: Sendable, Content: View>: View {
    let loader: Loader<T>
    @ViewBuilder var content: (T) -> Content

    var body: some View {
        if let value = loader.value {
            content(value)
                .safeAreaInset(edge: .top, spacing: 0) {
                    if case .failed(let message) = loader.phase {
                        Label("Showing the last data loaded. \(message)", systemImage: "exclamationmark.triangle")
                            .font(.caption).foregroundStyle(.orange)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12).padding(.vertical, 6).background(.bar)
                    }
                }
        } else {
            switch loader.phase {
            case .failed(let message):
                ContentUnavailableView {
                    Label("Couldn't load", systemImage: "exclamationmark.triangle")
                } description: { Text(message) } actions: {
                    Button("Try Again") { Task { await loader.reload() } }
                }
            default:
                ProgressView().controlSize(.large).frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

extension View {
    /// Says why a table is empty (nothing exists vs. the search filtered everything out) instead of leaving it blank.
    func emptyState(_ count: Int, searching: Bool, none: String, symbol: String = "tray") -> some View {
        overlay {
            if count == 0 {
                if searching { ContentUnavailableView("No matches", systemImage: "magnifyingglass") }
                else { ContentUnavailableView(none, systemImage: symbol) }
            }
        }
    }
}
