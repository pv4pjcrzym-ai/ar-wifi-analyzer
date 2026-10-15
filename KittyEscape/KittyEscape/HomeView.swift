import SwiftUI

struct HomeView: View {
    private enum Sheet: String, Identifiable {
        case daily, collection, shop, settings
        var id: String { rawValue }
    }

    @ObservedObject var progress: PlayerProgress
    @ObservedObject var store: Store
    let onPlay: () -> Void

    @State private var sheet: Sheet?
    @State private var bounce = false

    var body: some View {
        ZStack {
            Palette.backgroundColor.ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Button { sheet = .settings } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .buttonStyle(RoundIconButtonStyle())

                    Spacer()

                    Button { sheet = .shop } label: {
                        CoinPill(coins: progress.coins, showsPlus: true)
                    }
                    .buttonStyle(PressableStyle())
                }

                Spacer()

                Image(uiImage: CatArt.image(for: progress.favoriteBreed, size: 220))
                    .offset(y: bounce ? -14 : 0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: bounce)
                    .onTapGesture { SoundManager.shared.meow() }

                Text("Kitty Escape!")
                    .font(.system(size: 46, weight: .black, design: .rounded))
                    .foregroundStyle(Palette.ink)

                Text("Tap the cats in the right order\nand help them all escape!")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Palette.ink.opacity(0.7))

                Spacer()

                HStack(spacing: 12) {
                    MenuTile(icon: "gift.fill", title: "Daily", showsBadge: progress.canClaimDaily) { sheet = .daily }
                    MenuTile(icon: "pawprint.fill",
                             title: "Cats \(progress.unlockedBreedCount)/\(CatBreed.all.count)") { sheet = .collection }
                    MenuTile(icon: "cart.fill", title: "Shop") { sheet = .shop }
                }

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
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .daily: DailyRewardView(progress: progress)
            case .collection: CollectionView(progress: progress)
            case .shop: ShopView(store: store, progress: progress)
            case .settings: SettingsView(progress: progress, store: store)
            }
        }
        .onAppear {
            bounce = true
            if progress.canClaimDaily { sheet = .daily }
        }
    }
}
