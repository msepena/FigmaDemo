public protocol AIOpponent: Sendable {
    func move(for player: Player, in state: GameState) -> CellPosition?
}

public struct RandomAI: AIOpponent {
    public init() {}

    public func move(for player: Player, in state: GameState) -> CellPosition? {
        emptyCells(on: state.board).randomElement()
    }
}

public struct BlockOrWinAI: AIOpponent {
    public init() {}

    public func move(for player: Player, in state: GameState) -> CellPosition? {
        if let win = findWinningMove(for: player, on: state.board) { return win }
        if let block = findWinningMove(for: player.opponent, on: state.board) { return block }
        return emptyCells(on: state.board).randomElement()
    }
}

public struct ForkAwareAI: AIOpponent {
    public init() {}

    public func move(for player: Player, in state: GameState) -> CellPosition? {
        let board = state.board
        if let win = findWinningMove(for: player, on: board) { return win }
        if let block = findWinningMove(for: player.opponent, on: board) { return block }
        if let fork = findForkMove(for: player, on: board) { return fork }
        if let blockFork = blockOpponentFork(for: player, on: board) { return blockFork }
        if board[center].isEmpty { return center }
        if let corner = corners.first(where: { board[$0].isEmpty }) { return corner }
        return edges.first(where: { board[$0].isEmpty })
    }
}

// MARK: - Shared helpers

func emptyCells(on board: Board) -> [CellPosition] {
    CellPosition.allPositions.filter { board[$0].isEmpty }
}

func findWinningMove(for player: Player, on board: Board) -> CellPosition? {
    for position in emptyCells(on: board) {
        guard let next = board.placing(player, at: position) else { continue }
        if next.winner()?.player == player { return position }
    }
    return nil
}

/// A "fork" is a move that creates two simultaneous winning threats — i.e., after
/// playing it, `player` has at least two distinct cells from which a winning move
/// is available on the next turn.
func findForkMove(for player: Player, on board: Board) -> CellPosition? {
    for position in emptyCells(on: board) {
        guard let next = board.placing(player, at: position) else { continue }
        if winningThreatCount(for: player, on: next) >= 2 { return position }
    }
    return nil
}

/// If the opponent has a fork available, prefer to either block it directly,
/// or force them to defend a threat we create. Falls back to plain block.
func blockOpponentFork(for player: Player, on board: Board) -> CellPosition? {
    let opponent = player.opponent
    let opponentForks = emptyCells(on: board).filter { position in
        guard let next = board.placing(opponent, at: position) else { return false }
        return winningThreatCount(for: opponent, on: next) >= 2
    }
    guard !opponentForks.isEmpty else { return nil }

    // Try to create our own threat that doesn't accidentally enable opponent's fork.
    for position in emptyCells(on: board) {
        guard let afterUs = board.placing(player, at: position) else { continue }
        guard winningThreatCount(for: player, on: afterUs) >= 1 else { continue }
        // Ensure the forced response doesn't leave us worse off.
        guard let response = findWinningMove(for: opponent, on: afterUs) else {
            // No forced response and we have a threat — good move.
            return position
        }
        guard let afterResponse = afterUs.placing(opponent, at: response) else { continue }
        if winningThreatCount(for: opponent, on: afterResponse) < 2 { return position }
    }

    // Otherwise, occupy a fork cell directly to deny it.
    return opponentForks.first
}

/// Number of empty cells on `board` from which `player` could win on the very next move.
private func winningThreatCount(for player: Player, on board: Board) -> Int {
    emptyCells(on: board).reduce(0) { count, position in
        guard let next = board.placing(player, at: position) else { return count }
        return next.winner()?.player == player ? count + 1 : count
    }
}

// MARK: - Standard positions

private let center = CellPosition(row: 1, column: 1)!
private let corners: [CellPosition] = [
    CellPosition(row: 0, column: 0)!,
    CellPosition(row: 0, column: 2)!,
    CellPosition(row: 2, column: 0)!,
    CellPosition(row: 2, column: 2)!,
]
private let edges: [CellPosition] = [
    CellPosition(row: 0, column: 1)!,
    CellPosition(row: 1, column: 0)!,
    CellPosition(row: 1, column: 2)!,
    CellPosition(row: 2, column: 1)!,
]
