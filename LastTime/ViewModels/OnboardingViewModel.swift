import Combine
import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPageIndex: Int = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            systemImageName: "clock.arrow.circlepath",
            titleKey: "onboarding.screen1.title",
            descriptionKey: "onboarding.screen1.description"
        ),
        OnboardingPage(
            id: 1,
            systemImageName: "bell.badge",
            titleKey: "onboarding.screen2.title",
            descriptionKey: "onboarding.screen2.description"
        ),
        OnboardingPage(
            id: 2,
            systemImageName: "chart.bar.doc.horizontal",
            titleKey: "onboarding.screen3.title",
            descriptionKey: "onboarding.screen3.description"
        )
    ]

    var isLastPage: Bool {
        currentPageIndex == pages.count - 1
    }

    func next() {
        guard currentPageIndex < pages.count - 1 else { return }
        currentPageIndex += 1
    }

    func complete() {
        OnboardingService.hasCompletedOnboarding = true
    }
}
