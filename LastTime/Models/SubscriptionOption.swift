import Foundation

enum SubscriptionPeriod: String {
    case month
    case year
}

struct SubscriptionOption: Identifiable, Equatable {
    let id: String
    let period: SubscriptionPeriod
    let titleKey: String
    let priceKey: String
    let priceValue: String
    let isBestValue: Bool
    let productIdentifier: String

    static let month = SubscriptionOption(
        id: "month",
        period: .month,
        titleKey: "paywall.option.month",
        priceKey: "paywall.per_month",
        priceValue: "4.97",
        isBestValue: false,
        productIdentifier: AppConstants.InAppPurchase.monthlyProductId
    )

    static let year = SubscriptionOption(
        id: "year",
        period: .year,
        titleKey: "paywall.option.year",
        priceKey: "paywall.per_year",
        priceValue: "29.97",
        isBestValue: true,
        productIdentifier: AppConstants.InAppPurchase.yearlyProductId
    )

    static let all: [SubscriptionOption] = [.month, .year]
}
