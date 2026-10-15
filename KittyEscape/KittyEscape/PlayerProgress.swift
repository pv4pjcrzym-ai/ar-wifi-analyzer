import Combine
import Foundation

final class PlayerProgress: ObservableObject {
    private enum Keys {
        static let level = "progress.level"
        static let coins = "progress.coins"
    }

    private let defaults: UserDefaults

    @Published var level: Int {
        didSet { defaults.set(level, forKey: Keys.level) }
    }

    @Published var coins: Int {
        didSet { defaults.set(coins, forKey: Keys.coins) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        level = max(1, defaults.integer(forKey: Keys.level))
        coins = defaults.object(forKey: Keys.coins) as? Int ?? 100
    }

    func completeLevel(_ number: Int) {
        if number >= level { level = number + 1 }
    }
}
