public enum AccentColor: String, Sendable, Hashable, CaseIterable, Codable {
    case blue
    case purple
    case pink
    case orange
    case green

    /// Raw 24-bit RGB hex for each accent. The SwiftUI bridge lives in
    /// `AccentColor+Color.swift` (sibling file) — keeping the hex as plain data
    /// here means `AppPreferences` consumers that don't render UI (tests,
    /// future macOS targets) don't pull in SwiftUI.
    public var hex: UInt32 {
        switch self {
        case .blue:   return 0x007AFF
        case .purple: return 0xAF52DE
        case .pink:   return 0xFF2D55
        case .orange: return 0xFF9500
        case .green:  return 0x34C759
        }
    }
}
