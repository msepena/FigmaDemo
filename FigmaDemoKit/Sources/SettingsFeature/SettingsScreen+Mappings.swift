import SwiftUI
import AppPreferences
import DesignSystem
import UIComponents

// MARK: - Trailing summary labels (right-aligned text next to a row title)

func difficultyLabel(_ value: Difficulty) -> String {
    switch value {
    case .easy:   return "Easy"
    case .medium: return "Medium"
    case .hard:   return "Hard"
    }
}

func firstMoveLabel(_ value: FirstMove) -> String {
    switch value {
    case .x:      return "X"
    case .o:      return "O"
    case .random: return "Random"
    }
}

func themeLabel(_ value: Theme) -> String {
    switch value {
    case .light:  return "Light"
    case .dark:   return "Dark"
    case .system: return "System"
    }
}

func accentColorLabel(_ value: AccentColor) -> String {
    switch value {
    case .blue:   return "Blue"
    case .purple: return "Purple"
    case .pink:   return "Pink"
    case .orange: return "Orange"
    case .green:  return "Green"
    }
}

func markerStyleLabel(_ value: MarkerStyle) -> String {
    switch value {
    case .rounded: return "Rounded"
    }
}

// MARK: - Segmented-picker option arrays

let difficultyOptions: [(value: Difficulty, label: String)] = Difficulty.allCases.map { ($0, difficultyLabel($0)) }
let firstMoveOptions:  [(value: FirstMove,  label: String)] = FirstMove.allCases.map  { ($0, firstMoveLabel($0)) }
let themeOptions:      [(value: Theme,      label: String)] = Theme.allCases.map      { ($0, themeLabel($0)) }

// MARK: - Accent swatch mapping

let accentSwatchOptions: [(value: AccentColor, color: Color)] = AccentColor.allCases.map {
    ($0, Color(hex: $0.hex))
}
