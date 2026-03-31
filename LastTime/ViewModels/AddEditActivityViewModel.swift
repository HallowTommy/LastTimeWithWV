import Combine
import Foundation
import UIKit

@MainActor
final class AddEditActivityViewModel: ObservableObject {
    @Published var title: String
    @Published var selectedReminder: ReminderType?
    @Published var reminderAt: Date
    @Published var selectedCategoryId: UUID?
    @Published var isReminderPickerPresented = false
    @Published var selectedImage: UIImage?
    @Published var selectedImageData: Data?

    let activity: Activity?
    private let storage: StorageServiceProtocol
    private let imageStorage: ImageStorageServiceProtocol

    var categories: [ActivityCategory] {
        storage.loadCategories()
    }

    init(
        activity: Activity? = nil,
        storage: StorageServiceProtocol = StorageService(),
        imageStorage: ImageStorageServiceProtocol = ImageStorageService()
    ) {
        self.activity = activity
        self.storage = storage
        self.imageStorage = imageStorage
        self.title = activity?.title ?? ""
        self.selectedReminder = activity?.reminderType
        if let at = activity?.reminderAt {
            self.reminderAt = at
        } else if let last = activity?.lastDoneDate, let rem = activity?.reminderType {
            self.reminderAt = last.addingTimeInterval(rem.timeInterval)
        } else {
            self.reminderAt = Date().addingTimeInterval(86400)
        }
        self.selectedCategoryId = activity?.categoryId
        if let path = activity?.imagePath, let img = imageStorage.loadImage(path: path) {
            self.selectedImage = img
        }
    }

    var isEditing: Bool { activity != nil }

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
        var imagePath: String?
        let activityId: UUID

        if let existing = activity {
            activityId = existing.id
            if selectedImage == nil {
                if let oldPath = existing.imagePath {
                    imageStorage.deleteImage(path: oldPath)
                }
                imagePath = nil
            } else if let data = selectedImageData {
                if let oldPath = existing.imagePath {
                    imageStorage.deleteImage(path: oldPath)
                }
                imagePath = imageStorage.saveImage(data, for: existing.id)
            } else {
                imagePath = existing.imagePath
            }
            guard let idx = activities.firstIndex(where: { $0.id == existing.id }) else { return }
            activities[idx] = Activity(
                id: existing.id,
                title: trimmedTitle,
                lastDoneDate: existing.lastDoneDate,
                reminderType: selectedReminder,
                reminderAt: selectedReminder != nil ? reminderAt : nil,
                imagePath: imagePath ?? existing.imagePath,
                categoryId: selectedCategoryId,
                createdAt: existing.createdAt,
                recordIds: existing.recordIds
            )
        } else {
            let newActivity = Activity(title: trimmedTitle, reminderType: selectedReminder)
            activityId = newActivity.id
            if let data = selectedImageData {
                imagePath = imageStorage.saveImage(data, for: newActivity.id)
            }
            activities.append(Activity(
                id: newActivity.id,
                title: trimmedTitle,
                reminderType: selectedReminder,
                reminderAt: selectedReminder != nil ? reminderAt : nil,
                imagePath: imagePath,
                categoryId: selectedCategoryId,
                createdAt: newActivity.createdAt,
                recordIds: newActivity.recordIds
            ))
        }

        storage.saveActivities(activities)

        if let updated = activities.first(where: { $0.id == activityId }) {
            if updated.reminderType != nil {
                NotificationService.shared.scheduleReminder(for: updated)
            } else if updated.reminderType == nil {
                NotificationService.shared.cancelReminder(for: updated)
            }
        }
    }
}
