import Combine
import Foundation

@MainActor
final class LanguageService: ObservableObject {
    @Published var currentLocale: Locale

    static let supportedIdentifiers = ["en", "de"]
    private static let userDefaultsKey = "app_language"

    init() {
        let saved = UserDefaults.standard.string(forKey: Self.userDefaultsKey)
        let identifier = Self.supportedIdentifiers.contains(saved ?? "") ? saved! : "en"
        self.currentLocale = Locale(identifier: identifier)
    }

    func setLanguage(_ identifier: String) {
        guard Self.supportedIdentifiers.contains(identifier) else { return }
        UserDefaults.standard.set(identifier, forKey: Self.userDefaultsKey)
        currentLocale = Locale(identifier: identifier)
    }
}
