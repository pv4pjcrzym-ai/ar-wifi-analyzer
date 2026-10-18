import Combine
import Foundation

final class PlayerProgress: ObservableObject {
    static let dailyRewards = [20, 30, 40, 50, 60, 80, 150]

    private enum Keys {
        static let level = "progress.level"
        static let coins = "progress.coins"
        static let sound = "settings.sound"
        static let music = "settings.music"
        static let haptics = "settings.haptics"
        static let removeAds = "store.removeAds"
        static let favoriteBreed = "collection.favorite"
        static let dailyStreak = "daily.streak"
        static let lastDailyClaim = "daily.lastClaim"
    }

    private let defaults: UserDefaults

    @Published var level: Int {
        didSet { defaults.set(level, forKey: Keys.level) }
    }

    @Published var coins: Int {
        didSet { defaults.set(coins, forKey: Keys.coins) }
    }

    @Published var soundOn: Bool {
        didSet {
            defaults.set(soundOn, forKey: Keys.sound)
            SoundManager.shared.soundOn = soundOn
        }
    }

    @Published var musicOn: Bool {
        didSet {
            defaults.set(musicOn, forKey: Keys.music)
            SoundManager.shared.musicOn = musicOn
        }
    }

    @Published var hapticsOn: Bool {
        didSet {
            defaults.set(hapticsOn, forKey: Keys.haptics)
            Haptics.isEnabled = hapticsOn
        }
    }

    @Published var removeAds: Bool {
        didSet { defaults.set(removeAds, forKey: Keys.removeAds) }
    }

    @Published var favoriteBreedID: Int {
        didSet { defaults.set(favoriteBreedID, forKey: Keys.favoriteBreed) }
    }

    /// Days claimed in the current 7-day cycle.
    @Published private(set) var dailyStreak: Int {
        didSet { defaults.set(dailyStreak, forKey: Keys.dailyStreak) }
    }

    @Published private(set) var lastDailyClaim: Date? {
        didSet { defaults.set(lastDailyClaim, forKey: Keys.lastDailyClaim) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        level = max(1, defaults.integer(forKey: Keys.level))
        // integer(forKey:) also reads launch-argument overrides, which arrive as strings.
        coins = defaults.object(forKey: Keys.coins) == nil ? 100 : defaults.integer(forKey: Keys.coins)
        soundOn = defaults.object(forKey: Keys.sound) as? Bool ?? true
        musicOn = defaults.object(forKey: Keys.music) as? Bool ?? true
        hapticsOn = defaults.object(forKey: Keys.haptics) as? Bool ?? true
        removeAds = defaults.bool(forKey: Keys.removeAds)
        favoriteBreedID = defaults.integer(forKey: Keys.favoriteBreed)
        dailyStreak = defaults.integer(forKey: Keys.dailyStreak)
        lastDailyClaim = defaults.object(forKey: Keys.lastDailyClaim) as? Date

        SoundManager.shared.soundOn = soundOn
        SoundManager.shared.musicOn = musicOn
        Haptics.isEnabled = hapticsOn
    }

    func completeLevel(_ number: Int) {
        if number >= level { level = number + 1 }
    }

    // MARK: - Collection

    func isUnlocked(_ breed: CatBreed) -> Bool { breed.unlockLevel <= level }

    var favoriteBreed: CatBreed {
        CatBreed.all.first(where: { $0.id == favoriteBreedID && isUnlocked($0) }) ?? CatBreed.all[0]
    }

    var unlockedBreedCount: Int { CatBreed.unlocked(upTo: level).count }

    // MARK: - Daily gift

    var canClaimDaily: Bool {
        guard let lastDailyClaim else { return true }
        return !Calendar.current.isDateInToday(lastDailyClaim)
    }

    /// Index (0-6) of the reward the next claim pays out.
    var nextDailyIndex: Int {
        guard let lastDailyClaim else { return 0 }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastDailyClaim),
                                           to: calendar.startOfDay(for: Date())).day ?? 0
        // Missing a day restarts the streak.
        return days <= 1 ? dailyStreak % Self.dailyRewards.count : 0
    }

    /// How many days of the current cycle show as already claimed.
    var claimedDaysInCycle: Int {
        canClaimDaily ? nextDailyIndex : dailyStreak
    }

    @discardableResult
    func claimDaily() -> Int {
        guard canClaimDaily else { return 0 }
        let index = nextDailyIndex
        let reward = Self.dailyRewards[index]
        coins += reward
        dailyStreak = index + 1
        lastDailyClaim = Date()
        Analytics.log("daily_claim", ["day": index + 1, "reward": reward])
        return reward
    }
}
