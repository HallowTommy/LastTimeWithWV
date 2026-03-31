import Foundation

enum OnboardingService {
    private static let hasCompletedOnboardingKey = "lasttime_hasCompletedOnboarding"

    static var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasCompletedOnboardingKey)
        }
    }
}
