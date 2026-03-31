import Foundation

struct Activity: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var lastDoneDate: Date?
    var reminderType: ReminderType?
    var reminderAt: Date?
    var imagePath: String?
    var categoryId: UUID?
    var createdAt: Date
    var recordIds: [UUID]

    init(
        id: UUID = UUID(),
        title: String,
        lastDoneDate: Date? = nil,
        reminderType: ReminderType? = nil,
        reminderAt: Date? = nil,
        imagePath: String? = nil,
        categoryId: UUID? = nil,
        createdAt: Date = Date(),
        recordIds: [UUID] = []
    ) {
        self.id = id
        self.title = title
        self.lastDoneDate = lastDoneDate
        self.reminderType = reminderType
        self.reminderAt = reminderAt
        self.imagePath = imagePath
        self.categoryId = categoryId
        self.createdAt = createdAt
        self.recordIds = recordIds
    }
}
