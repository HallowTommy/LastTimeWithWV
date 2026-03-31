import Foundation

enum ReminderType: Codable, Identifiable, Equatable {
    case oneDay
    case threeDays
    case oneWeek
    case twoWeeks
    case oneMonth
    case threeMonths
    case sixMonths
    case custom(days: Int)

    static var presetCases: [ReminderType] {
        [.oneDay, .threeDays, .oneWeek, .twoWeeks, .oneMonth, .threeMonths, .sixMonths]
    }

    var id: String {
        switch self {
        case .oneDay: return "1d"
        case .threeDays: return "3d"
        case .oneWeek: return "1w"
        case .twoWeeks: return "2w"
        case .oneMonth: return "1m"
        case .threeMonths: return "3m"
        case .sixMonths: return "6m"
        case .custom(let days): return "custom_\(days)"
        }
    }

    func displayName(locale: Locale = .current) -> String {
        let key: String
        switch self {
        case .oneDay: key = "reminder.1day"
        case .threeDays: key = "reminder.3days"
        case .oneWeek: key = "reminder.1week"
        case .twoWeeks: key = "reminder.2weeks"
        case .oneMonth: key = "reminder.1month"
        case .threeMonths: key = "reminder.3months"
        case .sixMonths: key = "reminder.6months"
        case .custom(let days): return String(localized: String.LocalizationValue("reminder.custom_days"), locale: locale).replacingOccurrences(of: "%d", with: "\(days)")
        }
        return String(localized: String.LocalizationValue(key), locale: locale)
    }

    var timeInterval: TimeInterval {
        switch self {
        case .oneDay: return 86400
        case .threeDays: return 86400 * 3
        case .oneWeek: return 86400 * 7
        case .twoWeeks: return 86400 * 14
        case .oneMonth: return 86400 * 30
        case .threeMonths: return 86400 * 90
        case .sixMonths: return 86400 * 180
        case .custom(let days): return TimeInterval(days) * 86400
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        if raw.hasPrefix("custom_"), let days = Int(raw.dropFirst(7)), days > 0 {
            self = .custom(days: min(days, 365))
            return
        }
        switch raw {
        case "1d": self = .oneDay
        case "3d": self = .threeDays
        case "1w": self = .oneWeek
        case "2w": self = .twoWeeks
        case "1m": self = .oneMonth
        case "3m": self = .threeMonths
        case "6m": self = .sixMonths
        default: self = .oneWeek
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .oneDay: try container.encode("1d")
        case .threeDays: try container.encode("3d")
        case .oneWeek: try container.encode("1w")
        case .twoWeeks: try container.encode("2w")
        case .oneMonth: try container.encode("1m")
        case .threeMonths: try container.encode("3m")
        case .sixMonths: try container.encode("6m")
        case .custom(let days): try container.encode("custom_\(days)")
        }
    }
}
