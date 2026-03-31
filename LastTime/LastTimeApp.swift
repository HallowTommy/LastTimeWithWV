import SwiftUI
import UIKit

@main
struct LastTimeApp: App {
    @StateObject private var languageService = LanguageService()
    @StateObject private var premiumService = PremiumService()
    @StateObject private var webViewGateService = WebViewGateService()
    @State private var isLaunchComplete = false
    @State private var showWebViewGate = false

    init() {
        configureNavigationBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLaunchComplete {
                    MainTabView()
                        .environmentObject(languageService)
                        .environmentObject(premiumService)
                        .transition(.opacity)
                        .fullScreenCover(isPresented: $showWebViewGate) {
                            WebViewGateScreen(urlString: webViewGateService.targetURL)
                        }
                } else {
                    LoadingView()
                        .transition(.opacity)
                }
            }
            .environment(\.locale, languageService.currentLocale)
            .id(languageService.currentLocale.identifier)
            .animation(.easeInOut(duration: 0.4), value: isLaunchComplete)
            .task {
                async let remoteCheck: Void = webViewGateService.checkRemote()
                try? await Task.sleep(for: .seconds(2.5))
                await remoteCheck
                isLaunchComplete = true
                if webViewGateService.shouldShowWebView {
                    // Present after MainTabView is in the hierarchy
                    DispatchQueue.main.async {
                        showWebViewGate = true
                    }
                }
            }
        }
    }

    private func configureNavigationBarAppearance() {
        let titleColor = UIColor(AppColors.textPrimary)
        let navBar = UINavigationBar.appearance()
        navBar.tintColor = UIColor(AppColors.accent)

        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = UIColor(AppColors.backgroundPrimary)
        standardAppearance.titleTextAttributes = [.foregroundColor: titleColor]
        standardAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor]
        navBar.standardAppearance = standardAppearance
        navBar.compactAppearance = standardAppearance

        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithTransparentBackground()
        scrollEdgeAppearance.backgroundColor = .clear
        scrollEdgeAppearance.titleTextAttributes = [.foregroundColor: titleColor]
        scrollEdgeAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor]
        navBar.scrollEdgeAppearance = scrollEdgeAppearance
    }
}
