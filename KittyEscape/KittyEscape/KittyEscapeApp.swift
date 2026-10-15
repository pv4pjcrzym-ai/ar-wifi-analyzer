import SwiftUI

@main
struct KittyEscapeApp: App {
    @StateObject private var progress = PlayerProgress()

    var body: some Scene {
        WindowGroup {
            RootView(progress: progress)
                .preferredColorScheme(.light)
                .statusBarHidden()
        }
    }
}

struct RootView: View {
    @ObservedObject var progress: PlayerProgress
    @State private var isPlaying = false

    var body: some View {
        ZStack {
            if isPlaying {
                GameView(progress: progress) { isPlaying = false }
                    .transition(.opacity)
            } else {
                HomeView(progress: progress) { isPlaying = true }
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPlaying)
    }
}
