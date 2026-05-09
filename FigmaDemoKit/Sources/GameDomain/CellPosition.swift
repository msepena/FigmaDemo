public struct CellPosition: Sendable, Hashable {
    public let row: Int
    public let column: Int

    public init?(row: Int, column: Int) {
        guard (0...2).contains(row), (0...2).contains(column) else { return nil }
        self.row = row
        self.column = column
    }

    public static let allPositions: [CellPosition] = (0..<3).flatMap { r in
        (0..<3).compactMap { c in CellPosition(row: r, column: c) }
    }
}
