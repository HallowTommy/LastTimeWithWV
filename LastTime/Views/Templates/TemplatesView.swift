import SwiftUI

struct TemplatesView: View {
    @StateObject private var viewModel = TemplatesViewModel()
    @Environment(\.locale) private var locale
    var onTemplateAdded: (() -> Void)? = nil

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.backgroundPrimary, AppColors.backgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.templateKeys, id: \.self) { key in
                        TemplateCardView(
                            title: String(localized: String.LocalizationValue(key), locale: locale),
                            isAdded: viewModel.isTemplateAdded(key: key, locale: locale)
                        ) {
                            let localizedTitle = String(localized: String.LocalizationValue(key), locale: locale)
                            let added = viewModel.addTemplate(title: localizedTitle)
                            if added {
                                onTemplateAdded?()
                            } else {
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.warning)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("templates.navigation_title")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    TemplatesView()
        .environmentObject(LanguageService())
}
