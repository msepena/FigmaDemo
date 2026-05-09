public enum Player: Sendable, Hashable, CaseIterable {
    case x
    case o

    public var opponent: Player {
        switch self {
        case .x: return .o
        case .o: return .x
        }
    }
}
