import Testing
import Foundation
@testable import AppPreferences

@MainActor
@Suite("AppPreferences")
struct AppPreferencesTests {
    @Test func defaultsMatchFigmaComp() {
        let prefs = AppPreferences()
        #expect(prefs.difficulty == .medium)
        #expect(prefs.firstMove == .x)
        #expect(prefs.theme == .system)
        #expect(prefs.accentColor == .blue)
        #expect(prefs.markerStyle == .rounded)
        #expect(prefs.soundEnabled)
        #expect(prefs.hapticsEnabled)
    }

    @Test func mutationsPersist() {
        let suite = makeSuite()
        let prefs = AppPreferences(defaults: suite)
        prefs.difficulty = .hard
        prefs.firstMove = .random
        prefs.theme = .dark
        prefs.accentColor = .orange
        prefs.soundEnabled = false
        prefs.hapticsEnabled = false

        #expect(prefs.difficulty == .hard)
        #expect(prefs.firstMove == .random)
        #expect(prefs.theme == .dark)
        #expect(prefs.accentColor == .orange)
        #expect(!prefs.soundEnabled)
        #expect(!prefs.hapticsEnabled)
    }

    @Test func persistsAcrossInstances() {
        let suite = makeSuite()

        do {
            let prefs = AppPreferences(defaults: suite)
            prefs.difficulty = .hard
            prefs.firstMove = .random
            prefs.theme = .dark
            prefs.accentColor = .pink
            prefs.soundEnabled = false
            prefs.hapticsEnabled = false
        }

        let reloaded = AppPreferences(defaults: suite)
        #expect(reloaded.difficulty == .hard)
        #expect(reloaded.firstMove == .random)
        #expect(reloaded.theme == .dark)
        #expect(reloaded.accentColor == .pink)
        #expect(!reloaded.soundEnabled)
        #expect(!reloaded.hapticsEnabled)
    }
}

@MainActor
private func makeSuite() -> UserDefaults {
    let name = "AppPreferencesTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defaults.removePersistentDomain(forName: name)
    return defaults
}

@Suite("Preference enum encoding")
struct PreferenceEnumCodableTests {
    @Test func difficultyRoundTrips() throws {
        try assertCodableRoundTrip(Difficulty.allCases)
    }

    @Test func firstMoveRoundTrips() throws {
        try assertCodableRoundTrip(FirstMove.allCases)
    }

    @Test func themeRoundTrips() throws {
        try assertCodableRoundTrip(Theme.allCases)
    }

    @Test func accentColorRoundTrips() throws {
        try assertCodableRoundTrip(AccentColor.allCases)
    }

    @Test func markerStyleRoundTrips() throws {
        try assertCodableRoundTrip(MarkerStyle.allCases)
    }

    @Test func accentHexValuesAreDistinct() {
        let hexes = Set(AccentColor.allCases.map(\.hex))
        #expect(hexes.count == AccentColor.allCases.count)
    }
}

private func assertCodableRoundTrip<T: Codable & Equatable>(_ values: [T]) throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    for value in values {
        let data = try encoder.encode(value)
        let decoded = try decoder.decode(T.self, from: data)
        #expect(decoded == value)
    }
}
