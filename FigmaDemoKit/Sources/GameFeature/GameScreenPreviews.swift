import SwiftUI
import AppPreferences
import GameDomain

@MainActor
private func emptyVM() -> GameViewModel {
    GameViewModel(prefs: AppPreferences())
}

@MainActor
private func midGameVM() -> GameViewModel {
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
    return GameViewModel(state: state, engine: engine, prefs: AppPreferences())
}

@MainActor
private func drawVM() -> GameViewModel {
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
    return GameViewModel(state: state, engine: engine, prefs: AppPreferences())
}

#Preview("Empty board") {
    GameScreen(viewModel: emptyVM())
}

#Preview("Mid-game with diagonal X win") {
    GameScreen(viewModel: midGameVM())
}

#Preview("Draw") {
    GameScreen(viewModel: drawVM())
}
