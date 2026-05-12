import Foundation
import Observation

@Observable
@MainActor
public final class AppPreferences {
    public var difficulty: Difficulty {
        didSet { defaults.set(difficulty.rawValue, forKey: Keys.difficulty) }
    }
    public var firstMove: FirstMove {
        didSet { defaults.set(firstMove.rawValue, forKey: Keys.firstMove) }
    }
    public var theme: Theme {
        didSet { defaults.set(theme.rawValue, forKey: Keys.theme) }
    }
    public var accentColor: AccentColor {
        didSet { defaults.set(accentColor.rawValue, forKey: Keys.accentColor) }
    }
    public var markerStyle: MarkerStyle {
        didSet { defaults.set(markerStyle.rawValue, forKey: Keys.markerStyle) }
    }

    @ObservationIgnored
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.difficulty = Self.read(defaults, Keys.difficulty, fallback: .medium)
        self.firstMove = Self.read(defaults, Keys.firstMove, fallback: .x)
        self.theme = Self.read(defaults, Keys.theme, fallback: .system)
        self.accentColor = Self.read(defaults, Keys.accentColor, fallback: .blue)
        self.markerStyle = Self.read(defaults, Keys.markerStyle, fallback: .rounded)
    }

    private static func read<T: RawRepresentable>(
        _ defaults: UserDefaults,
        _ key: String,
        fallback: T
    ) -> T where T.RawValue == String {
        guard let raw = defaults.string(forKey: key), let value = T(rawValue: raw) else {
            return fallback
        }
        return value
    }

    private enum Keys {
        static let difficulty    = "AppPreferences.difficulty"
        static let firstMove     = "AppPreferences.firstMove"
        static let theme         = "AppPreferences.theme"
        static let accentColor   = "AppPreferences.accentColor"
        static let markerStyle   = "AppPreferences.markerStyle"
    }
}
