import SwiftUI

/// Terminal/Coding theme design system
enum TerminalTheme {
    // MARK: - Colors

    // Base palette (aligned to VISUAL_MOCKUP.md)
    static let background = Color(hex: "0F172A")          // deep ink
    static let surface = Color(hex: "1E1E2E")             // card fill
    static let accent = Color(hex: "00FF88")              // terminal green
    static let sessionGreen = Color(hex: "50FA7B")        // bright green
    static let weeklyGreen = Color(hex: "8BE9FD")         // cyan
    static let amber = Color(hex: "FFB86C")
    static let error = Color(hex: "FF5555")
    static let textPrimary = Color(hex: "F8F8F2")
    static let textSecondary = Color(hex: "A6B3C4")       // softer muted
    static let border = Color(hex: "44475A")
    static let glassHighlight = Color.white.opacity(0.12)
    static let glassShadow = Color.black.opacity(0.25)

    // MARK: - Typography

    static let monoFont = Font.system(.body, design: .monospaced)
    static let monoFontBold = Font.system(.body, design: .monospaced).weight(.semibold)
    static let monoFontSmall = Font.system(.caption, design: .monospaced)
    static let monoFontTiny = Font.system(.caption2, design: .monospaced)

    // MARK: - Gradients

    static let sessionGradient = LinearGradient(
        colors: [sessionGreen, sessionGreen.opacity(0.7)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let weeklyGradient = LinearGradient(
        colors: [weeklyGreen, weeklyGreen.opacity(0.7)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let glassOverlay = LinearGradient(
        colors: [
            Color.white.opacity(0.25),
            Color.white.opacity(0.05)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let errorGradient = LinearGradient(
        colors: [error, error.opacity(0.8)],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Helper Functions

    static func barGradient(for percent: Double) -> LinearGradient {
        if percent < 20 {
            return errorGradient
        } else if percent < 40 {
            return LinearGradient(
                colors: [amber, amber.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return sessionGradient
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
