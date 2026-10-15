import SwiftUI

struct HomeView: View {
    @ObservedObject var progress: PlayerProgress
    let onPlay: () -> Void
    @State private var wiggle = false

    var body: some View {
        ZStack {
            Palette.backgroundColor.ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    CoinPill(coins: progress.coins)
                }

                Spacer()

                Text("🐈")
                    .font(.system(size: 120))
                    .rotationEffect(.degrees(wiggle ? 8 : -8))
                    .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: wiggle)
                    .onAppear { wiggle = true }

                Text("Kitty Escape!")
                    .font(.system(size: 46, weight: .black, design: .rounded))
                    .foregroundStyle(Palette.ink)

                Text("Tap the cats in the right order\nand help them all escape!")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Palette.ink.opacity(0.7))

                Spacer()

                Button(action: onPlay) {
                    VStack(spacing: 2) {
                        Text("PLAY")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                        Text("Level \(progress.level)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .opacity(0.9)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(ChunkyButtonStyle(color: Palette.play))
            }
            .padding(24)
        }
    }
}
