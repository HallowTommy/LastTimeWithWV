import Foundation

struct ActivityRecord: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var activityId: UUID

    init(id: UUID = UUID(), date: Date, activityId: UUID) {
        self.id = id
        self.date = date
        self.activityId = activityId
    }
}
