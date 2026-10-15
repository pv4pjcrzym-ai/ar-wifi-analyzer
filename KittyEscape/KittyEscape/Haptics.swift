import UIKit

enum Haptics {
    static var isEnabled = true

    private static let impact = UIImpactFeedbackGenerator(style: .light)
    private static let notification = UINotificationFeedbackGenerator()

    static func tap() {
        guard isEnabled else { return }
        impact.impactOccurred()
    }

    static func error() {
        guard isEnabled else { return }
        notification.notificationOccurred(.error)
    }

    static func success() {
        guard isEnabled else { return }
        notification.notificationOccurred(.success)
    }
}
