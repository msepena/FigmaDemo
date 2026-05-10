import Foundation
import Testing
import AppPreferences
import GameDomain
@testable import GameFeature

// MARK: - Test fixtures

/// Plays a fixed queue of moves regardless of board state. Used to make AI
/// behavior deterministic for tests.
final class ScriptedAI: AIOpponent, @unchecked Sendable {
    private var queue: [CellPosition]
    init(_ moves: [CellPosition]) { self.queue = moves }
    func move(for player: Player, in state: GameState) -> CellPosition? {
        guard !queue.isEmpty else { return nil }
        return queue.removeFirst()
    }
}

/// Returns no move — effectively disables the AI. Useful when a test only
/// makes a single human move and never expects an AI response.
struct NoOpAI: AIOpponent {
    func move(for player: Player, in state: GameState) -> CellPosition? { nil }
}

@MainActor
private func makePrefs(firstMove: FirstMove = .x, difficulty: Difficulty = .medium) -> AppPreferences {
    let suite = "GameViewModelTests-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defaults.removePersistentDomain(forName: suite)
    let prefs = AppPreferences(defaults: defaults)
    prefs.firstMove = firstMove
    prefs.difficulty = difficulty
    return prefs
}

@MainActor
private func makeVM(
    firstMove: FirstMove = .x,
    difficulty: Difficulty = .medium,
    aiOverride: (any AIOpponent)? = NoOpAI(),
    state: GameState = GameState()
) -> GameViewModel {
    GameViewModel(
        state: state,
        engine: GameEngine(),
        prefs: makePrefs(firstMove: firstMove, difficulty: difficulty),
        aiMoveDelay: .zero,
        aiOverride: aiOverride
    )
}

// MARK: - Suites

@MainActor
@Suite("GameViewModel")
struct GameViewModelTests {
    @Test func freshViewModelStartsAtRound1() {
        let vm = makeVM()
        #expect(vm.headerEyebrow == "Round 1")
        #expect(vm.turnLetter == "X")
        #expect(vm.turnText == "Your turn")
        #expect(!vm.canUndo)
    }

    @Test func tapCellPlacesMark() {
        let vm = makeVM()
        let pos = CellPosition(row: 0, column: 0)!
        vm.tapCell(at: pos)
        #expect(vm.state.board[pos].player == .x)
        #expect(vm.state.currentPlayer == .o)
        #expect(vm.canUndo)
    }

    @Test func tapOnOccupiedCellIsIgnored() {
        let vm = makeVM()
        let pos = CellPosition(row: 1, column: 1)!
        vm.tapCell(at: pos) // X
        let snapshot = vm.state
        vm.tapCell(at: pos) // ignored — not human's turn
        #expect(vm.state == snapshot)
    }

    @Test func winFreezesBoardAndUpdatesScore() async {
        let scripted = ScriptedAI([
            CellPosition(row: 1, column: 0)!,
            CellPosition(row: 1, column: 1)!,
        ])
        let vm = makeVM(aiOverride: scripted)

        vm.tapCell(at: CellPosition(row: 0, column: 0)!) // X
        await vm.awaitPendingAIMove() // O at (1,0)
        vm.tapCell(at: CellPosition(row: 0, column: 1)!) // X
        await vm.awaitPendingAIMove() // O at (1,1)
        vm.tapCell(at: CellPosition(row: 0, column: 2)!) // X wins
        await vm.awaitPendingAIMove() // no-op: outcome finished

        #expect(vm.state.outcome.isFinished)
        #expect(vm.state.score.xWins == 1)
        #expect(vm.turnText == "Player X wins")

        let frozen = vm.state
        vm.tapCell(at: CellPosition(row: 2, column: 2)!)
        #expect(vm.state == frozen)
    }

    @Test func undoRestoresPreviousState() async {
        let scripted = ScriptedAI([CellPosition(row: 1, column: 1)!])
        let vm = makeVM(aiOverride: scripted)

        vm.tapCell(at: CellPosition(row: 0, column: 0)!) // X
        await vm.awaitPendingAIMove() // O at (1,1)

        vm.undo()
        // Two-move undo: rolls back the AI's move and the human's move that preceded it.
        #expect(vm.state.history.isEmpty)
        #expect(vm.state.currentPlayer == .x)
        #expect(vm.state.board[CellPosition(row: 0, column: 0)!].isEmpty)
        #expect(vm.state.board[CellPosition(row: 1, column: 1)!].isEmpty)
    }

    @Test func newGameAfterWinAdvancesRoundAndPreservesScore() async {
        let scripted = ScriptedAI([
            CellPosition(row: 1, column: 0)!,
            CellPosition(row: 1, column: 1)!,
        ])
        let vm = makeVM(aiOverride: scripted)

        vm.tapCell(at: CellPosition(row: 0, column: 0)!)
        await vm.awaitPendingAIMove()
        vm.tapCell(at: CellPosition(row: 0, column: 1)!)
        await vm.awaitPendingAIMove()
        vm.tapCell(at: CellPosition(row: 0, column: 2)!) // X wins
        await vm.awaitPendingAIMove()
        #expect(vm.state.score.xWins == 1)

        vm.newGame()
        await vm.awaitPendingAIMove() // round 2 starts with O — AI moves first if scripted has more
        #expect(vm.state.roundNumber == 2)
        #expect(vm.state.score.xWins == 1)
        #expect(vm.headerEyebrow == "Round 2")
    }

