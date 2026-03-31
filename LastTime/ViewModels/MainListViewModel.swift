import Combine
import Foundation

@MainActor
final class MainListViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var searchText = ""
    @Published var filter: MainListFilter = .all
    @Published var selectedCategoryId: UUID?
    @Published var isEditMode = false

    var categories: [ActivityCategory] {
        storage.loadCategories()
    }

    enum SortOrder: String, CaseIterable {
        case byLastDone
        case byTitle
        case byNextReminder

        var localizationKey: String {
            switch self {
            case .byLastDone: return "sort.by_last_done"
            case .byTitle: return "sort.by_title"
            case .byNextReminder: return "sort.by_next_reminder"
            }
        }
    }

    @Published var sortOrder: SortOrder = .byLastDone

    enum MainListFilter: String, CaseIterable {
        case all
        case withReminder
        case recent
        case overdue

        var localizationKey: String {
            switch self {
            case .all: return "filter.all"
            case .withReminder: return "filter.with_reminder"
            case .recent: return "filter.recent"
            case .overdue: return "filter.overdue"
            }
        }
    }

    private let storage: StorageServiceProtocol

    init(storage: StorageServiceProtocol = StorageService()) {
        self.storage = storage
        loadData()
    }

    func loadData() {
        activities = storage.loadActivities()
        NotificationService.shared.rescheduleAllReminders(for: activities)
        applyFilterAndSearch()
    }

    var filteredActivities: [Activity] {
        var result = activities

        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }

        switch filter {
        case .all:
            break
        case .withReminder:
            result = result.filter { $0.reminderType != nil }
        case .recent:
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            result = result.filter { ($0.lastDoneDate ?? .distantPast) >= weekAgo }
        case .overdue:
            result = result.filter { $0.isOverdue }
        }

        if let categoryId = selectedCategoryId {
            result = result.filter { $0.categoryId == categoryId }
        }

        switch sortOrder {
        case .byLastDone:
            return result.sorted { ($0.lastDoneDate ?? .distantPast) < ($1.lastDoneDate ?? .distantPast) }
        case .byTitle:
            return result.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .byNextReminder:
            return result.sorted { nextReminderDate(for: $0) < nextReminderDate(for: $1) }
        }
    }

    private func nextReminderDate(for activity: Activity) -> Date {
        guard let last = activity.lastDoneDate, let rem = activity.reminderType else { return .distantFuture }
        return last.addingTimeInterval(rem.timeInterval)
    }

    var overdueCount: Int {
        activities.filter { $0.isOverdue }.count
    }

    var dueThisWeekCount: Int {
        let now = Date()
        let calendar = Calendar.current
        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: now) else { return 0 }
        return activities.filter { activity in
            guard let status = activity.reminderStatus, status.state != .overdue else { return false }
            return status.nextDate >= now && status.nextDate < weekEnd
        }.count
    }

    var doneTodayCount: Int {
        let allRecords = storage.loadRecords()
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        return allRecords.filter { calendar.isDate($0.date, inSameDayAs: startOfToday) }.count
    }

    private func applyFilterAndSearch() {}

    func markAsDone(_ activity: Activity) {
        let now = Date()
        let record = ActivityRecord(date: now, activityId: activity.id)
        var updatedActivity = activity
        updatedActivity.lastDoneDate = now
        updatedActivity.recordIds.append(record.id)

        var activitiesList = storage.loadActivities()
        guard let idx = activitiesList.firstIndex(where: { $0.id == activity.id }) else { return }

        var records = storage.loadRecords()
        records.append(record)
        activitiesList[idx] = updatedActivity

        storage.saveRecords(records)
        storage.saveActivities(activitiesList)

        if updatedActivity.reminderType != nil {
            NotificationService.shared.scheduleReminder(for: updatedActivity)
        }

        loadData()
    }

    func deleteActivity(_ activity: Activity) {
        NotificationService.shared.cancelReminder(for: activity)
        var activitiesList = storage.loadActivities().filter { $0.id != activity.id }
        var records = storage.loadRecords().filter { $0.activityId != activity.id }
        storage.saveActivities(activitiesList)
        storage.saveRecords(records)
        loadData()
    }
}
