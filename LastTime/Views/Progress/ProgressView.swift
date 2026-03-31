import SwiftUI

struct ProgressStatsView: View {
    @StateObject private var viewModel = ProgressViewModel()
    @Environment(\.locale) private var locale

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
                    statsSection
                    ProgressChartView(data: viewModel.chartData)
                    achievementsSection
                }
                .padding()
            }
        }
        .navigationTitle("progress.navigation_title")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadStats(locale: locale)
        }
        .onChange(of: locale) { _, newLocale in
            viewModel.loadStats(locale: newLocale)
        }
    }

    private var statsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(title: "progress.stat_activities", value: "\(viewModel.activitiesCount)")
                StatCard(title: "progress.stat_this_week", value: "\(viewModel.recordsThisWeek)")
                StatCard(title: "progress.stat_this_month", value: "\(viewModel.recordsThisMonth)")
            }
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("progress.achievements")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            ForEach(viewModel.achievements) { achievement in
                HStack(spacing: 12) {
                    Image(systemName: achievement.icon)
                        .foregroundStyle(achievement.isUnlocked ? AppColors.accent : AppColors.textSecondary)
                    Text(LocalizedStringKey(achievement.localizationKey))
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    if achievement.isUnlocked {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColors.accent)
                    }
                }
                .padding(12)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                        .stroke(AppColors.divider, lineWidth: 0.5)
                )
            }
        }
    }
}

private struct StatCard: View {
    let title: LocalizedStringKey
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(AppColors.textPrimary)
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .stroke(AppColors.divider, lineWidth: 0.5)
        )
    }
}

#Preview {
    ProgressStatsView()
        .environmentObject(LanguageService())
}
