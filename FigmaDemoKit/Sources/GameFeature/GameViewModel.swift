import Foundation
import Observation
import SwiftUI
import GameDomain
import UIComponents

@Observable
@MainActor
public final class GameViewModel {
    public private(set) var state: GameState
    private let engine: GameEngine

    public init(state: GameState = GameState(), engine: GameEngine = GameEngine()) {
        self.state = state
        self.engine = engine
    }

    // MARK: - Derived UI props

    public var headerEyebrow: String { eyebrowText(for: state) }

    public var scoreColumnsForUI: [ScoreColumn] { scoreColumns(for: state.score) }

    public var turnLetter: String  { turnIndicator(for: state).letter }
    public var turnTint:   Color   { turnIndicator(for: state).tint }
    public var turnText:   String  { turnIndicator(for: state).text }

    public var canUndo: Bool { !state.history.isEmpty }

    public func cellState(at position: CellPosition) -> CellVisualState {
        cellVisualState(for: state, at: position)
    }

    // MARK: - Actions

    public func tapCell(at position: CellPosition) {
        if let next = engine.makeMove(at: position, in: state) {
            state = next
        }
    }

    public func newGame() {
        if state.outcome.isFinished {
            // Round was complete; preserve cumulative score and bump round counter.
            state = engine.newRound(from: state)
        } else {
            // Round is still in progress — clear the board and keep score/round.
            state = GameState(
                board: Board(),
                currentPlayer: .x,
                outcome: .ongoing,
                score: state.score,
                roundNumber: state.roundNumber,
                history: []
            )
        }
    }

    public func undo() {
        if let undone = engine.undo(in: state) {
            state = undone
        }
    }

    /// Resets cumulative score, round counter, board, and history. Used by
    /// the Settings screen's "Reset Stats" action via an app-level callback.
    public func resetAll() {
        state = GameState()
    }
}
