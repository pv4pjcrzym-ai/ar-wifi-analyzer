import StoreKit
import SwiftUI

struct DailyRewardView: View {
    private enum DayState {
        case claimed, today, locked
    }

    @ObservedObject var progress: PlayerProgress
    @Environment(\.dismiss) private var dismiss
    @State private var claimedReward: Int?

    var body: some View {
        VStack(spacing: 18) {
            Text("Daily Gift")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(Palette.ink)
            Text("Come back every day for bigger rewards!")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Palette.ink.opacity(0.7))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                ForEach(0..<PlayerProgress.dailyRewards.count, id: \.self) { day in
                    dayCell(day)
                }
            }

            if progress.canClaimDaily {
                Button("Claim \(PlayerProgress.dailyRewards[progress.nextDailyIndex]) 🪙") {
                    claimedReward = progress.claimDaily()
                    SoundManager.shared.play(.coin)
                    Haptics.success()
                }
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .buttonStyle(ChunkyButtonStyle(color: Palette.play))
            } else {
                Text(claimedReward.map { "+\($0) coins! See you tomorrow 🐾" } ?? "Come back tomorrow for your next gift!")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.ink)
                Button("Close") { dismiss() }
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .buttonStyle(ChunkyButtonStyle(color: Palette.play))
            }
        }
        .padding(24)
        .presentationDetents([.medium, .large])
        .presentationBackground(Palette.backgroundColor)
    }

    private func state(for day: Int) -> DayState {
        if day < progress.claimedDaysInCycle { return .claimed }
        if progress.canClaimDaily && day == progress.nextDailyIndex { return .today }
        return .locked
    }

    private func dayCell(_ day: Int) -> some View {
        let dayState = state(for: day)
        return VStack(spacing: 4) {
            Text("Day \(day + 1)")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
            Text(dayState == .claimed ? "✅" : (day == PlayerProgress.dailyRewards.count - 1 ? "💰" : "🪙"))
                .font(.system(size: 26))
            Text("\(PlayerProgress.dailyRewards[day])")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
        }
        .foregroundStyle(Palette.ink)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(dayState == .today ? Palette.coin.opacity(0.35) : Palette.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(dayState == .today ? Palette.hintButton : Color.clear, lineWidth: 3)
        )
        .opacity(dayState == .locked ? 0.6 : 1)
    }
}

struct CollectionView: View {
    @ObservedObject var progress: PlayerProgress
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Tap a cat to make it your favourite.")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Palette.ink.opacity(0.7))
                    .padding(.top, 4)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(CatBreed.all) { breed in
                        breedCard(breed)
                    }
                }
                .padding(16)
            }
            .background(Palette.backgroundColor)
            .navigationTitle("Cats \(progress.unlockedBreedCount)/\(CatBreed.all.count)")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func breedCard(_ breed: CatBreed) -> some View {
        let unlocked = progress.isUnlocked(breed)
        let isFavorite = progress.favoriteBreed == breed
        return Button {
            guard unlocked else { return }
            progress.favoriteBreedID = breed.id
            SoundManager.shared.meow()
        } label: {
            VStack(spacing: 6) {
                Image(uiImage: CatArt.image(for: breed, size: 84))
                    .saturation(unlocked ? 1 : 0)
                    .opacity(unlocked ? 1 : 0.3)
                    .overlay {
                        if !unlocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(Palette.ink.opacity(0.7))
                        }
                    }
                Text(unlocked ? breed.name : "Level \(breed.unlockLevel)")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(Palette.ink)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette.card))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isFavorite ? Palette.play : Color.clear, lineWidth: 3)
            )
        }
        .buttonStyle(PressableStyle())
    }
}

struct ShopView: View {
    @ObservedObject var store: Store
    @ObservedObject var progress: PlayerProgress
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    CoinPill(coins: progress.coins)

                    if store.products.isEmpty {
                        ProgressView()
                            .padding(.top, 40)
                        Text("Loading the shop…")
                            .foregroundStyle(Palette.ink.opacity(0.7))
                    }

                    ForEach(store.products) { product in
                        ShopRow(product: product,
                                isOwned: product.id == StoreProduct.removeAds && progress.removeAds,
                                isBusy: store.isPurchasing) {
                            Task { await store.purchase(product) }
                        }
                    }

                    Button("Restore purchases") {
                        Task { await store.restore() }
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .padding(.top, 8)

                    if let message = store.message {
                        Text(message)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Palette.ink.opacity(0.7))
                    }
                }
                .padding(20)
            }
            .background(Palette.backgroundColor)
            .navigationTitle("Shop")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct ShopRow: View {
    let product: Product
    let isOwned: Bool
    let isBusy: Bool
    let onBuy: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Text(icon)
                .font(.system(size: 36))
            VStack(alignment: .leading, spacing: 2) {
                Text(product.displayName)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(Palette.ink)
                Text(product.description)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Palette.ink.opacity(0.6))
            }
            Spacer()
            Button(isOwned ? "Owned" : product.displayPrice, action: onBuy)
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .buttonStyle(ChunkyButtonStyle(color: Palette.play, minWidth: 90))
                .disabled(isOwned || isBusy)
                .opacity(isOwned ? 0.6 : 1)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Palette.card))
    }

    private var icon: String {
        switch product.id {
        case StoreProduct.removeAds: return "🚫"
        case StoreProduct.coinsLarge: return "💰"
        default: return "🪙"
        }
    }
}

struct SettingsView: View {
    @ObservedObject var progress: PlayerProgress
    @ObservedObject var store: Store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Sound") {
                    Toggle("Sound effects", isOn: $progress.soundOn)
                    Toggle("Music", isOn: $progress.musicOn)
                    Toggle("Vibration", isOn: $progress.hapticsOn)
                }
                Section("Purchases") {
                    Button("Restore purchases") {
                        Task { await store.restore() }
                    }
                    if let message = store.message {
                        Text(message).foregroundStyle(.secondary)
                    }
                }
                Section("About") {
                    Link("Privacy policy", destination: AppInfo.privacyPolicyURL)
                    Link("Contact support", destination: AppInfo.supportURL)
                    LabeledContent("Version", value: AppInfo.version)
                }
            }
            .tint(Palette.play)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
