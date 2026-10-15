import UIKit

/// Collectible cats. New breeds unlock as the player progresses and start
/// showing up on the boards.
struct CatBreed: Identifiable, Equatable {
    enum Pattern {
        case plain, tabby, patch
    }

    let id: Int
    let name: String
    let color: UIColor
    let patternColor: UIColor
    let pattern: Pattern
    let unlockLevel: Int

    static func == (lhs: CatBreed, rhs: CatBreed) -> Bool { lhs.id == rhs.id }

    static let all: [CatBreed] = [
        CatBreed(id: 0, name: "Ginger", color: rgb(0.96, 0.62, 0.30), patternColor: rgb(0.84, 0.45, 0.17), pattern: .tabby, unlockLevel: 1),
        CatBreed(id: 1, name: "Smokey", color: rgb(0.55, 0.60, 0.68), patternColor: rgb(0.42, 0.46, 0.54), pattern: .plain, unlockLevel: 1),
        CatBreed(id: 2, name: "Biscuit", color: rgb(0.95, 0.88, 0.75), patternColor: rgb(0.72, 0.50, 0.32), pattern: .patch, unlockLevel: 3),
        CatBreed(id: 3, name: "Shadow", color: rgb(0.27, 0.28, 0.36), patternColor: rgb(0.18, 0.18, 0.24), pattern: .plain, unlockLevel: 6),
        CatBreed(id: 4, name: "Bubblegum", color: rgb(0.95, 0.58, 0.70), patternColor: rgb(0.85, 0.42, 0.56), pattern: .tabby, unlockLevel: 10),
        CatBreed(id: 5, name: "Blueberry", color: rgb(0.58, 0.78, 0.95), patternColor: rgb(0.36, 0.55, 0.85), pattern: .patch, unlockLevel: 15),
        CatBreed(id: 6, name: "Mochi", color: rgb(0.98, 0.97, 0.95), patternColor: rgb(0.60, 0.60, 0.62), pattern: .patch, unlockLevel: 20),
        CatBreed(id: 7, name: "Pumpkin", color: rgb(0.98, 0.50, 0.15), patternColor: rgb(0.80, 0.32, 0.08), pattern: .tabby, unlockLevel: 30),
        CatBreed(id: 8, name: "Minty", color: rgb(0.60, 0.88, 0.75), patternColor: rgb(0.38, 0.70, 0.56), pattern: .plain, unlockLevel: 40),
        CatBreed(id: 9, name: "Lilac", color: rgb(0.76, 0.66, 0.92), patternColor: rgb(0.58, 0.46, 0.80), pattern: .tabby, unlockLevel: 50),
        CatBreed(id: 10, name: "Goldie", color: rgb(1.00, 0.82, 0.30), patternColor: rgb(0.88, 0.62, 0.12), pattern: .patch, unlockLevel: 65),
        CatBreed(id: 11, name: "Cosmo", color: rgb(0.24, 0.30, 0.55), patternColor: rgb(0.95, 0.85, 0.40), pattern: .patch, unlockLevel: 80),
    ]

    static func unlocked(upTo level: Int) -> [CatBreed] {
        all.filter { $0.unlockLevel <= level }
    }

    private static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
