import SwiftUI

public enum DSColor {
    /// #F2F2F7 — screen background
    public static let bg = Color(hex: 0xF2F2F7)
    /// #FFFFFF — card surface
    public static let cardBackground = Color.white
    /// #1C1C1E — primary label
    public static let label = Color(hex: 0x1C1C1E)
    /// #8E8E93 — secondary label
    public static let secondary = Color(hex: 0x8E8E93)
    /// #007AFF — Player X / accent
    public static let playerXBlue = Color(hex: 0x007AFF)
    /// #FF9500 — Player O
    public static let playerOOrange = Color(hex: 0xFF9500)
    /// #D8D8DC — divider/grid line
    public static let gridLine = Color(hex: 0xD8D8DC)
    /// 12% blue tint for winning X cells
    public static let winHighlightBlue = Color(hex: 0x007AFF).opacity(0.12)
    /// 12% orange tint for winning O cells
    public static let winHighlightOrange = Color(hex: 0xFF9500).opacity(0.12)
    /// 12% blue tint for the turn indicator pill
    public static let turnPillTint = Color(hex: 0x007AFF).opacity(0.12)
    /// Soft empty-cell background (matches screen bg so cells "cut out" of the white card)
    public static let emptyCell = Color(hex: 0xF2F2F7)
}

extension Color {
    /// Construct a Color from a 24-bit RGB hex literal.
    public init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
