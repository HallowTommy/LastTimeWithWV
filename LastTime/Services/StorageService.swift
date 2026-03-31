import Foundation

protocol StorageServiceProtocol: Sendable {
    func loadActivities() -> [Activity]
    func saveActivities(_ activities: [Activity])
    func loadRecords() -> [ActivityRecord]
    func saveRecords(_ records: [ActivityRecord])
    func loadCategories() -> [ActivityCategory]
    func saveCategories(_ categories: [ActivityCategory])
}

final class StorageService: StorageServiceProtocol {
    private let fileManager = FileManager.default
    private let activitiesKey = AppConstants.Storage.activitiesKey
    private let recordsKey = AppConstants.Storage.recordsKey
    private let categoriesKey = AppConstants.Storage.categoriesKey

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var activitiesFileURL: URL {
        documentsURL.appendingPathComponent("\(activitiesKey).json")
    }

    private var recordsFileURL: URL {
        documentsURL.appendingPathComponent("\(recordsKey).json")
    }

    private var categoriesFileURL: URL {
        documentsURL.appendingPathComponent("\(categoriesKey).json")
    }

    func loadActivities() -> [Activity] {
        loadFromFile(url: activitiesFileURL, type: [Activity].self) ?? []
    }

    func saveActivities(_ activities: [Activity]) {
        saveToFile(activities, url: activitiesFileURL)
    }

    func loadRecords() -> [ActivityRecord] {
        loadFromFile(url: recordsFileURL, type: [ActivityRecord].self) ?? []
    }

    func saveRecords(_ records: [ActivityRecord]) {
        saveToFile(records, url: recordsFileURL)
    }

    func loadCategories() -> [ActivityCategory] {
        loadFromFile(url: categoriesFileURL, type: [ActivityCategory].self) ?? []
    }

    func saveCategories(_ categories: [ActivityCategory]) {
        saveToFile(categories, url: categoriesFileURL)
    }

    private func loadFromFile<T: Decodable>(url: URL, type: T.Type) -> T? {
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func saveToFile<T: Encodable>(_ value: T, url: URL) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        try? data.write(to: url)
    }
}
