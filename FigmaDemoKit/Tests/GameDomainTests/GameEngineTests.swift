import Testing
@testable import GameDomain

@Suite("GameEngine")
struct GameEngineTests {
    private let engine = GameEngine()

    @Test func freshStateStartsAsX() {
        let state = GameState()
        #expect(state.currentPlayer == .x)
        #expect(state.outcome == .ongoing)
        #expect(state.score.totalRounds == 0)
        #expect(state.roundNumber == 1)
    }

    @Test func makeMoveAlternatesPlayer() {
        let state = GameState()
        let after1 = engine.makeMove(at: CellPosition(row: 0, column: 0)!, in: state)!
        #expect(after1.currentPlayer == .o)
        let after2 = engine.makeMove(at: CellPosition(row: 1, column: 1)!, in: after1)!
        #expect(after2.currentPlayer == .x)
    }

    @Test func makeMoveOnOccupiedCellRejected() {
        let state = engine.makeMove(at: CellPosition(row: 0, column: 0)!, in: GameState())!
        #expect(engine.makeMove(at: CellPosition(row: 0, column: 0)!, in: state) == nil)
    }

    @Test func winningMoveUpdatesOutcomeAndScore() {
        var state = GameState()
        // X plays the top row
        state = engine.makeMove(at: CellPosition(row: 0, column: 0)!, in: state)!
        state = engine.makeMove(at: CellPosition(row: 1, column: 0)!, in: state)! // O
        state = engine.makeMove(at: CellPosition(row: 0, column: 1)!, in: state)!
        state = engine.makeMove(at: CellPosition(row: 1, column: 1)!, in: state)! // O
        state = engine.makeMove(at: CellPosition(row: 0, column: 2)!, in: state)! // X wins

        #expect(state.outcome.isFinished)
        if case let .win(player, _) = state.outcome {
            #expect(player == .x)
        } else {
            Issue.record("Expected a win, got \(state.outcome)")
        }
        #expect(state.score.xWins == 1)
        #expect(state.score.oWins == 0)
    }

    @Test func movesAfterWinAreRejected() {
        var state = GameState()
        state = engine.makeMove(at: CellPosition(row: 0, column: 0)!, in: state)!
        state = engine.makeMove(at: CellPosition(row: 1, column: 0)!, in: state)!
        state = engine.makeMove(at: CellPosition(row: 0, column: 1)!, in: state)!
        state = engine.makeMove(at: CellPosition(row: 1, column: 1)!, in: state)!
        state = engine.makeMove(at: CellPosition(row: 0, column: 2)!, in: state)! // X wins

        let attempt = engine.makeMove(at: CellPosition(row: 2, column: 2)!, in: state)
        #expect(attempt == nil)
    }

    @Test func drawDetected() {
        // X O X / X O O / O X X — a non-winning full board
        let plays: [(Player, Int, Int)] = [
            (.x, 0, 0), (.o, 0, 1), (.x, 0, 2),
            (.o, 1, 1), (.x, 1, 0), (.o, 1, 2),
            (.x, 2, 1), (.o, 2, 0), (.x, 2, 2),
        ]
        var state = GameState()
        for play in plays {
            // skip player check: engine uses currentPlayer; force the prescribed sequence
            state = engine.makeMove(at: CellPosition(row: play.1, column: play.2)!, in: state)!
        }
        #expect(state.outcome == .draw)
        #expect(state.score.draws == 1)
    }

    @Test func undoRestoresPreviousMove() {
        var state = GameState()
        state = engine.makeMove(at: CellPosition(row: 0, column: 0)!, in: state)!
        state = engine.makeMove(at: CellPosition(row: 1, column: 1)!, in: state)!

        let undone = engine.undo(in: state)!
        #expect(undone.history.count == 1)
        #expect(undone.board[CellPosition(row: 1, column: 1)!].isEmpty)
        #expect(undone.currentPlayer == .o)
    }

    @Test func undoOnEmptyHistoryIsNil() {
        #expect(engine.undo(in: GameState()) == nil)
    }

    @Test func undoRollsBackWinScore() {
        var state = GameState()
        state = engine.makeMove(at: CellPosition(row: 0, column: 0)!, in: state)!
        state = engine.makeMove(at: CellPosition(row: 1, column: 0)!, in: state)!
        state = engine.makeMove(at: CellPosition(row: 0, column: 1)!, in: state)!
        state = engine.makeMove(at: CellPosition(row: 1, column: 1)!, in: state)!
        state = engine.makeMove(at: CellPosition(row: 0, column: 2)!, in: state)!
        #expect(state.score.xWins == 1)

        let undone = engine.undo(in: state)!
        #expect(undone.score.xWins == 0)
        #expect(undone.outcome == .ongoing)
    }

    @Test func newRoundPreservesScoreAndUsesProvidedStarter() {
        var state = GameState(score: Score(xWins: 2, oWins: 1, draws: 0))
        state.roundNumber = 3
        let next = engine.newRound(from: state, starter: .o)
        #expect(next.score.xWins == 2)
        #expect(next.score.oWins == 1)
        #expect(next.roundNumber == 4)
        #expect(next.currentPlayer == .o)
        #expect(next.history.isEmpty)
        #expect(next.outcome == .ongoing)
    }

    @Test func newRoundHonorsXStarter() {
        let state = GameState(roundNumber: 2)
        let next = engine.newRound(from: state, starter: .x)
        #expect(next.currentPlayer == .x)
        #expect(next.roundNumber == 3)
    }

    @Test func resetClearsEverything() {
        let state = GameState(
            score: Score(xWins: 5, oWins: 3, draws: 1),
            roundNumber: 9
        )
        let reset = engine.resetAll()
        #expect(reset.score.totalRounds == 0)
        #expect(reset.roundNumber == 1)
        #expect(reset.currentPlayer == .x)
        #expect(reset.board.isEmpty)
        // sanity: the original is unchanged (value type)
        #expect(state.roundNumber == 9)
    }
}
