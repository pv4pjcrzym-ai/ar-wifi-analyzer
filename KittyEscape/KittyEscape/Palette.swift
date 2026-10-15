import SwiftUI
import UIKit

enum Palette {
    static let background = UIColor(red: 1.00, green: 0.95, blue: 0.88, alpha: 1)
    static let boardBacking = UIColor(red: 0.96, green: 0.84, blue: 0.70, alpha: 1)
    static let tile = UIColor(red: 1.00, green: 0.91, blue: 0.80, alpha: 1)
    static let heart = UIColor(red: 0.96, green: 0.36, blue: 0.48, alpha: 1)
    static let hint = UIColor(red: 1.00, green: 0.80, blue: 0.20, alpha: 1)

    private static let catColors: [UIColor] = [
        UIColor(red: 0.96, green: 0.62, blue: 0.30, alpha: 1), // ginger
        UIColor(red: 0.55, green: 0.60, blue: 0.68, alpha: 1), // grey
        UIColor(red: 0.95, green: 0.88, blue: 0.75, alpha: 1), // cream
        UIColor(red: 0.27, green: 0.28, blue: 0.36, alpha: 1), // black
        UIColor(red: 0.95, green: 0.58, blue: 0.70, alpha: 1), // pink
        UIColor(red: 0.58, green: 0.78, blue: 0.95, alpha: 1), // blue
    ]

    static var catColorCount: Int { catColors.count }

    static func catColor(_ index: Int) -> UIColor {
        catColors[index % catColors.count]
    }

    static let confetti: [UIColor] = catColors + [heart, hint]

    static let backgroundColor = Color(uiColor: background)
    static let heartColor = Color(uiColor: heart)
    static let ink = Color(red: 0.30, green: 0.20, blue: 0.15)
    static let play = Color(red: 0.36, green: 0.78, blue: 0.45)
    static let hintButton = Color(red: 1.00, green: 0.70, blue: 0.15)
    static let coin = Color(red: 1.00, green: 0.78, blue: 0.10)
}

extension UIColor {
    func darker(_ amount: CGFloat) -> UIColor {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: min(saturation * 1.1, 1), brightness: brightness * (1 - amount), alpha: alpha)
    }
}
