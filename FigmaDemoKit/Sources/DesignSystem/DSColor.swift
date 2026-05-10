import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public enum DSColor {
    /// Screen background. Light: #F2F2F7 / Dark: #000000.
    public static let bg = Color.adaptive(light: 0xF2F2F7, dark: 0x000000)
    /// Card surface. Light: #FFFFFF / Dark: #1C1C1E.
    public static let cardBackground = Color.adaptive(light: 0xFFFFFF, dark: 0x1C1C1E)
    /// Primary label. Light: #1C1C1E / Dark: #FFFFFF.
    public static let label = Color.adaptive(light: 0x1C1C1E, dark: 0xFFFFFF)
    /// Secondary label. Light: #8E8E93 / Dark: #98989D.
    public static let secondary = Color.adaptive(light: 0x8E8E93, dark: 0x98989D)
    /// Divider / grid hairline. Light: #D8D8DC / Dark: #3A3A3C.
    public static let gridLine = Color.adaptive(light: 0xD8D8DC, dark: 0x3A3A3C)
    /// Empty-cell background — sits inside `cardBackground` with enough contrast to
    /// read as a distinct tile. Light: #E5E5EA / Dark: #2C2C2E.
    public static let emptyCell = Color.adaptive(light: 0xE5E5EA, dark: 0x2C2C2E)
    /// Inverse of `label` — used for text that sits on top of a `label`-colored fill
    /// (e.g. the "New Game" pill button). Light: #FFFFFF / Dark: #000000.
    public static let invertedLabel = Color.adaptive(light: 0xFFFFFF, dark: 0x000000)

    // MARK: - Brand / overlay (do NOT adapt)

    /// #007AFF — default accent. Runtime accent comes from `\.dsAccentColor` in
    /// the SwiftUI environment; this constant is the fallback when no accent has
    /// been injected (default value for the environment key, plus previews).
    public static let playerXBlue = Color(hex: 0x007AFF)
    /// #FF9500 — Player O (fixed; not driven by the user-selected accent).
    public static let playerOOrange = Color(hex: 0xFF9500)
    /// 12% orange tint for winning O cells.
    public static let winHighlightOrange = Color(hex: 0xFF9500).opacity(0.12)
    /// #FF3B30 — destructive action label (Reset Stats)
    public static let destructive = Color(hex: 0xFF3B30)
}

extension Color {
    /// Construct a Color from a 24-bit RGB hex literal.
    public init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }

    /// Returns a SwiftUI `Color` that resolves to `light` in light appearance and
    /// `dark` in dark appearance. Falls back to `light` on platforms without
    /// UIKit (e.g. the macOS host that runs `swift test`).
    public static func adaptive(light: UInt32, dark: UInt32) -> Color {
        #if canImport(UIKit)
        return Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(rgb: dark)
                : UIColor(rgb: light)
        })
        #else
        return Color(hex: light)
        #endif
    }
}

#if canImport(UIKit)
extension UIColor {
    fileprivate convenience init(rgb: UInt32, alpha: CGFloat = 1.0) {
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
#endif
