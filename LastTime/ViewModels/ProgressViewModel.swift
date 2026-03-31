import Combine
import Foundation

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published var activitiesCount: Int = 0
    @Published var recordsThisWeek: Int = 0
    @Published var recordsThisMonth: Int = 0
    @Published var chartData: [ChartDataPoint] = []
    @Published var achievements: [Achievement] = []

    struct ChartDataPoint: Identifiable {
        let id: UUID
        let dayLabel: String
        let count: Int

        init(dayLabel: String, count: Int, id: UUID = UUID()) {
            self.id = id
            self.dayLabel = dayLabel
            self.count = count
        }
    }

    struct Achievement: Identifiable {
        let id = UUID()
        let localizationKey: String
        let icon: String
        let isUnlocked: Bool
    }

    private let storage: StorageServiceProtocol

    init(storage: StorageServiceProtocol = StorageService()) {
        self.storage = storage
    }

    func loadStats(locale: Locale = Locale(identifier: "en")) {
        let activities = storage.loadActivities()
        let records = storage.loadRecords()

        activitiesCount = activities.count

        let now = Date()
        let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
        let monthStart = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now

        recordsThisWeek = records.filter { $0.date >= weekStart }.count
        recordsThisMonth = records.filter { $0.date >= monthStart }.count

        let calendar = Calendar.current
        var chartPoints: [ChartDataPoint] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        dateFormatter.locale = locale
        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            let count = records.filter { $0.date >= dayStart && $0.date < dayEnd }.count
            chartPoints.append(ChartDataPoint(
                dayLabel: dateFormatter.string(from: date),
                count: count
            ))
        }
        chartData = chartPoints

        achievements = [
            Achievement(
                localizationKey: "achievement.first_action",
                icon: "star",
                isUnlocked: activitiesCount >= 1
            ),
            Achievement(
                localizationKey: "achievement.10_records",
                icon: "checkmark.circle",
                isUnlocked: records.count >= 10
            ),
            Achievement(
                localizationKey: "achievement.7_day_streak",
                icon: "flame",
                isUnlocked: hasSevenDaysStreak(records: records)
            )
        ]
    }

    private func hasSevenDaysStreak(records: [ActivityRecord]) -> Bool {
        let sortedDates = Set(records.map { Calendar.current.startOfDay(for: $0.date) }).sorted(by: >)
        guard !sortedDates.isEmpty else { return false }
        var streak = 0
        var current = Calendar.current.startOfDay(for: Date())
        for date in sortedDates {
            if date == current {
                streak += 1
                current = Calendar.current.date(byAdding: .day, value: -1, to: current) ?? current
                if streak >= 7 { return true }
            } else if date < current {
                break
            }
        }
        return false
    }
}
