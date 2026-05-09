import SwiftUI
import GameDomain
import DesignSystem
import UIComponents

extension Player {
    /// Display tint used for X/O glyphs and accents.
    var displayColor: Color {
        switch self {
        case .x: return DSColor.playerXBlue
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

/// Build the three score columns for the scoreboard from a `Score`.
public func scoreColumns(for score: Score) -> [ScoreColumn] {
    [
        .init(label: "Player X", value: "\(score.xWins)", valueColor: DSColor.playerXBlue),
        .init(label: "Draws",    value: "\(score.draws)", valueColor: DSColor.label),
        .init(label: "Player O", value: "\(score.oWins)", valueColor: DSColor.playerOOrange),
    ]
}

/// Eyebrow text shown above the screen title — e.g. "ROUND 9".
public func eyebrowText(for state: GameState) -> String {
    "Round \(state.roundNumber)"
}

/// Tint and text for the turn indicator pill, taking into account terminal outcomes.
public func turnIndicator(for state: GameState) -> (letter: String, tint: Color, text: String) {
    switch state.outcome {
    case .ongoing:
        return (state.currentPlayer.glyph, state.currentPlayer.displayColor, "Your turn")
    case .win(let player, _):
        return (player.glyph, player.displayColor, "Player \(player.glyph) wins")
    case .draw:
        return ("=", DSColor.label, "It's a draw")
    }
}
