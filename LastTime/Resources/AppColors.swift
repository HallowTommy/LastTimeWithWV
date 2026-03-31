import SwiftUI

enum AppColors {
    static func color(hex: String) -> Color {
        Color(hex: hex)
    }

    static let backgroundPrimary = Color(hex: "0a0e17")
    static let backgroundSecondary = Color(hex: "152238")
    static let cardBackground = Color(hex: "1a2332").opacity(0.85)
    static let textPrimary = Color(hex: "e8ecf0")
    static let textSecondary = Color(hex: "8b9aab")
    static let accent = Color(hex: "5b8fb9")
    static let accentMuted = Color(hex: "3d5a73")
    static let divider = Color(hex: "2a3544")
    static let danger = Color(hex: "b8595b")
    static let success = Color(hex: "5b9b6d")
    static let warning = Color(hex: "c9a227")
}

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
