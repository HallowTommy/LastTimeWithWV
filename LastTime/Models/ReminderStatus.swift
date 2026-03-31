import Foundation

enum ReminderStatusState {
    case ok
    case soon
    case overdue
}

struct ReminderStatus {
    let nextDate: Date
    let state: ReminderStatusState
}

extension Activity {
    /// Returns reminder status when activity has both lastDoneDate and reminderType. "Soon" = within 2 days of next reminder.
    var reminderStatus: ReminderStatus? {
        guard let last = lastDoneDate, let rem = reminderType else { return nil }
        let next = last.addingTimeInterval(rem.timeInterval)
        let now = Date()
        if now >= next {
            return ReminderStatus(nextDate: next, state: .overdue)
        }
        let daysUntil = next.timeIntervalSince(now) / 86400
        if daysUntil <= 2 {
            return ReminderStatus(nextDate: next, state: .soon)
        }
        return ReminderStatus(nextDate: next, state: .ok)
    }

    var isOverdue: Bool {
        reminderStatus?.state == .overdue
    }
}
