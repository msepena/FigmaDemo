import SwiftUI
import AppPreferences
import DesignSystem
import GameFeature
import SettingsFeature

struct ContentView: View {
    @State private var prefs = AppPreferences()
    @State private var gameVM = GameViewModel()
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            GameScreen(
                viewModel: gameVM,
                onSettingsTap: { path.append(SettingsRoute.settings) }
            )
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: SettingsRoute.self) { _ in
                SettingsScreen(
                    viewModel: SettingsViewModel(
                        prefs: prefs,
                        onResetStats: { gameVM.resetAll() }
                    ),
                    onBack: { path.removeLast() }
                )
                .toolbar(.hidden, for: .navigationBar)
            }
        }
        .dsAccentColor(prefs.accentColor.color)
        .preferredColorScheme(prefs.theme.preferredColorScheme)
    }
}

private enum SettingsRoute: Hashable { case settings }

private extension Theme {
    var preferredColorScheme: ColorScheme? {
        switch self {
        case .light:  return .light
        case .dark:   return .dark
        case .system: return nil
        }
    }
}

#Preview {
    ContentView()
}
