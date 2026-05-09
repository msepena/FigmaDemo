import SwiftUI
import AppPreferences

#Preview("Default") {
    SettingsScreen(
        viewModel: SettingsViewModel(prefs: AppPreferences(), onResetStats: {}),
        onBack: {}
    )
}

#Preview("Mutated") {
    let prefs = AppPreferences()
    prefs.difficulty = .hard
    prefs.firstMove = .random
    prefs.accentColor = .green
    prefs.soundEnabled = false
    return SettingsScreen(
        viewModel: SettingsViewModel(prefs: prefs, onResetStats: {}),
        onBack: {}
    )
}
