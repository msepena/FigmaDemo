import Testing
@testable import GameDomain

@Suite("RandomAI")
struct RandomAITests {
    @Test func returnsLegalMoveOnNonFullBoard() {
        let ai = RandomAI()
        let state = GameState()
        let move = ai.move(for: .x, in: state)
        #expect(move != nil)
        #expect(state.board[move!].isEmpty)
    }

    @Test func returnsNilOnFullBoard() {
        let ai = RandomAI()
        var board = Board()
        // Fill every cell with X (.empty -> .occupied(.x)).
        for position in CellPosition.allPositions {
            board = board.placing(.x, at: position)!
        }
        let state = GameState(board: board)
        #expect(ai.move(for: .o, in: state) == nil)
    }
}

@Suite("BlockOrWinAI")
struct BlockOrWinAITests {
    private let ai = BlockOrWinAI()

    @Test func takesImmediateWin() {
        // O has two in a row at (1,0)(1,1); cell (1,2) wins for O.
        var board = Board()
        board = board.placing(.o, at: CellPosition(row: 1, column: 0)!)!
        board = board.placing(.o, at: CellPosition(row: 1, column: 1)!)!
        board = board.placing(.x, at: CellPosition(row: 0, column: 0)!)!
        board = board.placing(.x, at: CellPosition(row: 0, column: 1)!)!
        let state = GameState(board: board, currentPlayer: .o)
        #expect(ai.move(for: .o, in: state) == CellPosition(row: 1, column: 2)!)
    }

    @Test func blocksOpponentImmediateWin() {
        // X has two in a row across the top; O must block at (0,2).
        var board = Board()
        board = board.placing(.x, at: CellPosition(row: 0, column: 0)!)!
        board = board.placing(.x, at: CellPosition(row: 0, column: 1)!)!
        board = board.placing(.o, at: CellPosition(row: 1, column: 0)!)!
        let state = GameState(board: board, currentPlayer: .o)
        #expect(ai.move(for: .o, in: state) == CellPosition(row: 0, column: 2)!)
    }

    @Test func prefersWinOverBlock() {
        // O can win at (1,2); X also threatens at (0,2). AI should take the win.
        var board = Board()
        board = board.placing(.x, at: CellPosition(row: 0, column: 0)!)!
        board = board.placing(.x, at: CellPosition(row: 0, column: 1)!)!
        board = board.placing(.o, at: CellPosition(row: 1, column: 0)!)!
        board = board.placing(.o, at: CellPosition(row: 1, column: 1)!)!
        let state = GameState(board: board, currentPlayer: .o)
        #expect(ai.move(for: .o, in: state) == CellPosition(row: 1, column: 2)!)
    }
}

@Suite("ForkAwareAI")
struct ForkAwareAITests {
    private let ai = ForkAwareAI()

    @Test func playsCenterOnEmptyBoard() {
        let state = GameState()
        #expect(ai.move(for: .x, in: state) == CellPosition(row: 1, column: 1)!)
    }

    @Test func takesImmediateWin() {
        var board = Board()
        board = board.placing(.x, at: CellPosition(row: 0, column: 0)!)!
        board = board.placing(.x, at: CellPosition(row: 0, column: 1)!)!
        board = board.placing(.o, at: CellPosition(row: 1, column: 0)!)!
        let state = GameState(board: board, currentPlayer: .x)
        #expect(ai.move(for: .x, in: state) == CellPosition(row: 0, column: 2)!)
    }

    @Test func blocksOpponentImmediateWin() {
        var board = Board()
        board = board.placing(.x, at: CellPosition(row: 0, column: 0)!)!
        board = board.placing(.x, at: CellPosition(row: 0, column: 1)!)!
        board = board.placing(.o, at: CellPosition(row: 1, column: 0)!)!
        let state = GameState(board: board, currentPlayer: .o)
        #expect(ai.move(for: .o, in: state) == CellPosition(row: 0, column: 2)!)
    }

    @Test func takesForkWhenAvailable() {
        // Setup: X at (0,0) and (1,1); O at (0,2).
        // X playing (2,0) creates two threats (column 0 and the anti-diagonal).
        var board = Board()
        board = board.placing(.x, at: CellPosition(row: 0, column: 0)!)!
        board = board.placing(.o, at: CellPosition(row: 0, column: 2)!)!
        board = board.placing(.x, at: CellPosition(row: 1, column: 1)!)!
        let state = GameState(board: board, currentPlayer: .x)

        let move = ai.move(for: .x, in: state)
        #expect(move != nil)

        // After playing the fork move, X must have at least 2 winning continuations.
        let after = board.placing(.x, at: move!)!
        let threats = CellPosition.allPositions.filter { pos in
            guard after[pos].isEmpty,
                  let n = after.placing(.x, at: pos) else { return false }
            return n.winner()?.player == .x
        }
        #expect(threats.count >= 2)
    }

    @Test func defendsAgainstDoubleCornerForkWithEdge() {
        // Classic fork trap: X opens corner, O takes center, X plays opposite corner.
        // Now X threatens a fork via any free corner. O must respond with an EDGE
        // to force X to defend, not play a corner (which would let X fork).
        var board = Board()
        board = board.placing(.x, at: CellPosition(row: 0, column: 0)!)!
        board = board.placing(.o, at: CellPosition(row: 1, column: 1)!)!
        board = board.placing(.x, at: CellPosition(row: 2, column: 2)!)!
        let state = GameState(board: board, currentPlayer: .o)

        let move = ai.move(for: .o, in: state)
        #expect(move != nil)

        let edges: Set<CellPosition> = [
            CellPosition(row: 0, column: 1)!,
            CellPosition(row: 1, column: 0)!,
            CellPosition(row: 1, column: 2)!,
            CellPosition(row: 2, column: 1)!,
        ]
        #expect(edges.contains(move!))
    }
}
