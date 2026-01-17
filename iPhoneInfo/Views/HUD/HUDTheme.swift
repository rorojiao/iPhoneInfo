import SwiftUI

enum HUDTheme {
    // Design tokens derived from the provided ROG mockups
    static let backgroundTop = Color(hex: 0x121212)
    static let backgroundBottom = Color(hex: 0x0E0E10)

    static let rogRed = Color(hex: 0xFF3333)
    static let rogRedDeep = Color(hex: 0xCC2222)
    static let rogCyan = Color(hex: 0x00CCFF)

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.72)

    static let panelFill = Color.white.opacity(0.04)
    static let panelFillStrong = Color.white.opacity(0.06)
    static let panelStroke = Color.white.opacity(0.10)

    static let borderSoft = rogRed.opacity(0.55)
    static let borderStrong = rogRed.opacity(0.85)

    static let glowSoft = rogRed.opacity(0.25)
    static let glowStrong = rogRed.opacity(0.45)
    static let cyanGlow = rogCyan.opacity(0.35)

    static let cornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 10
    static let borderWidth: CGFloat = 2

    static let primaryButtonHeight: CGFloat = 48
    static let secondaryButtonHeight: CGFloat = 40
    static let iconTileSize: CGFloat = 62

    // Backward-compatible aliases for existing views
    static let neonRed = rogRed
    static let neonCyan = rogCyan
    static let neonGreen = Color(hex: 0x39F28C)
    static let neonMagenta = rogRed
    static let neonOrange = Color(hex: 0xFF7A33)
}

private extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
