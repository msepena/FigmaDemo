public enum Mark: Sendable, Hashable {
    case empty
    case occupied(Player)

    public var player: Player? {
        if case let .occupied(p) = self { return p }
        return nil
    }

    public var isEmpty: Bool {
        if case .empty = self { return true }
        return false
    }
}
