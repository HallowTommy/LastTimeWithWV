import Combine
import Foundation

@MainActor
final class TemplatesViewModel: ObservableObject {
    @Published var templateKeys: [String] = TemplatesData.templateKeys

    private let storage: StorageServiceProtocol

    init(storage: StorageServiceProtocol = StorageService()) {
        self.storage = storage
    }

    func addTemplate(title: String) -> Bool {
        var activities = storage.loadActivities()
        guard !activities.contains(where: { $0.title == title }) else { return false }
        activities.append(Activity(title: title))
        storage.saveActivities(activities)
        return true
    }

    func isTemplateAdded(key: String, locale: Locale) -> Bool {
        let localizedTitle = String(localized: String.LocalizationValue(key), locale: locale)
        return storage.loadActivities().contains { $0.title == localizedTitle }
    }

    var activitiesCount: Int {
        storage.loadActivities().count
    }
}
