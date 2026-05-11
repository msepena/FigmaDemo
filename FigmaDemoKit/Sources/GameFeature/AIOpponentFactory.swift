import AppPreferences
import GameDomain

enum AIOpponentFactory {
    static func make(for difficulty: Difficulty) -> any AIOpponent {
        switch difficulty {
        case .easy:   return RandomAI()
        case .medium: return BlockOrWinAI()
        case .hard:   return ForkAwareAI()
        }
    }
}
