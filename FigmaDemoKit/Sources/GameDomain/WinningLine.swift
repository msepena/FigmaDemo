public struct WinningLine: Sendable, Hashable {
    public let positions: [CellPosition]

    public init(_ positions: [CellPosition]) {
        precondition(positions.count == 3, "A winning line must have exactly 3 positions")
        self.positions = positions
    }

    public static let allLines: [WinningLine] = {
        let rows = (0..<3).map { r in
            WinningLine((0..<3).compactMap { c in CellPosition(row: r, column: c) })
        }
        let cols = (0..<3).map { c in
            WinningLine((0..<3).compactMap { r in CellPosition(row: r, column: c) })
        }
        let diag1 = WinningLine((0..<3).compactMap { i in CellPosition(row: i, column: i) })
        let diag2 = WinningLine((0..<3).compactMap { i in CellPosition(row: i, column: 2 - i) })
        return rows + cols + [diag1, diag2]
    }()
}
