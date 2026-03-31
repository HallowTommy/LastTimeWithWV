import Combine
import Foundation
import UIKit

@MainActor
final class ActivityDetailViewModel: ObservableObject {
    @Published var title: String
    @Published var selectedReminder: ReminderType?
    @Published var selectedCategoryId: UUID?
    @Published var isReminderPickerPresented = false
    @Published var selectedImage: UIImage?
    @Published var selectedImageData: Data?

    let activity: Activity
    private let storage: StorageServiceProtocol
    private let imageStorage: ImageStorageServiceProtocol

    var categories: [ActivityCategory] {
        storage.loadCategories()
    }

    @Published var averageIntervalDays: Double?
    @Published var currentStreak: Int = 0
    @Published var countThisMonth: Int = 0

    var activityRecords: [ActivityRecord] {
        storage.loadRecords()
            .filter { $0.activityId == activity.id }
            .sorted { $0.date > $1.date }
    }

    func loadStats() {
        let records = storage.loadRecords()
            .filter { $0.activityId == activity.id }
            .sorted { $0.date < $1.date }
        let calendar = Calendar.current
        let now = Date()

        countThisMonth = records.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }.count

        if records.count >= 2 {
            var totalDays: Double = 0
            for i in 1..<records.count {
                totalDays += records[i].date.timeIntervalSince(records[i - 1].date) / 86400
            }
            averageIntervalDays = totalDays / Double(records.count - 1)
        } else {
            averageIntervalDays = nil
        }

        let sortedDates = Set(records.map { calendar.startOfDay(for: $0.date) }).sorted(by: >)
        var streak = 0
        var current = calendar.startOfDay(for: now)
        for date in sortedDates {
            if date == current {
                streak += 1
                current = calendar.date(byAdding: .day, value: -1, to: current) ?? current
            } else if date < current {
                break
            }
        }
        currentStreak = streak
    }

    init(
        activity: Activity,
        storage: StorageServiceProtocol = StorageService(),
        imageStorage: ImageStorageServiceProtocol = ImageStorageService()
    ) {
        self.activity = activity
        self.storage = storage
        self.imageStorage = imageStorage
        self.title = activity.title
        self.selectedReminder = activity.reminderType
        self.selectedCategoryId = activity.categoryId
        if let path = activity.imagePath, let img = imageStorage.loadImage(path: path) {
            self.selectedImage = img
        }
    }

    func setImage(_ image: UIImage?) {
        selectedImage = image
        selectedImageData = image?.jpegData(compressionQuality: 0.8)
    }

    func removeImage() {
        selectedImage = nil
        selectedImageData = nil
    }

    func addCategory(name: String, colorHex: String) -> ActivityCategory? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        var categories = storage.loadCategories()
        let category = ActivityCategory(name: trimmed, colorHex: colorHex)
        categories.append(category)
        storage.saveCategories(categories)
        return category
    }

    func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        var activities = storage.loadActivities()
        guard let idx = activities.firstIndex(where: { $0.id == activity.id }) else { return }

        var imagePath: String?
        if selectedImage == nil {
            if let oldPath = activity.imagePath {
                imageStorage.deleteImage(path: oldPath)
            }
            imagePath = nil
        } else if let data = selectedImageData {
            if let oldPath = activity.imagePath {
                imageStorage.deleteImage(path: oldPath)
            }
            imagePath = imageStorage.saveImage(data, for: activity.id)
        } else {
            imagePath = activity.imagePath
        }

        let oldReminder = activities[idx].reminderType
        activities[idx] = Activity(
            id: activity.id,
            title: trimmedTitle,
            lastDoneDate: activity.lastDoneDate,
            reminderType: selectedReminder,
            reminderAt: activity.reminderAt,
            imagePath: imagePath,
            categoryId: selectedCategoryId,
            createdAt: activity.createdAt,
            recordIds: activity.recordIds
        )

        if selectedReminder == nil, oldReminder != nil {
            NotificationService.shared.cancelReminder(for: activities[idx])
        } else if let rem = selectedReminder, activities[idx].lastDoneDate != nil {
            NotificationService.shared.scheduleReminder(for: activities[idx])
        }

        storage.saveActivities(activities)
    }

    func markAsDone() {
        let now = Date()
        let record = ActivityRecord(date: now, activityId: activity.id)
        var updated = activity
        updated.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.lastDoneDate = now
        updated.reminderType = selectedReminder
        updated.reminderAt = nil
        updated.categoryId = selectedCategoryId
        updated.recordIds.append(record.id)

        var activities = storage.loadActivities()
        guard let idx = activities.firstIndex(where: { $0.id == activity.id }) else { return }

        var records = storage.loadRecords()
        records.append(record)
        activities[idx] = updated

        storage.saveRecords(records)
        storage.saveActivities(activities)

        if updated.reminderType != nil {
            NotificationService.shared.scheduleReminder(for: updated)
        }
    }

    func delete() {
        var activities = storage.loadActivities().filter { $0.id != activity.id }
        var records = storage.loadRecords().filter { $0.activityId != activity.id }
        if let path = activity.imagePath {
            imageStorage.deleteImage(path: path)
        }
        NotificationService.shared.cancelReminder(for: activity)
        storage.saveActivities(activities)
        storage.saveRecords(records)
    }
}
