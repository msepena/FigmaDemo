import SwiftUI
import GameDomain

#Preview("Empty board") {
    GameScreen()
}

#Preview("Mid-game with diagonal X win") {
    let engine = GameEngine()
    var state = GameState()
    let plays: [(Int, Int)] = [
        (0, 0), (0, 2),
        (1, 1), (2, 1),
        (2, 2),
    ]
    for (r, c) in plays {
        if let next = engine.makeMove(at: CellPosition(row: r, column: c)!, in: state) {
            state = next
        }
    }
    return GameScreen(viewModel: GameViewModel(state: state, engine: engine))
}

#Preview("Draw") {
    let engine = GameEngine()
    var state = GameState()
    let plays: [(Int, Int)] = [
        (0, 0), (0, 1), (0, 2),
        (1, 1), (1, 0), (1, 2),
        (2, 1), (2, 0), (2, 2),
    ]
    for (r, c) in plays {
        if let next = engine.makeMove(at: CellPosition(row: r, column: c)!, in: state) {
            state = next
        }
    }
    return GameScreen(viewModel: GameViewModel(state: state, engine: engine))
}
