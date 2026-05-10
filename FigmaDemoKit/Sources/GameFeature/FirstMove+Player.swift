import AppPreferences
import GameDomain

extension FirstMove {
    /// Resolve the user's "First Move" preference to the concrete `Player` who
    /// should start the next round. `.random` picks X or O with equal odds.
    func resolvedStarter() -> Player {
        switch self {
        case .x: return .x
        case .o: return .o
        case .random: return Bool.random() ? .x : .o
        }
    }
}
