import Combine
import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var records: [ActivityRecord] = []

    private let activity: Activity
    private let storage: StorageServiceProtocol

    init(activity: Activity, storage: StorageServiceProtocol = StorageService()) {
        self.activity = activity
        self.storage = storage
        loadRecords()
    }

    func loadRecords() {
        let allRecords = storage.loadRecords()
        records = allRecords
            .filter { $0.activityId == activity.id }
            .sorted { $0.date > $1.date }
    }
}
