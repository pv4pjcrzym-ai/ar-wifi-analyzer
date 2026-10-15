import SpriteKit
import SwiftUI

struct GameView: View {
    @StateObject private var session: GameSession
    @ObservedObject private var progress: PlayerProgress
    private let onExit: () -> Void

    init(progress: PlayerProgress, onExit: @escaping () -> Void) {
        _session = StateObject(wrappedValue: GameSession(progress: progress))
        _progress = ObservedObject(wrappedValue: progress)
        self.onExit = onExit
    }

    var body: some View {
        ZStack {
            SpriteView(scene: session.scene, preferredFramesPerSecond: 60)
                .ignoresSafeArea()

            VStack {
                topBar
                Spacer()
                bottomBar
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            overlay
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: session.phase)
    }

    @ViewBuilder
    private var overlay: some View {
        switch session.phase {
        case .playing:
            EmptyView()
        case let .won(stars, reward, newBreed):
            ResultCard(title: session.isHard ? "Hard level beaten!" : "Purr-fect!",
                       subtitle: "+\(reward) coins",
                       stars: stars) {
                if let newBreed {
                    VStack(spacing: 4) {
                        Image(uiImage: CatArt.image(for: newBreed, size: 96))
                        Text("New cat unlocked: \(newBreed.name)!")
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                            .foregroundStyle(Palette.ink)
                    }
                }
                Button("Next level") { session.nextLevel() }
                    .buttonStyle(ChunkyButtonStyle(color: Palette.play))
            }
            .onAppear { SoundManager.shared.play(newBreed == nil ? .coin : .unlock) }
        case .lost:
            ResultCard(title: "Out of lives", subtitle: "So close! Keep going?", stars: nil) {
                if Ads.shared.isRewardedReady {
                    Button("Watch ad  +1 ❤️") { session.reviveWithAd() }
                        .buttonStyle(ChunkyButtonStyle(color: Palette.heartColor))
                }
                Button("Continue  \(GameSession.reviveCost) 🪙") { _ = session.revive() }
                    .buttonStyle(ChunkyButtonStyle(color: Palette.hintButton))
                    .disabled(progress.coins < GameSession.reviveCost)
                    .opacity(progress.coins < GameSession.reviveCost ? 0.5 : 1)
                Button("Try again") { session.restart() }
                    .buttonStyle(ChunkyButtonStyle(color: Palette.play))
            }
        }
    }

    private var topBar: some View {
        VStack(spacing: 10) {
            HStack {
                Button(action: onExit) {
                    Image(systemName: "house.fill")
                }
                .buttonStyle(RoundIconButtonStyle())

                Spacer()

                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Level \(session.level)")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundStyle(Palette.ink)
                        if session.isHard {
                            Text("HARD")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Palette.heartColor))
                        }
                    }
                    HStack(spacing: 4) {
                        ForEach(0..<GameSession.maxHearts, id: \.self) { index in
                            Image(systemName: index < session.hearts ? "heart.fill" : "heart")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Palette.heartColor)
                        }
                    }
                }

                Spacer()

                CoinPill(coins: progress.coins)
            }

            ProgressView(value: Double(session.totalCats - session.catsLeft),
                         total: Double(max(session.totalCats, 1)))
                .tint(Palette.play)
                .scaleEffect(x: 1, y: 2)
                .padding(.horizontal, 40)
        }
    }

    private var bottomBar: some View {
        HStack {
            Button { session.restart() } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            .buttonStyle(RoundIconButtonStyle())

            Spacer()

            Button { _ = session.useHint() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                    Text("Hint  \(GameSession.hintCost) 🪙")
                }
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
            }
            .buttonStyle(ChunkyButtonStyle(color: Palette.hintButton))
            .disabled(progress.coins < GameSession.hintCost)
            .opacity(progress.coins < GameSession.hintCost ? 0.5 : 1)
        }
    }
}

private struct ResultCard<Actions: View>: View {
    let title: String
    let subtitle: String
    let stars: Int?
    @ViewBuilder let actions: () -> Actions

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()

            VStack(spacing: 18) {
                if let stars {
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Image(systemName: "star.fill")
                                .font(.system(size: index == 1 ? 54 : 42))
                                .foregroundStyle(index < stars ? Palette.coin : Color.gray.opacity(0.3))
                        }
                    }
                }
                Text(title)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Palette.ink)
                Text(subtitle)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.ink.opacity(0.7))
                VStack(spacing: 12) {
                    actions()
                }
                .font(.system(size: 22, weight: .heavy, design: .rounded))
            }
            .padding(28)
            .frame(maxWidth: 340)
            .background(RoundedRectangle(cornerRadius: 32, style: .continuous).fill(Palette.backgroundColor))
            .padding(24)
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
    }
}
