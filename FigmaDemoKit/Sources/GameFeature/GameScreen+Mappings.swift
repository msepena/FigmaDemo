import SwiftUI
import GameDomain
import DesignSystem
import UIComponents

extension Player {
    /// Display tint used for X/O glyphs and accents. Player X follows the user's
    /// chosen `accent`; Player O is fixed.
    func displayColor(accent: Color) -> Color {
        switch self {
        case .x: return accent
        case .o: return DSColor.playerOOrange
        }
    }

    /// Single-character glyph rendered in the cell.
    var glyph: String {
        switch self {
        case .x: return "X"
        case .o: return "O"
        }
    }
}

/// Map a `(GameState, position)` pair to the UI-only `CellVisualState`.
/// Highlight cells on the winning line when the round is over.
public func cellVisualState(for state: GameState, at position: CellPosition) -> CellVisualState {
    let mark = state.board[position]
    let isOnWinningLine = state.outcome.winningLine?.positions.contains(position) ?? false

    switch mark {
    case .empty:
        return .empty
    case .occupied(.x):
        return isOnWinningLine ? .xWinning : .x
    case .occupied(.o):
        return isOnWinningLine ? .oWinning : .o
    }
}

/// Build the three score columns for the scoreboard from a `Score`. Player X's
/// column follows the active accent; Player O stays orange.
public func scoreColumns(for score: Score, accent: Color) -> [ScoreColumn] {
    [
        .init(label: "Player X", value: "\(score.xWins)", valueColor: accent),
        .init(label: "Draws",    value: "\(score.draws)", valueColor: DSColor.label),
        .init(label: "Player O", value: "\(score.oWins)", valueColor: DSColor.playerOOrange),
    ]
}

/// Eyebrow text shown above the screen title — e.g. "ROUND 9".
public func eyebrowText(for state: GameState) -> String {
    "Round \(state.roundNumber)"
}

/// Letter + text for the turn indicator pill, taking into account terminal outcomes.
/// The tint is *not* computed here because it depends on the active accent — the
/// View resolves that via `\.dsAccentColor` and combines with this result.
public func turnIndicatorText(for state: GameState) -> (letter: String, text: String) {
    switch state.outcome {
    case .ongoing:
        return (state.currentPlayer.glyph, "Your turn")
    case .win(let player, _):
        return (player.glyph, "Player \(player.glyph) wins")
    case .draw:
        return ("=", "It's a draw")
    }
}

/// Tint for the turn indicator pill — accent for X (or X-win), orange for O,
/// neutral label color for a draw.
public func turnIndicatorTint(for state: GameState, accent: Color) -> Color {
    switch state.outcome {
    case .ongoing:        return state.currentPlayer.displayColor(accent: accent)
    case .win(let p, _):  return p.displayColor(accent: accent)
    case .draw:           return DSColor.label
    }
}
