import SwiftUI

private struct DSAccentColorKey: EnvironmentKey {
    static let defaultValue: Color = DSColor.playerXBlue
}

public extension EnvironmentValues {
    /// The currently active accent color, threaded from `AppPreferences.accentColor`.
    /// Default is the same blue used by Player X so unstyled previews and snapshots
    /// keep their pre-existing appearance.
    var dsAccentColor: Color {
        get { self[DSAccentColorKey.self] }
        set { self[DSAccentColorKey.self] = newValue }
    }
}

public extension View {
    /// Sets `\.dsAccentColor` and `\.tint` in lockstep so both custom views (which
    /// read `\.dsAccentColor`) and built-in SwiftUI controls (which follow `.tint`)
    /// pick up the same color.
    func dsAccentColor(_ color: Color) -> some View {
        environment(\.dsAccentColor, color).tint(color)
    }
}
