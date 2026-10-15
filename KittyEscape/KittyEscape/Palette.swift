import SwiftUI
import UIKit

enum Palette {
    static let background = UIColor(red: 1.00, green: 0.95, blue: 0.88, alpha: 1)
    static let boardBacking = UIColor(red: 0.96, green: 0.84, blue: 0.70, alpha: 1)
    static let tile = UIColor(red: 1.00, green: 0.91, blue: 0.80, alpha: 1)
    static let heart = UIColor(red: 0.96, green: 0.36, blue: 0.48, alpha: 1)
    static let hint = UIColor(red: 1.00, green: 0.80, blue: 0.20, alpha: 1)
    static let inkUI = UIColor(red: 0.30, green: 0.20, blue: 0.15, alpha: 1)

    static let confetti: [UIColor] = CatBreed.all.map(\.color) + [heart, hint]

    static let backgroundColor = Color(uiColor: background)
    static let heartColor = Color(uiColor: heart)
    static let ink = Color(uiColor: inkUI)
    static let play = Color(red: 0.36, green: 0.78, blue: 0.45)
    static let hintButton = Color(red: 1.00, green: 0.70, blue: 0.15)
    static let coin = Color(red: 1.00, green: 0.78, blue: 0.10)
    static let card = Color.white
}

extension UIColor {
    var hsbBrightness: CGFloat {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return brightness
    }

    func darker(_ amount: CGFloat) -> UIColor {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: min(saturation * 1.1, 1), brightness: brightness * (1 - amount), alpha: alpha)
    }
}
