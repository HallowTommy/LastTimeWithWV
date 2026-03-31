import Foundation

extension Date {
    func timeAgoDisplay(locale: Locale = .current) -> String {
        let loc = locale
        let interval = Date().timeIntervalSince(self)

        if interval < 60 {
            return String(localized: String.LocalizationValue("date.just_now"), locale: loc)
        } else if interval < 3600 {
            let mins = Int(interval / 60)
            return mins == 1
                ? String(localized: String.LocalizationValue("date.minute_ago"), locale: loc)
                : String(localized: String.LocalizationValue("date.minutes_ago"), locale: loc).replacingOccurrences(of: "%d", with: "\(mins)")
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return formatTimeAgo(value: hours, oneKey: "date.hour", fewKey: "date.hours_few", manyKey: "date.hours_many", locale: loc)
        } else if interval < 86400 * 7 {
            let days = Int(interval / 86400)
            return formatTimeAgo(value: days, oneKey: "date.day", fewKey: "date.days_few", manyKey: "date.days_many", locale: loc)
        } else if interval < 86400 * 30 {
            let weeks = Int(interval / (86400 * 7))
            return formatTimeAgo(value: weeks, oneKey: "date.week", fewKey: "date.weeks_few", manyKey: "date.weeks_many", locale: loc)
        } else if interval < 86400 * 365 {
            let months = Int(interval / (86400 * 30))
            return formatTimeAgo(value: months, oneKey: "date.month", fewKey: "date.months_few", manyKey: "date.months_many", locale: loc)
        } else {
            let years = Int(interval / (86400 * 365))
            return formatTimeAgo(value: years, oneKey: "date.year", fewKey: "date.years_few", manyKey: "date.years_many", locale: loc)
        }
    }

    private func formatTimeAgo(value: Int, oneKey: String, fewKey: String, manyKey: String, locale: Locale) -> String {
        let key: String
        if value == 1 {
            key = oneKey
        } else if value >= 2, value <= 4 {
            key = fewKey
        } else {
            key = manyKey
        }
        let form = String(localized: String.LocalizationValue(key), locale: locale)
        let format = String(localized: String.LocalizationValue("date.ago"), locale: locale)
        return format.replacingOccurrences(of: "%d", with: "\(value)").replacingOccurrences(of: "%@", with: form)
    }

    func formattedHistory(locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = locale
        return formatter.string(from: self)
    }
}