    @Test func newGameMidRoundClearsBoardKeepsRound() async {
        let vm = makeVM()
        vm.tapCell(at: CellPosition(row: 1, column: 1)!) // X mid-round
        await vm.awaitPendingAIMove()
        vm.newGame()
        await vm.awaitPendingAIMove()
        #expect(vm.state.roundNumber == 1)
        #expect(vm.state.board.isEmpty)
        #expect(vm.state.currentPlayer == .x)
    }

    @Test func resetAllClearsScoreRoundAndBoard() async {
        let scripted = ScriptedAI([
            CellPosition(row: 1, column: 0)!,
            CellPosition(row: 1, column: 1)!,
        ])
        let vm = makeVM(aiOverride: scripted)

        vm.tapCell(at: CellPosition(row: 0, column: 0)!)
        await vm.awaitPendingAIMove()
        vm.tapCell(at: CellPosition(row: 0, column: 1)!)
        await vm.awaitPendingAIMove()
        vm.tapCell(at: CellPosition(row: 0, column: 2)!) // X wins
        await vm.awaitPendingAIMove()
        vm.newGame() // round 2
        await vm.awaitPendingAIMove()
        vm.tapCell(at: CellPosition(row: 2, column: 2)!)
        await vm.awaitPendingAIMove()
        #expect(vm.state.score.xWins == 1)
        #expect(vm.state.roundNumber == 2)

        vm.resetAll()
        await vm.awaitPendingAIMove()

        #expect(vm.state.score.xWins == 0)
        #expect(vm.state.score.oWins == 0)
        #expect(vm.state.score.draws == 0)
        #expect(vm.state.roundNumber == 1)
        #expect(vm.state.board.isEmpty)
        #expect(vm.state.history.isEmpty)
        #expect(vm.state.currentPlayer == .x)
    }
}

@MainActor
@Suite("GameViewModel + AI")
struct GameViewModelAITests {
    @Test func aiMovesFirstWhenFirstMoveIsO() async {
        let scripted = ScriptedAI([CellPosition(row: 1, column: 1)!])
        let vm = makeVM(firstMove: .o, aiOverride: scripted)
        await vm.awaitPendingAIMove()
        #expect(vm.state.history.count == 1)
        #expect(vm.state.history.first?.player == .x) // AI is X when human is O
        #expect(vm.state.board[CellPosition(row: 1, column: 1)!].player == .x)
        #expect(vm.state.currentPlayer == .o)
    }

    @Test func tapCellIgnoredOnAITurn() async {
        // Human is X. After human plays, it's AI's turn. NoOpAI never moves,
        // so the board stays in "AI to move" state — and a tap should be ignored.
        let vm = makeVM(aiOverride: NoOpAI())
        vm.tapCell(at: CellPosition(row: 0, column: 0)!) // X
        await vm.awaitPendingAIMove()
        let snapshot = vm.state
        vm.tapCell(at: CellPosition(row: 2, column: 2)!) // would-be human attempt during AI turn
        #expect(vm.state == snapshot)
    }

    @Test func aiDoesNotMoveAfterHumanWins() async {
        // Pre-stage the board so X wins on the next move.
        var board = Board()
        board = board.placing(.x, at: CellPosition(row: 0, column: 0)!)!
        board = board.placing(.x, at: CellPosition(row: 0, column: 1)!)!
        board = board.placing(.o, at: CellPosition(row: 1, column: 0)!)!
        board = board.placing(.o, at: CellPosition(row: 1, column: 1)!)!
        let starting = GameState(
            board: board,
            currentPlayer: .x,
            history: [
                Move(player: .x, position: CellPosition(row: 0, column: 0)!),
                Move(player: .o, position: CellPosition(row: 1, column: 0)!),
                Move(player: .x, position: CellPosition(row: 0, column: 1)!),
                Move(player: .o, position: CellPosition(row: 1, column: 1)!),
            ]
        )
        let scripted = ScriptedAI([CellPosition(row: 2, column: 2)!])
        let vm = makeVM(aiOverride: scripted, state: starting)

        vm.tapCell(at: CellPosition(row: 0, column: 2)!) // X wins
        await vm.awaitPendingAIMove()

        #expect(vm.state.outcome.isFinished)
        #expect(vm.state.board[CellPosition(row: 2, column: 2)!].isEmpty)
        #expect(vm.state.history.count == 5) // no AI move appended
    }

    @Test func hardDifficultyBlocksImmediateWin() async {
        // Real AI factory (no override) must engage the difficulty enum.
        // Stage: X has two in a row; AI (O) on Hard must block.
        var board = Board()
        board = board.placing(.x, at: CellPosition(row: 0, column: 0)!)!
        board = board.placing(.x, at: CellPosition(row: 0, column: 1)!)!
        board = board.placing(.o, at: CellPosition(row: 1, column: 0)!)!
        let starting = GameState(
            board: board,
            currentPlayer: .x,
            history: [
                Move(player: .x, position: CellPosition(row: 0, column: 0)!),
                Move(player: .o, position: CellPosition(row: 1, column: 0)!),
                Move(player: .x, position: CellPosition(row: 0, column: 1)!),
            ]
        )
        let prefs = makePrefs(firstMove: .x, difficulty: .hard)
        let vm = GameViewModel(
            state: starting,
            engine: GameEngine(),
            prefs: prefs,
            aiMoveDelay: .zero
        )
        // Human plays an arbitrary non-winning move that doesn't immediately end the game,
        // so the AI's next move should block X's existing two-in-a-row at (0,2).
        vm.tapCell(at: CellPosition(row: 2, column: 2)!)
        await vm.awaitPendingAIMove()

        #expect(vm.state.board[CellPosition(row: 0, column: 2)!].player == .o)
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
