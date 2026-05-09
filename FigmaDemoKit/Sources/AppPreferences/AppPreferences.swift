import Foundation
import Observation

@Observable
@MainActor
public final class AppPreferences {
    public var difficulty: Difficulty = .medium
    public var firstMove: FirstMove = .x
    public var theme: Theme = .system
    public var accentColor: AccentColor = .blue
    public var markerStyle: MarkerStyle = .rounded
    public var soundEnabled: Bool = true
    public var hapticsEnabled: Bool = true

    public init() {}
}
