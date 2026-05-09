public enum AccentColor: String, Sendable, Hashable, CaseIterable, Codable {
    case blue
    case purple
    case pink
    case orange
    case green

    /// Raw 24-bit RGB hex for each accent. Kept as data on the model so the UI
    /// layer (which depends on SwiftUI) can map this to a `Color` without
    /// `AppPreferences` having to import SwiftUI itself.
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
