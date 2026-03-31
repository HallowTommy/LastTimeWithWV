import SwiftUI
import StoreKit

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject private var languageService: LanguageService
    @State private var showLanguagePicker = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.backgroundPrimary, AppColors.backgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
//                    premiumBanner
                    languageSection
                    categoriesSection
                    settingsSection
                }
            }
        }
        .navigationTitle("settings.navigation_title")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showLanguagePicker) {
            languagePickerSheet
        }
    }

    private var premiumBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .foregroundStyle(AppColors.accent)
            Text("settings.premium_banner_active")
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .stroke(AppColors.success.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    private var languageSection: some View {
        VStack(spacing: 0) {
            settingsButton(icon: "globe", title: "settings.language") {
                showLanguagePicker = true
            }
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .stroke(AppColors.divider, lineWidth: 0.5)
        )
        .padding(.horizontal)
    }

    private var languagePickerSheet: some View {
        NavigationStack {
            List {
                ForEach(LanguageService.supportedIdentifiers, id: \.self) { id in
                    Button {
                        languageService.setLanguage(id)
                        showLanguagePicker = false
                    } label: {
                        let titleKey = id == "en" ? "language.english" : "language.german"
                        HStack {
                            Text(LocalizedStringKey(titleKey))
                            .foregroundStyle(AppColors.textPrimary)
                            Spacer()
                            if languageService.currentLocale.language.languageCode?.identifier == id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppColors.accent)
                            }
                        }
                    }
                    .listRowBackground(AppColors.cardBackground)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.backgroundPrimary)
            .navigationTitle("settings.language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.backgroundSecondary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var categoriesSection: some View {
        VStack(spacing: 0) {
            NavigationLink {
                CategoriesView()
            } label: {
                categoriesRowLabel
            }
            .buttonStyle(.plain)
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .stroke(AppColors.divider, lineWidth: 0.5)
        )
        .padding(.horizontal)
    }

    private var categoriesRowLabel: some View {
        HStack {
            Image(systemName: "folder")
                .foregroundStyle(AppColors.accent)
                .frame(width: 24)
            Text("settings.categories")
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(16)
    }

    private var settingsSection: some View {
        VStack(spacing: 0) {
            settingsRow(icon: "bell", title: "settings.notifications", toggle: $viewModel.notificationsEnabled)
            settingsButton(icon: "arrow.clockwise", title: "settings.restore_purchases", action: {})
            settingsButton(icon: "hand.raised", title: "settings.privacy_policy", action: openPrivacyPolicy)
            settingsButton(icon: "doc.text", title: "settings.terms_of_use", action: openTermsOfUse)
            settingsButton(icon: "questionmark.circle", title: "settings.support", action: openSupport)
            settingsButton(icon: "star", title: "settings.rate_us", action: requestReview)
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .stroke(AppColors.divider, lineWidth: 0.5)
        )
        .padding(.horizontal)
    }

    private func settingsRow(icon: String, title: LocalizedStringKey, toggle: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(AppColors.accent)
                .frame(width: 24)
            Text(title)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Toggle("", isOn: toggle)
                .tint(AppColors.accent)
        }
        .padding(16)
        .listRowBackground(AppColors.backgroundSecondary)
    }

    private func settingsButton(icon: String, title: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 24)
                Text(title)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }

    private func openPrivacyPolicy() {
        if let url = URL(string: AppConstants.URLs.privacyPolicy) {
            UIApplication.shared.open(url)
        }
    }

    private func openTermsOfUse() {
        if let url = URL(string: AppConstants.URLs.termsOfUse) {
            UIApplication.shared.open(url)
        }
    }

    private func openSupport() {
        if let url = URL(string: AppConstants.URLs.support) {
            UIApplication.shared.open(url)
        }
    }

    private func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func shareApp() {
        let url = URL(string: "https://apps.apple.com/app/lasttime")!
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LanguageService())
}
