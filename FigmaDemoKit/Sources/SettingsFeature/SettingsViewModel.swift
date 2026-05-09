import Foundation
import Observation
import AppPreferences

/// Bridges ``AppPreferences`` (pure data) with the actions ``SettingsScreen``
/// needs to invoke on the rest of the app — currently just "reset stats",
/// injected by the app layer so this module never has to import GameFeature.
@Observable
@MainActor
public final class SettingsViewModel {
    public let prefs: AppPreferences
    private let onResetStats: () -> Void

    public init(prefs: AppPreferences, onResetStats: @escaping () -> Void) {
        self.prefs = prefs
        self.onResetStats = onResetStats
    }

    public func resetStats() {
        onResetStats()
    }
}
