import Combine
import Foundation

@MainActor
final class CategoriesViewModel: ObservableObject {
    @Published var categories: [ActivityCategory] = []

    private let storage: StorageServiceProtocol

    init(storage: StorageServiceProtocol = StorageService()) {
        self.storage = storage
        loadCategories()
    }

    func loadCategories() {
        categories = storage.loadCategories()
    }

    func addCategory(name: String, colorHex: String) {
        let category = ActivityCategory(name: name, colorHex: colorHex)
        categories.append(category)
        storage.saveCategories(categories)
    }

    func updateCategory(id: UUID, name: String, colorHex: String) {
        guard let idx = categories.firstIndex(where: { $0.id == id }) else { return }
        categories[idx] = ActivityCategory(
            id: categories[idx].id,
            name: name,
            iconAssetName: categories[idx].iconAssetName,
            colorHex: colorHex
        )
        storage.saveCategories(categories)
    }

    func deleteCategory(_ category: ActivityCategory) {
        categories.removeAll { $0.id == category.id }
        storage.saveCategories(categories)
    }
}
