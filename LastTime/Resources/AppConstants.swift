import Foundation

enum AppConstants {
    static let screenPadding: CGFloat = 16
    static let cardSpacing: CGFloat = 12
    static let cardCornerRadius: CGFloat = 12
    static let buttonCornerRadius: CGFloat = 10
    static let inputCornerRadius: CGFloat = 10
    static let cardHeight: CGFloat = 72

    enum Storage {
        static let activitiesKey = "lasttime_activities"
        static let recordsKey = "lasttime_records"
        static let categoriesKey = "lasttime_categories"
        static let imagesFolder = "ActivityImages"
        static let isPremiumKey = "lasttime_is_premium"
    }

    enum Notification {
        static let requestIdentifierPrefix = "lasttime_reminder_"
    }

    enum URLs {
        static let privacyPolicy = "https://sites.google.com/view/lasttimetrackerpolicy/mainweb"
        static let termsOfUse = "https://sites.google.com/view/lasttimetrackertermofuse/main"
        static let support = "https://sites.google.com/view/lasttimetrackersup/main"
    }

    /// Free tier limits; paywall is shown when exceeded and user is not premium.
    enum FreeLimits {
        static let activities = 3
    }

    /// In-App Purchase product identifiers (must match App Store Connect).
    enum InAppPurchase {
        static let monthlyProductId = "premium_monthly"
        static let yearlyProductId = "premium_one_year"
    }
}
