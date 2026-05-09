import Testing
import GameDomain
@testable import GameFeature

@MainActor
@Suite("GameViewModel")
struct GameViewModelTests {
    @Test func freshViewModelStartsAtRound1() {
        let vm = GameViewModel()
        #expect(vm.headerEyebrow == "Round 1")
        #expect(vm.turnLetter == "X")
        #expect(vm.turnText == "Your turn")
        #expect(!vm.canUndo)
    }

    @Test func tapCellPlacesMark() {
        let vm = GameViewModel()
        let pos = CellPosition(row: 0, column: 0)!
        vm.tapCell(at: pos)
        #expect(vm.state.board[pos].player == .x)
        #expect(vm.state.currentPlayer == .o)
        #expect(vm.canUndo)
    }

    @Test func tapOnOccupiedCellIsIgnored() {
        let vm = GameViewModel()
        let pos = CellPosition(row: 1, column: 1)!
        vm.tapCell(at: pos) // X
        let snapshot = vm.state
        vm.tapCell(at: pos) // would be O — must be ignored
        #expect(vm.state == snapshot)
    }

    @Test func winFreezesBoardAndUpdatesScore() {
        let vm = GameViewModel()
        // X plays the top row to win
        vm.tapCell(at: CellPosition(row: 0, column: 0)!)
        vm.tapCell(at: CellPosition(row: 1, column: 0)!) // O
        vm.tapCell(at: CellPosition(row: 0, column: 1)!)
        vm.tapCell(at: CellPosition(row: 1, column: 1)!) // O
        vm.tapCell(at: CellPosition(row: 0, column: 2)!) // X wins

        #expect(vm.state.outcome.isFinished)
        #expect(vm.state.score.xWins == 1)
        #expect(vm.turnText == "Player X wins")

        // Tapping more cells must not change anything.
        let frozen = vm.state
        vm.tapCell(at: CellPosition(row: 2, column: 2)!)
        #expect(vm.state == frozen)
    }

    @Test func undoRestoresPreviousState() {
        let vm = GameViewModel()
        vm.tapCell(at: CellPosition(row: 0, column: 0)!)
        vm.tapCell(at: CellPosition(row: 1, column: 1)!)

        vm.undo()
        #expect(vm.state.history.count == 1)
        #expect(vm.state.currentPlayer == .o)
        #expect(vm.state.board[CellPosition(row: 1, column: 1)!].isEmpty)
    }

    @Test func newGameAfterWinAdvancesRoundAndPreservesScore() {
        let vm = GameViewModel()
        // X wins round 1
        vm.tapCell(at: CellPosition(row: 0, column: 0)!)
        vm.tapCell(at: CellPosition(row: 1, column: 0)!)
        vm.tapCell(at: CellPosition(row: 0, column: 1)!)
        vm.tapCell(at: CellPosition(row: 1, column: 1)!)
        vm.tapCell(at: CellPosition(row: 0, column: 2)!)
        #expect(vm.state.score.xWins == 1)

        vm.newGame()
        #expect(vm.state.roundNumber == 2)
        #expect(vm.state.score.xWins == 1)
        #expect(vm.state.board.isEmpty)
        #expect(vm.headerEyebrow == "Round 2")
    }

    @Test func newGameMidRoundClearsBoardKeepsRound() {
        let vm = GameViewModel()
        vm.tapCell(at: CellPosition(row: 1, column: 1)!) // X mid-round
        vm.newGame()
        #expect(vm.state.roundNumber == 1)
        #expect(vm.state.board.isEmpty)
        #expect(vm.state.currentPlayer == .x)
    }
}

@MainActor
@Suite("GameScreen mappings")
struct GameMappingTests {
    @Test func emptyCellMapsToEmpty() {
        let state = GameState()
        let pos = CellPosition(row: 0, column: 0)!
        #expect(cellVisualState(for: state, at: pos) == .empty)
    }

    @Test func xOnWinningLineMapsToWinningVariant() {
        let engine = GameEngine()
        var state = GameState()
        state = engine.makeMove(at: CellPosition(row: 0, column: 0)!, in: state)!
        state = engine.makeMove(at: CellPosition(row: 1, column: 0)!, in: state)!
        state = engine.makeMove(at: CellPosition(row: 0, column: 1)!, in: state)!
        state = engine.makeMove(at: CellPosition(row: 1, column: 1)!, in: state)!
        state = engine.makeMove(at: CellPosition(row: 0, column: 2)!, in: state)! // X wins top row

        #expect(cellVisualState(for: state, at: CellPosition(row: 0, column: 0)!) == .xWinning)
        #expect(cellVisualState(for: state, at: CellPosition(row: 0, column: 2)!) == .xWinning)
        #expect(cellVisualState(for: state, at: CellPosition(row: 1, column: 0)!) == .o)
    }

    @Test func eyebrowReflectsRoundNumber() {
        let state = GameState(roundNumber: 7)
        #expect(eyebrowText(for: state) == "Round 7")
    }
}
