import Foundation

/// Placeholder until an ad SDK (AppLovin MAX or AdMob) is added.
/// The game already calls these at the right moments.
final class Ads {
    static let shared = Ads()

    /// Interstitials start at this level and then play every few levels.
    private let firstInterstitialLevel = 5
    private let interstitialEvery = 3

    var isRewardedReady: Bool { false }

    func showRewarded(completion: @escaping (Bool) -> Void) {
        completion(false)
    }

    func maybeShowInterstitial(afterLevel level: Int, removeAds: Bool) {
        guard !removeAds, level >= firstInterstitialLevel, level % interstitialEvery == 0 else { return }
        Analytics.log("interstitial_opportunity", ["level": level])
    }
}

/// Swap the body for Firebase, GameAnalytics or similar.
enum Analytics {
    static func log(_ event: String, _ parameters: [String: Any] = [:]) {
        #if DEBUG
        print("[analytics]", event, parameters)
        #endif
    }
}

enum AppInfo {
    // Replace before submitting: App Store review requires a working privacy policy.
    static let privacyPolicyURL = URL(string: "https://example.com/kittyescape/privacy")!
    static let supportURL = URL(string: "mailto:support@example.com")!

    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
