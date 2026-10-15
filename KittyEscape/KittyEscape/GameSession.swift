import Combine
import Foundation

/// Rules and state for one level. The scene renders it, SwiftUI shows the HUD.
final class GameSession: ObservableObject {
    enum Phase: Equatable {
        case playing
        case won(stars: Int, reward: Int, newBreed: CatBreed?)
        case lost
    }

    static let maxHearts = 3
    static let hintCost = 30
    static let reviveCost = 50

    let progress: PlayerProgress

    @Published private(set) var level: Int
    @Published private(set) var hearts = GameSession.maxHearts
    @Published private(set) var phase: Phase = .playing
    @Published private(set) var catsLeft = 0
    private(set) var totalCats = 0
    private(set) var board: Board
    private(set) var spec: LevelSpec
    private var breeds: [CatBreed] = []
    private var mistakes = 0

    lazy var scene = GameScene(session: self)

    var isHard: Bool { spec.isHard }

    init(progress: PlayerProgress) {
        self.progress = progress
        level = progress.level
        spec = LevelGenerator.spec(for: progress.level)
        board = LevelGenerator.makeBoard(level: progress.level)
        prepareLevel()
    }

    func breed(for cat: Cat) -> CatBreed {
        breeds[cat.colorIndex % breeds.count]
    }

    func tap(_ point: GridPoint) -> TapOutcome {
        guard phase == .playing else { return .empty }
        let outcome = board.tap(point)
        switch outcome {
        case .escaped:
            catsLeft = board.cats.count
            if board.isCleared { finishLevel() }
        case .blocked:
            mistakes += 1
            hearts -= 1
            if hearts <= 0 {
                phase = .lost
                Analytics.log("level_fail", ["level": level, "cats_left": catsLeft])
            }
        case .woke, .empty:
            break
        }
        return outcome
    }

    func restart() { load(level: level) }

    func nextLevel() {
        Ads.shared.maybeShowInterstitial(afterLevel: level, removeAds: progress.removeAds)
        load(level: progress.level)
    }

    @discardableResult
    func useHint() -> Bool {
        guard phase == .playing, progress.coins >= Self.hintCost,
              let cat = board.removableCats.last else { return false }
        progress.coins -= Self.hintCost
        scene.showHint(cat)
        Analytics.log("hint_used", ["level": level])
        return true
    }

    @discardableResult
    func revive() -> Bool {
        guard phase == .lost, progress.coins >= Self.reviveCost else { return false }
        progress.coins -= Self.reviveCost
        resume(source: "coins")
        return true
    }

    func reviveWithAd() {
        guard phase == .lost else { return }
        Ads.shared.showRewarded { [weak self] rewarded in
            if rewarded { self?.resume(source: "ad") }
        }
    }

    private func resume(source: String) {
        hearts = 1
        phase = .playing
        Analytics.log("revive", ["level": level, "source": source])
    }

    private func finishLevel() {
        let stars = max(1, 3 - mistakes)
        let reward = (10 + stars * 5) * (spec.isHard ? 2 : 1)
        let isFirstClear = level >= progress.level
        let newBreed = isFirstClear ? CatBreed.all.first(where: { $0.unlockLevel == level + 1 }) : nil
        progress.coins += reward
        progress.completeLevel(level)
        phase = .won(stars: stars, reward: reward, newBreed: newBreed)
        Analytics.log("level_complete", ["level": level, "stars": stars, "hard": spec.isHard])
    }

    private func load(level: Int) {
        self.level = level
        spec = LevelGenerator.spec(for: level)
        board = LevelGenerator.makeBoard(level: level)
        prepareLevel()
        scene.rebuild(animated: true)
    }

    private func prepareLevel() {
        // Feature the newest cats the player has unlocked.
        breeds = Array(CatBreed.unlocked(upTo: progress.level).suffix(spec.colorCount))
        totalCats = board.cats.count
        catsLeft = totalCats
        hearts = Self.maxHearts
        mistakes = 0
        phase = .playing
        Analytics.log("level_start", ["level": level])
    }
}
