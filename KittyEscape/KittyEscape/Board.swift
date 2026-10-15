import Foundation

enum Direction: Int, CaseIterable {
    case up, right, down, left

    var dx: Int {
        switch self {
        case .left: return -1
        case .right: return 1
        default: return 0
        }
    }

    /// Row 0 is the bottom row, so "up" increases the row index.
    var dy: Int {
        switch self {
        case .up: return 1
        case .down: return -1
        default: return 0
        }
    }
}

struct GridPoint: Hashable {
    var col: Int
    var row: Int

    func moved(_ direction: Direction) -> GridPoint {
        GridPoint(col: col + direction.dx, row: row + direction.dy)
    }
}

struct Cat: Identifiable, Hashable {
    let id: Int
    let position: GridPoint
    let direction: Direction
    let colorIndex: Int
    var isAsleep = false
}

enum TapOutcome {
    case escaped(Cat)
    /// The tapped cat and the first cat standing in its way.
    case blocked(Cat, Cat)
    /// A sleeping cat was tapped and is now awake (no penalty).
    case woke(Cat)
    case empty
}

struct Board {
    let columns: Int
    let rows: Int
    private(set) var cats: [Int: Cat] = [:]
    private var occupancy: [GridPoint: Int] = [:]

    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
    }

    var isCleared: Bool { cats.isEmpty }

    func contains(_ point: GridPoint) -> Bool {
        (0..<columns).contains(point.col) && (0..<rows).contains(point.row)
    }

    func cat(at point: GridPoint) -> Cat? {
        occupancy[point].flatMap { cats[$0] }
    }

    mutating func add(_ cat: Cat) {
        precondition(contains(cat.position) && occupancy[cat.position] == nil, "Cell must be free")
        cats[cat.id] = cat
        occupancy[cat.position] = cat.id
    }

    mutating func remove(_ id: Int) {
        guard let cat = cats.removeValue(forKey: id) else { return }
        occupancy[cat.position] = nil
    }

    /// First cat met when walking from `point` toward the edge, if any.
    func firstCat(from point: GridPoint, toward direction: Direction) -> Cat? {
        var next = point.moved(direction)
        while contains(next) {
            if let cat = self.cat(at: next) { return cat }
            next = next.moved(direction)
        }
        return nil
    }

    func blocker(of cat: Cat) -> Cat? {
        firstCat(from: cat.position, toward: cat.direction)
    }

    var removableCats: [Cat] {
        cats.values.filter { blocker(of: $0) == nil }.sorted { $0.id < $1.id }
    }

    mutating func tap(_ point: GridPoint) -> TapOutcome {
        guard var cat = self.cat(at: point) else { return .empty }
        if cat.isAsleep {
            cat.isAsleep = false
            cats[cat.id] = cat
            return .woke(cat)
        }
        if let blocker = self.blocker(of: cat) { return .blocked(cat, blocker) }
        remove(cat.id)
        return .escaped(cat)
    }
}
