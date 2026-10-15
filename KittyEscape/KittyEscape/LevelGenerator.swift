import Foundation

/// Deterministic RNG so every player gets the same board for a given level.
struct SplitMix64: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

struct LevelSpec {
    let columns: Int
    let rows: Int
    let catCount: Int
    let colorCount: Int
}

enum LevelGenerator {
    static func spec(for level: Int) -> LevelSpec {
        let level = max(1, level)
        let columns = min(3 + (level + 1) / 3, 8)
        let rows = min(columns + 1 + level / 8, 11)
        let fill = min(0.4 + 0.025 * Double(level), 0.8)
        let catCount = max(3, Int((Double(columns * rows) * fill).rounded()))
        let colorCount = min(2 + level / 4, Palette.catColorCount)
        return LevelSpec(columns: columns, rows: rows, catCount: catCount, colorCount: colorCount)
    }

    /// Each new cat is only given a direction whose path is clear of the cats
    /// placed before it. So among any remaining cats, the most recently placed
    /// one can always escape: every level is solvable and can never deadlock.
    static func makeBoard(level: Int) -> Board {
        let spec = spec(for: level)
        var rng = SplitMix64(seed: UInt64(max(1, level)) &* 0x2545_F491_4F6C_DD1D &+ 7)
        var board = Board(columns: spec.columns, rows: spec.rows)

        var cells: [GridPoint] = []
        for col in 0..<spec.columns {
            for row in 0..<spec.rows {
                cells.append(GridPoint(col: col, row: row))
            }
        }
        cells.shuffle(using: &rng)

        var nextID = 0
        for cell in cells where nextID < spec.catCount {
            let directions = Direction.allCases.shuffled(using: &rng)
            guard let direction = directions.first(where: { board.firstCat(from: cell, toward: $0) == nil }) else {
                continue
            }
            let colorIndex = Int.random(in: 0..<spec.colorCount, using: &rng)
            board.add(Cat(id: nextID, position: cell, direction: direction, colorIndex: colorIndex))
            nextID += 1
        }
        return board
    }
}
