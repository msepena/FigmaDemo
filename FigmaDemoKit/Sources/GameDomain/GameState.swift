public struct Score: Sendable, Hashable {
    public var xWins: Int
    public var oWins: Int
    public var draws: Int

    public init(xWins: Int = 0, oWins: Int = 0, draws: Int = 0) {
        self.xWins = xWins
        self.oWins = oWins
        self.draws = draws
    }

    public var totalRounds: Int { xWins + oWins + draws }
}

public struct Move: Sendable, Hashable {
    public let player: Player
    public let position: CellPosition

    public init(player: Player, position: CellPosition) {
        self.player = player
        self.position = position
    }
}

public struct GameState: Sendable, Hashable {
    public var board: Board
    public var currentPlayer: Player
    public var outcome: GameOutcome
    public var score: Score
    public var roundNumber: Int
    public var history: [Move]

    public init(
        board: Board = Board(),
        currentPlayer: Player = .x,
        outcome: GameOutcome = .ongoing,
        score: Score = Score(),
        roundNumber: Int = 1,
        history: [Move] = []
    ) {
        self.board = board
        self.currentPlayer = currentPlayer
        self.outcome = outcome
        self.score = score
        self.roundNumber = roundNumber
        self.history = history
    }
}
