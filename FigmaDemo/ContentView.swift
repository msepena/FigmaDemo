import SwiftUI
import AppPreferences
import DesignSystem
import GameFeature
import SettingsFeature
import UIComponents

struct ContentView: View {
    @State private var prefs: AppPreferences
    @State private var gameVM: GameViewModel
    @State private var path = NavigationPath()
    @State private var splashVisible: Bool

    init() {
        let prefs = AppPreferences()
        _prefs = State(initialValue: prefs)
        _gameVM = State(initialValue: GameViewModel(prefs: prefs))
        // UI tests pass `-DisableSplash` so the animated reveal doesn't block
        // first-tap assertions or distort the launch-perf metric.
        let splashDisabled = ProcessInfo.processInfo.arguments.contains("-DisableSplash")
        _splashVisible = State(initialValue: !splashDisabled)
    }

    var body: some View {
        ZStack {
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

            if splashVisible {
                BrandSplashView { splashVisible = false }
                    .preferredColorScheme(prefs.theme.preferredColorScheme)
                    .transition(.opacity)
            }
        }
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
