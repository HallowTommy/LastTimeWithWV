import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    /// Number of daily repeat notifications to schedule after the initial reminder (e.g. remind daily until user marks done).
    private let repeatDaysCount = 14

    private init() {}

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func scheduleReminder(for activity: Activity) {
        guard activity.reminderType != nil else { return }

        let triggerDate: Date
        if let custom = activity.reminderAt, custom > Date() {
            triggerDate = custom
        } else if let lastDone = activity.lastDoneDate, let reminderType = activity.reminderType {
            triggerDate = lastDone.addingTimeInterval(reminderType.timeInterval)
        } else {
            return
        }

        requestAuthorization { granted in
            guard granted else { return }
            self.cancelReminder(for: activity)

            let locale = Locale(identifier: UserDefaults.standard.string(forKey: "app_language") ?? "en")
            let content = UNMutableNotificationContent()
            content.title = String(localized: String.LocalizationValue("notification.title"), locale: locale)
            content.body = "\(String(localized: String.LocalizationValue("notification.body_prefix"), locale: locale)) \(activity.title)"
            content.sound = .default

            let calendar = Calendar.current

            var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let initialId = "\(AppConstants.Notification.requestIdentifierPrefix)\(activity.id.uuidString)"
            let initialRequest = UNNotificationRequest(identifier: initialId, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(initialRequest)

            for dayOffset in 1...self.repeatDaysCount {
                guard let repeatDate = calendar.date(byAdding: .day, value: dayOffset, to: triggerDate) else { continue }
                let repeatComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: repeatDate)
                let repeatTrigger = UNCalendarNotificationTrigger(dateMatching: repeatComponents, repeats: false)
                let repeatId = "\(AppConstants.Notification.requestIdentifierPrefix)\(activity.id.uuidString)_repeat_\(dayOffset)"
                let repeatRequest = UNNotificationRequest(identifier: repeatId, content: content, trigger: repeatTrigger)
                UNUserNotificationCenter.current().add(repeatRequest)
            }
        }
    }

    func cancelReminder(for activity: Activity) {
        var identifiers = ["\(AppConstants.Notification.requestIdentifierPrefix)\(activity.id.uuidString)"]
        for i in 1...self.repeatDaysCount {
            identifiers.append("\(AppConstants.Notification.requestIdentifierPrefix)\(activity.id.uuidString)_repeat_\(i)")
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func rescheduleAllReminders(for activities: [Activity]) {
        for activity in activities where activity.reminderType != nil {
            scheduleReminder(for: activity)
        }
    }
}
