import UIKit

enum Haptics {
    private static let impact = UIImpactFeedbackGenerator(style: .light)
    private static let notification = UINotificationFeedbackGenerator()

    static func tap() { impact.impactOccurred() }
    static func error() { notification.notificationOccurred(.error) }
    static func success() { notification.notificationOccurred(.success) }
}
