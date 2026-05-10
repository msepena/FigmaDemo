import Foundation
import Observation
import AppPreferences
import GameDomain
import UIComponents

@Observable
@MainActor
public final class GameViewModel {
    public private(set) var state: GameState

    @ObservationIgnored
    private let engine: GameEngine
    @ObservationIgnored
    private let prefs: AppPreferences
    @ObservationIgnored
    private let aiMoveDelay: Duration
    @ObservationIgnored
    private let aiOverride: (any AIOpponent)?
    @ObservationIgnored
    private var humanSide: Player
    @ObservationIgnored
    private var pendingAITask: Task<Void, Never>?

    public init(
        state: GameState = GameState(),
        engine: GameEngine = GameEngine(),
        prefs: AppPreferences,
        aiMoveDelay: Duration = .milliseconds(350),
        aiOverride: (any AIOpponent)? = nil
    ) {
        self.state = state
        self.engine = engine
        self.prefs = prefs
        self.aiMoveDelay = aiMoveDelay
        self.aiOverride = aiOverride
        self.humanSide = Self.resolveHumanSide(from: prefs.firstMove)
        if state.currentPlayer == humanSide.opponent, !state.outcome.isFinished {
            scheduleAIMove()
        }
    }

    // MARK: - Derived UI props

    public var headerEyebrow: String { eyebrowText(for: state) }

    public var turnLetter: String { turnIndicatorText(for: state).letter }
    public var turnText: String   { turnIndicatorText(for: state).text }

    public var canUndo: Bool { !state.history.isEmpty }

    public func cellState(at position: CellPosition) -> CellVisualState {
        cellVisualState(for: state, at: position)
    }

    // MARK: - Actions

    public func tapCell(at position: CellPosition) {
        guard !state.outcome.isFinished else { return }
        guard state.currentPlayer == humanSide else { return }
        guard let next = engine.makeMove(at: position, in: state) else { return }
        state = next
        if state.currentPlayer == humanSide.opponent, !state.outcome.isFinished {
            scheduleAIMove()
        }
    }

    public func newGame() {
        pendingAITask?.cancel()
        humanSide = Self.resolveHumanSide(from: prefs.firstMove)

        if state.outcome.isFinished {
            state = engine.newRound(from: state)
        } else {
            let starter: Player = state.roundNumber.isMultiple(of: 2) ? .o : .x
            state = GameState(
                board: Board(),
                currentPlayer: starter,
                outcome: .ongoing,
                score: state.score,
                roundNumber: state.roundNumber,
                history: []
            )
        }

        if state.currentPlayer == humanSide.opponent, !state.outcome.isFinished {
            scheduleAIMove()
        }
    }

    public func undo() {
        pendingAITask?.cancel()
        guard let last = state.history.last else { return }

        if last.player == humanSide.opponent {
            // Roll back AI's move and the human move that preceded it.
            if let undone = engine.undo(in: state) {
                state = undone
                if let undoneAgain = engine.undo(in: state) {
                    state = undoneAgain
                }
            }
        } else if let undone = engine.undo(in: state) {
            state = undone
        }
    }

    /// Resets cumulative score, round counter, board, and history. Used by
    /// the Settings screen's "Reset Stats" action via an app-level callback.
    public func resetAll() {
        pendingAITask?.cancel()
        humanSide = Self.resolveHumanSide(from: prefs.firstMove)
        state = GameState()
        if state.currentPlayer == humanSide.opponent {
            scheduleAIMove()
        }
    }

    // MARK: - Test hook

    /// Awaits the in-flight AI move task, if any. Tests inject `aiMoveDelay = .zero`
    /// and call this to deterministically await the AI's response.
    func awaitPendingAIMove() async {
        await pendingAITask?.value
    }

    // MARK: - AI move scheduling

    private func scheduleAIMove() {
        pendingAITask?.cancel()
        let aiSide = humanSide.opponent
        let delay = aiMoveDelay
        pendingAITask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: delay)
            guard let self else { return }
            guard !Task.isCancelled else { return }
            guard !self.state.outcome.isFinished,
                  self.state.currentPlayer == aiSide else { return }
            let strategy = self.aiOverride ?? AIOpponentFactory.make(for: self.prefs.difficulty)
            guard let move = strategy.move(for: aiSide, in: self.state),
                  let next = self.engine.makeMove(at: move, in: self.state) else { return }
            self.state = next
        }
    }

    private static func resolveHumanSide(from firstMove: FirstMove) -> Player {
        switch firstMove {
        case .x: return .x
        case .o: return .o
        case .random: return Bool.random() ? .x : .o
        }
    }
}
