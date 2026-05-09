public struct Board: Sendable, Hashable {
    private var cells: [Mark]

    public init() {
        self.cells = Array(repeating: .empty, count: 9)
    }

    public subscript(_ position: CellPosition) -> Mark {
        cells[position.row * 3 + position.column]
    }

    public func placing(_ player: Player, at position: CellPosition) -> Board? {
        guard self[position].isEmpty else { return nil }
        var copy = self
        copy.cells[position.row * 3 + position.column] = .occupied(player)
        return copy
    }

    public var isFull: Bool {
        cells.allSatisfy { !$0.isEmpty }
    }

    public var isEmpty: Bool {
        cells.allSatisfy(\.isEmpty)
    }

    public func winner() -> (player: Player, line: WinningLine)? {
        for line in WinningLine.allLines {
            let marks = line.positions.map { self[$0] }
            guard let first = marks.first?.player else { continue }
            if marks.allSatisfy({ $0.player == first }) {
                return (first, line)
            }
        }
        return nil
    }
}
