import Testing
import AppPreferences
@testable import SettingsFeature

@MainActor
@Suite("SettingsViewModel")
struct SettingsViewModelTests {
    @Test func resetStatsInvokesInjectedClosure() {
        var resetCount = 0
        let vm = SettingsViewModel(
            prefs: AppPreferences(),
            onResetStats: { resetCount += 1 }
        )

        vm.resetStats()
        vm.resetStats()

        #expect(resetCount == 2)
    }

    @Test func mutatingPrefsThroughViewModelIsObservable() {
        let prefs = AppPreferences()
        let vm = SettingsViewModel(prefs: prefs, onResetStats: {})

        vm.prefs.difficulty = .hard
        vm.prefs.theme = .dark

        #expect(prefs.difficulty == .hard)
        #expect(prefs.theme == .dark)
        #expect(vm.prefs.difficulty == .hard)
    }
}

@MainActor
@Suite("Settings label mappings")
struct SettingsMappingTests {
    @Test func difficultyLabelsMatchFigmaCopy() {
        #expect(difficultyLabel(.easy)   == "Easy")
        #expect(difficultyLabel(.medium) == "Medium")
        #expect(difficultyLabel(.hard)   == "Hard")
    }

    @Test func firstMoveLabelsMatchFigmaCopy() {
        #expect(firstMoveLabel(.x)      == "X")
        #expect(firstMoveLabel(.o)      == "O")
        #expect(firstMoveLabel(.random) == "Random")
    }

    @Test func themeLabelsMatchFigmaCopy() {
        #expect(themeLabel(.light)  == "Light")
        #expect(themeLabel(.dark)   == "Dark")
        #expect(themeLabel(.system) == "System")
    }

    @Test func segmentedOptionArraysAreFullyEnumerated() {
        #expect(difficultyOptions.count == Difficulty.allCases.count)
        #expect(firstMoveOptions.count  == FirstMove.allCases.count)
        #expect(themeOptions.count      == Theme.allCases.count)
    }
}
