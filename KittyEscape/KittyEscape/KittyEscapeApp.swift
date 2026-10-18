import SwiftUI

@main
struct KittyEscapeApp: App {
    @StateObject private var progress: PlayerProgress
    @StateObject private var store: Store

    init() {
        let progress = PlayerProgress()
        _progress = StateObject(wrappedValue: progress)
        _store = StateObject(wrappedValue: Store(progress: progress))
    }

    var body: some Scene {
        WindowGroup {
            RootView(progress: progress, store: store)
                .preferredColorScheme(.light)
                .statusBarHidden()
        }
    }
}

struct RootView: View {
    @ObservedObject var progress: PlayerProgress
    @ObservedObject var store: Store
    @State private var isPlaying = Demo.screen == "game"

    var body: some View {
        ZStack {
            if isPlaying {
                GameView(progress: progress) { isPlaying = false }
                    .transition(.opacity)
            } else {
                HomeView(progress: progress, store: store) { isPlaying = true }
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPlaying)
        .onAppear { SoundManager.shared.startMusic() }
    }
}
