public struct GameEngine: Sendable {
    public init() {}

    /// Apply `player`'s move at `position`. Returns a new state, or `nil` if the move is illegal
    /// (cell occupied, wrong player's turn, or game already finished).
    public func makeMove(at position: CellPosition, in state: GameState) -> GameState? {
        guard !state.outcome.isFinished else { return nil }
        guard let nextBoard = state.board.placing(state.currentPlayer, at: position) else {
            return nil
        }

        var newState = state
        newState.board = nextBoard
        newState.history.append(Move(player: state.currentPlayer, position: position))

        if let win = nextBoard.winner() {
            newState.outcome = .win(win.player, win.line)
            switch win.player {
            case .x: newState.score.xWins += 1
            case .o: newState.score.oWins += 1
            }
        } else if nextBoard.isFull {
            newState.outcome = .draw
            newState.score.draws += 1
        } else {
            newState.outcome = .ongoing
            newState.currentPlayer = state.currentPlayer.opponent
        }

        return newState
    }

    /// Undo the most recent move. Returns `nil` if there is nothing to undo. The score is
    /// preserved when the round is still ongoing, but a finished round whose result has already
    /// been counted is rolled back along with the last move.
    public func undo(in state: GameState) -> GameState? {
        guard let lastMove = state.history.last else { return nil }
        var newState = state
        newState.history.removeLast()

        // Roll back the score adjustment if the previous move ended the round.
        if state.outcome.isFinished {
            switch state.outcome {
            case .win(let player, _):
                switch player {
                case .x: newState.score.xWins -= 1
                case .o: newState.score.oWins -= 1
                }
            case .draw:
                newState.score.draws -= 1
            case .ongoing:
                break
            }
        }

        // Rebuild the board from the trimmed history rather than mutating in place.
        var rebuilt = Board()
        for move in newState.history {
            rebuilt = rebuilt.placing(move.player, at: move.position) ?? rebuilt
        }
        newState.board = rebuilt
        newState.outcome = .ongoing
        newState.currentPlayer = lastMove.player
        return newState
    }

    /// Start a new round, preserving cumulative score and incrementing the round counter.
    /// The starting player alternates: X starts round 1, O starts round 2, X starts round 3, etc.
    public func newRound(from state: GameState) -> GameState {
        let nextRound = state.roundNumber + 1
        let starter: Player = nextRound.isMultiple(of: 2) ? .o : .x
        return GameState(
            board: Board(),
            currentPlayer: starter,
            outcome: .ongoing,
            score: state.score,
            roundNumber: nextRound,
            history: []
        )
    }

    /// Reset everything — board, score, history, round counter.
    public func resetAll() -> GameState {
        GameState()
    }
}
