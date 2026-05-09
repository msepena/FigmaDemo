import Testing
@testable import GameDomain

@Suite("Board")
struct BoardTests {
    @Test func newBoardIsEmpty() {
        let board = Board()
        #expect(board.isEmpty)
        #expect(!board.isFull)
        for position in CellPosition.allPositions {
            #expect(board[position].isEmpty)
        }
    }

    @Test func placeMarkOnEmptyCell() {
        let board = Board()
        let pos = CellPosition(row: 1, column: 1)!
        let updated = board.placing(.x, at: pos)
        #expect(updated != nil)
        #expect(updated?[pos].player == .x)
    }

    @Test func placeMarkOnOccupiedCellFails() {
        let board = Board().placing(.x, at: CellPosition(row: 0, column: 0)!)!
        let result = board.placing(.o, at: CellPosition(row: 0, column: 0)!)
        #expect(result == nil)
    }

    @Test func boardFullAfterNineMoves() {
        var board = Board()
        let players: [Player] = [.x, .o, .x, .o, .x, .o, .x, .o, .x]
        for (i, player) in players.enumerated() {
            let pos = CellPosition(row: i / 3, column: i % 3)!
            board = board.placing(player, at: pos)!
        }
        #expect(board.isFull)
    }

    @Test func detectsRowWin() {
        var board = Board()
        for c in 0..<3 {
            board = board.placing(.x, at: CellPosition(row: 1, column: c)!)!
        }
        let winner = board.winner()
        #expect(winner?.player == .x)
        #expect(winner?.line.positions.map(\.row).allSatisfy { $0 == 1 } == true)
    }

    @Test func detectsColumnWin() {
        var board = Board()
        for r in 0..<3 {
            board = board.placing(.o, at: CellPosition(row: r, column: 2)!)!
        }
        #expect(board.winner()?.player == .o)
    }

    @Test func detectsMainDiagonalWin() {
        var board = Board()
        for i in 0..<3 {
            board = board.placing(.x, at: CellPosition(row: i, column: i)!)!
        }
        let winner = board.winner()
        #expect(winner?.player == .x)
        #expect(winner?.line.positions == [
            CellPosition(row: 0, column: 0)!,
            CellPosition(row: 1, column: 1)!,
            CellPosition(row: 2, column: 2)!,
        ])
    }

    @Test func detectsAntiDiagonalWin() {
        var board = Board()
        for i in 0..<3 {
            board = board.placing(.o, at: CellPosition(row: i, column: 2 - i)!)!
        }
        #expect(board.winner()?.player == .o)
    }

    @Test func noWinnerOnMixedBoard() {
        var board = Board()
        board = board.placing(.x, at: CellPosition(row: 0, column: 0)!)!
        board = board.placing(.o, at: CellPosition(row: 1, column: 1)!)!
        board = board.placing(.x, at: CellPosition(row: 2, column: 2)!)!
        #expect(board.winner() == nil)
    }
}

@Suite("WinningLine")
struct WinningLineTests {
    @Test func eightLinesTotal() {
        #expect(WinningLine.allLines.count == 8)
    }

    @Test func everyLineHasThreePositions() {
        for line in WinningLine.allLines {
            #expect(line.positions.count == 3)
        }
    }
}
