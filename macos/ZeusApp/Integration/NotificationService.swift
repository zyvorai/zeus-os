import Foundation
import UserNotifications
import ZeusKit

/// Local banners for new alerts. Authorization is requested lazily: when the user turns the setting on,
/// or the first time a banner would be posted with the setting already on.
@MainActor
final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    private var delegateSet = false
    private var center: UNUserNotificationCenter { .current() }

    private func ensureDelegate() {
        if !delegateSet { center.delegate = self; delegateSet = true }
    }

    func requestAuthorization() async -> Bool {
        ensureDelegate()
        return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    func notify(_ alerts: [FiredAlert], server: String?) {
        guard Prefs.notificationsEnabled, !alerts.isEmpty else { return }
        ensureDelegate()
        Task {
            let center = self.center
            if await center.notificationSettings().authorizationStatus == .notDetermined { _ = await requestAuthorization() }
            guard await center.notificationSettings().authorizationStatus == .authorized else { return }
            for a in alerts.prefix(5) {                  // a burst shouldn't bury the screen
                let c = UNMutableNotificationContent()
                c.title = "\(a.severity.capitalized): \(a.ruleName)"
                c.body = "\(a.resourceName) in \(a.namespace)" + (server.map { " · \($0)" } ?? "")
                c.threadIdentifier = "zeus.alerts"
                try? await center.add(UNNotificationRequest(identifier: "zeus.alert.\(a.id)", content: c, trigger: nil))
            }
            if alerts.count > 5 {
                let c = UNMutableNotificationContent()
                c.title = "\(alerts.count - 5) more alerts"; c.threadIdentifier = "zeus.alerts"
                try? await center.add(UNNotificationRequest(identifier: "zeus.alert.more", content: c, trigger: nil))
            }
        }
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification)
        async -> UNNotificationPresentationOptions { [.banner, .sound] }
}
