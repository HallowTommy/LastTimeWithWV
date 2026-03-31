import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.backgroundPrimary, AppColors.backgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $viewModel.currentPageIndex) {
                    ForEach(viewModel.pages) { page in
                        onboardingPageContent(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: viewModel.currentPageIndex) { _, newIndex in
                    if newIndex == 1 {
                        NotificationService.shared.requestAuthorization { granted in
                            if granted {
                                UserDefaults.standard.set(true, forKey: "notifications_enabled")
                            }
                        }
                    }
                }

                VStack(spacing: 16) {
                    if viewModel.isLastPage {
                        Button {
                            viewModel.complete()
                            onComplete()
                        } label: {
                            Text("onboarding.getStarted")
                                .font(.headline)
                                .foregroundStyle(AppColors.backgroundPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.accent)
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.buttonCornerRadius))
                        }
                    } else {
                        Button {
                            viewModel.next()
                        } label: {
                            Text("onboarding.next")
                                .font(.headline)
                                .foregroundStyle(AppColors.backgroundPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.accent)
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.buttonCornerRadius))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }

    private func onboardingPageContent(page: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            Spacer(minLength: 24)

            Image(systemName: page.systemImageName)
                .font(.system(size: 80))
                .foregroundStyle(AppColors.accent)

            VStack(spacing: 8) {
                Text(LocalizedStringKey(page.titleKey))
                    .font(.title2.bold())
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(LocalizedStringKey(page.descriptionKey))
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 24)
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
