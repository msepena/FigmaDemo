public enum GameOutcome: Sendable, Hashable {
    case ongoing
    case win(Player, WinningLine)
    case draw

    public var isFinished: Bool {
        switch self {
        case .ongoing: return false
        case .win, .draw: return true
        }
    }

    public var winningLine: WinningLine? {
        if case let .win(_, line) = self { return line }
        return nil
    }
}
