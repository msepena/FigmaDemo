import Testing
import Foundation
import AppPreferences
import GameDomain
@testable import GameFeature

@MainActor
@Suite("GameViewModel")
struct GameViewModelTests {
    @Test func freshViewModelStartsAtRound1() {
        let vm = GameViewModel(prefs: makePrefs())
        #expect(vm.headerEyebrow == "Round 1")
        #expect(vm.turnLetter == "X")
        #expect(vm.turnText == "Your turn")
        #expect(!vm.canUndo)
    }

    @Test func tapCellPlacesMark() {
        let vm = GameViewModel(prefs: makePrefs())
        let pos = CellPosition(row: 0, column: 0)!
        vm.tapCell(at: pos)
        #expect(vm.state.board[pos].player == .x)
        #expect(vm.state.currentPlayer == .o)
        #expect(vm.canUndo)
    }

    @Test func tapOnOccupiedCellIsIgnored() {
        let vm = GameViewModel(prefs: makePrefs())
        let pos = CellPosition(row: 1, column: 1)!
        vm.tapCell(at: pos) // X
        let snapshot = vm.state
        vm.tapCell(at: pos) // would be O — must be ignored
        #expect(vm.state == snapshot)
    }

    @Test func winFreezesBoardAndUpdatesScore() {
        let vm = GameViewModel(prefs: makePrefs())
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
        let vm = GameViewModel(prefs: makePrefs())
        vm.tapCell(at: CellPosition(row: 0, column: 0)!)
        vm.tapCell(at: CellPosition(row: 1, column: 1)!)

        vm.undo()
        #expect(vm.state.history.count == 1)
        #expect(vm.state.currentPlayer == .o)
        #expect(vm.state.board[CellPosition(row: 1, column: 1)!].isEmpty)
    }

    @Test func newGameAfterWinAdvancesRoundAndPreservesScore() {
        let vm = GameViewModel(prefs: makePrefs())
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
        let vm = GameViewModel(prefs: makePrefs())
        vm.tapCell(at: CellPosition(row: 1, column: 1)!) // X mid-round
        vm.newGame()
        #expect(vm.state.roundNumber == 1)
        #expect(vm.state.board.isEmpty)
        #expect(vm.state.currentPlayer == .x)
    }

    @Test func resetAllClearsScoreRoundAndBoard() {
        let vm = GameViewModel(prefs: makePrefs())
        // X wins round 1, then start round 2 with one move on the board.
        vm.tapCell(at: CellPosition(row: 0, column: 0)!)
        vm.tapCell(at: CellPosition(row: 1, column: 0)!)
        vm.tapCell(at: CellPosition(row: 0, column: 1)!)
        vm.tapCell(at: CellPosition(row: 1, column: 1)!)
        vm.tapCell(at: CellPosition(row: 0, column: 2)!) // X wins
        vm.newGame() // round 2
        vm.tapCell(at: CellPosition(row: 2, column: 2)!)
        #expect(vm.state.score.xWins == 1)
        #expect(vm.state.roundNumber == 2)

        vm.resetAll()

        #expect(vm.state.score.xWins == 0)
        #expect(vm.state.score.oWins == 0)
        #expect(vm.state.score.draws == 0)
        #expect(vm.state.roundNumber == 1)
        #expect(vm.state.board.isEmpty)
        #expect(vm.state.history.isEmpty)
        #expect(vm.state.currentPlayer == .x)
    }

    // MARK: - First Move preference

    @Test func firstMoveOIsHonoredOnFreshViewModel() {
        let prefs = makePrefs()
        prefs.firstMove = .o
        let vm = GameViewModel(prefs: prefs)
        #expect(vm.state.currentPlayer == .o)
        #expect(vm.turnLetter == "O")
    }

    @Test func firstMoveOIsHonoredOnNewRoundAfterWin() {
        let prefs = makePrefs()
        prefs.firstMove = .o
        let vm = GameViewModel(prefs: prefs)
        // O wins the top row (since O starts).
        vm.tapCell(at: CellPosition(row: 0, column: 0)!) // O
        vm.tapCell(at: CellPosition(row: 1, column: 0)!) // X
        vm.tapCell(at: CellPosition(row: 0, column: 1)!) // O
        vm.tapCell(at: CellPosition(row: 1, column: 1)!) // X
        vm.tapCell(at: CellPosition(row: 0, column: 2)!) // O wins
        #expect(vm.state.outcome.isFinished)

        vm.newGame()
        #expect(vm.state.roundNumber == 2)
        #expect(vm.state.currentPlayer == .o) // override, not alternation
    }

    @Test func firstMoveOIsHonoredOnMidRoundNewGame() {
        let prefs = makePrefs()
        prefs.firstMove = .o
        let vm = GameViewModel(prefs: prefs)
        vm.tapCell(at: CellPosition(row: 1, column: 1)!) // O places mid-round
        vm.newGame() // mid-round reset
        #expect(vm.state.roundNumber == 1)
        #expect(vm.state.currentPlayer == .o)
    }

    @Test func firstMoveChangeAppliesOnlyToNextNewGame() {
        let prefs = makePrefs()
        prefs.firstMove = .x
        let vm = GameViewModel(prefs: prefs)
        // Place X on the board.
        let pos = CellPosition(row: 0, column: 0)!
        vm.tapCell(at: pos)
        #expect(vm.state.board[pos].player == .x)

        // Change preference mid-round — current state must not be disturbed.
        prefs.firstMove = .o
        #expect(vm.state.board[pos].player == .x)
        #expect(vm.state.currentPlayer == .o) // it's O's turn (X just moved)

        // Next New Game picks up the new preference.
        vm.newGame()
        #expect(vm.state.board.isEmpty)
        #expect(vm.state.currentPlayer == .o)
    }

    @Test func resetAllHonorsFirstMovePreference() {
        let prefs = makePrefs()
        prefs.firstMove = .o
        let vm = GameViewModel(prefs: prefs)
        vm.tapCell(at: CellPosition(row: 0, column: 0)!)
        vm.resetAll()
        #expect(vm.state.currentPlayer == .o)
        #expect(vm.state.board.isEmpty)
    }

    @Test func randomFirstMoveResolvesToXOrO() {
        let prefs = makePrefs()
        prefs.firstMove = .random
        // Build many fresh VMs and assert every starter is .x or .o (never anything else).
        for _ in 0..<50 {
            let vm = GameViewModel(prefs: prefs)
            let starter = vm.state.currentPlayer
            #expect(starter == .x || starter == .o)
        }
    }
}

@MainActor
private func makePrefs() -> AppPreferences {
    let name = "GameViewModelTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defaults.removePersistentDomain(forName: name)
    return AppPreferences(defaults: defaults)
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
