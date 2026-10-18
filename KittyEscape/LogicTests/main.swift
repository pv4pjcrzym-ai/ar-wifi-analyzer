// Plays every level with random valid moves to prove the generator never
// produces an unsolvable or stuck board. Run by CI with swiftc.
import Foundation

var failures = 0

func check(_ condition: Bool, _ message: @autoclosure () -> String) {
    if !condition {
        failures += 1
        print("FAIL:", message())
    }
}

for level in 1...300 {
    let spec = LevelGenerator.spec(for: level)
    let original = LevelGenerator.makeBoard(level: level)
    check(original.cats.count >= 3, "level \(level) has only \(original.cats.count) cats")
    check(original.cats.count <= spec.catCount, "level \(level) has too many cats")
    check(original.columns == spec.columns && original.rows == spec.rows, "level \(level) has wrong size")

    let again = LevelGenerator.makeBoard(level: level)
    check(Set(again.cats.values) == Set(original.cats.values), "level \(level) is not deterministic")

    for attempt in 0..<20 {
        var board = original
        var rng = SystemRandomNumberGenerator()
        var taps = 0
        while !board.isCleared {
            let free = board.removableCats
            guard let cat = free.randomElement(using: &rng) else {
                check(false, "level \(level) got stuck on attempt \(attempt) with \(board.cats.count) cats left")
                break
            }
            switch board.tap(cat.position) {
            case .escaped, .woke:
                break
            case .blocked, .empty:
                check(false, "level \(level): a removable cat could not escape")
            }
            taps += 1
            if taps > 1000 {
                check(false, "level \(level) never finished")
                break
            }
        }
    }
}

let firstSleepy = LevelGenerator.makeBoard(level: LevelGenerator.firstSleepyLevel)
check(firstSleepy.cats.values.contains { $0.isAsleep }, "first sleepy level has no sleepy cat")
check(!LevelGenerator.makeBoard(level: 1).cats.values.contains { $0.isAsleep }, "level 1 has a sleepy cat")

if failures > 0 {
    print("\(failures) failure(s)")
    exit(1)
}
print("All level logic tests passed")
