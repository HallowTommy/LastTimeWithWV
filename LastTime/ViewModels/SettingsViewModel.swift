import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notifications_enabled")
            if notificationsEnabled {
                NotificationService.shared.requestAuthorization { _ in }
            }
        }
    }

    init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
    }
}
