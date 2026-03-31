import Foundation
import Combine

@MainActor
final class PremiumService: ObservableObject {
    @Published private(set) var isPremium: Bool {
        didSet {
            UserDefaults.standard.set(isPremium, forKey: AppConstants.Storage.isPremiumKey)
        }
    }

    init() {
        self.isPremium = true
        UserDefaults.standard.set(true, forKey: AppConstants.Storage.isPremiumKey)
    }

    func activatePremium() {
        isPremium = true
    }
}
