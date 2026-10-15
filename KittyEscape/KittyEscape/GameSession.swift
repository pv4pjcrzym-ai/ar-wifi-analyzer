import Combine
import Foundation

/// Rules and state for one level. The scene renders it, SwiftUI shows the HUD.
final class GameSession: ObservableObject {
    enum Phase: Equatable {
        case playing
        case won(stars: Int, reward: Int)
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
    private var mistakes = 0

    lazy var scene = GameScene(session: self)

    init(progress: PlayerProgress) {
        self.progress = progress
        level = progress.level
        board = LevelGenerator.makeBoard(level: progress.level)
        totalCats = board.cats.count
        catsLeft = totalCats
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
            if hearts <= 0 { phase = .lost }
        case .empty:
            break
        }
        return outcome
    }

    func restart() { load(level: level) }

    func nextLevel() { load(level: progress.level) }

    @discardableResult
    func useHint() -> Bool {
        guard phase == .playing, progress.coins >= Self.hintCost,
              let cat = board.removableCats.last else { return false }
        progress.coins -= Self.hintCost
        scene.showHint(cat)
        return true
    }

    /// Continue after running out of hearts. Hook a rewarded ad in here later.
    @discardableResult
    func revive() -> Bool {
        guard phase == .lost, progress.coins >= Self.reviveCost else { return false }
        progress.coins -= Self.reviveCost
        hearts = 1
        phase = .playing
        return true
    }

    private func finishLevel() {
        let stars = max(1, 3 - mistakes)
        let reward = 10 + stars * 5
        progress.coins += reward
        progress.completeLevel(level)
        phase = .won(stars: stars, reward: reward)
    }

    private func load(level: Int) {
        self.level = level
        board = LevelGenerator.makeBoard(level: level)
        totalCats = board.cats.count
        catsLeft = totalCats
        hearts = Self.maxHearts
        mistakes = 0
        phase = .playing
        scene.rebuild(animated: true)
    }
}
