import Foundation

struct PaywallBenefit: Identifiable {
    let id: String
    let systemImageName: String
    let titleKey: String

    static let unlimitedActivities = PaywallBenefit(
        id: "unlimited_activities",
        systemImageName: "infinity",
        titleKey: "paywall.benefit.unlimited_activities"
    )

    static let reminders = PaywallBenefit(
        id: "reminders",
        systemImageName: "bell.fill",
        titleKey: "paywall.benefit.reminders"
    )

    static let categories = PaywallBenefit(
        id: "categories",
        systemImageName: "folder.fill",
        titleKey: "paywall.benefit.categories"
    )

    static let statsAchievements = PaywallBenefit(
        id: "stats_achievements",
        systemImageName: "chart.bar.fill",
        titleKey: "paywall.benefit.stats_achievements"
    )

    static let all: [PaywallBenefit] = [
        .unlimitedActivities,
        .reminders,
        .categories,
        .statsAchievements
    ]
}
