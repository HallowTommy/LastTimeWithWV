import SwiftUI

struct ProgressChartView: View {
    let data: [ProgressViewModel.ChartDataPoint]
    private let maxBarHeight: CGFloat = 80

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("progress.chart_title")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            if data.isEmpty {
                Text("progress.no_data")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: maxBarHeight)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(data) { point in
                        VStack(spacing: 6) {
                            Spacer(minLength: 0)
                            barView(for: point)
                            Text(point.dayLabel)
                                .font(.caption2)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: maxBarHeight + 24)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .stroke(AppColors.divider, lineWidth: 0.5)
        )
    }

    private func barView(for point: ProgressViewModel.ChartDataPoint) -> some View {
        let maxCount = max(data.map(\.count).max() ?? 1, 1)
        let heightRatio = CGFloat(point.count) / CGFloat(maxCount)
        let barHeight = max(heightRatio * maxBarHeight, point.count > 0 ? 6 : 0)

        return RoundedRectangle(cornerRadius: 4)
            .fill(
                LinearGradient(
                    colors: [AppColors.accent, AppColors.accentMuted],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(height: barHeight)
            .frame(maxHeight: maxBarHeight, alignment: .bottom)
    }
}

#Preview {
    ProgressChartView(data: [
        ProgressViewModel.ChartDataPoint(dayLabel: "Пн", count: 2),
        ProgressViewModel.ChartDataPoint(dayLabel: "Вт", count: 5),
        ProgressViewModel.ChartDataPoint(dayLabel: "Ср", count: 1),
        ProgressViewModel.ChartDataPoint(dayLabel: "Чт", count: 3),
        ProgressViewModel.ChartDataPoint(dayLabel: "Пт", count: 0),
        ProgressViewModel.ChartDataPoint(dayLabel: "Сб", count: 4),
        ProgressViewModel.ChartDataPoint(dayLabel: "Нд", count: 2)
    ])
    .padding()
    .background(AppColors.backgroundPrimary)
}
