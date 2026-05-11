import AppKit

// Mirrors the hex values in FigmaDemoKit/Sources/DesignSystem/DSColor.swift.
// Update both files together when the in-app palette changes.
enum Palette {
    static let bgLight       = NSColor(hex: 0xF2F2F7)
    static let bgDark        = NSColor(hex: 0x000000)
    static let cardLight     = NSColor(hex: 0xFFFFFF)
    static let cardDark      = NSColor(hex: 0x1C1C1E)
    static let gridLineLight = NSColor(hex: 0xD8D8DC)
    static let gridLineDark  = NSColor(hex: 0x3A3A3C)
    static let playerXBlue   = NSColor(hex: 0x007AFF)
    static let playerOOrange = NSColor(hex: 0xFF9500)
}

extension NSColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >>  8) & 0xFF) / 255
        let b = CGFloat( hex        & 0xFF) / 255
        self.init(srgbRed: r, green: g, blue: b, alpha: alpha)
    }
}
