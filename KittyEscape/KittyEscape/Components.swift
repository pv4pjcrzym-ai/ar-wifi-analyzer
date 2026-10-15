import SwiftUI

struct ChunkyButtonStyle: ButtonStyle {
    var color: Color
    var minWidth: CGFloat = 120

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .frame(minWidth: minWidth, minHeight: 50)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(color)
                    .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: configuration.isPressed ? 2 : 6)
            )
            .offset(y: configuration.isPressed ? 4 : 0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
            .clickSound(configuration.isPressed)
    }
}

struct RoundIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .heavy))
            .foregroundStyle(Palette.ink)
            .frame(width: 50, height: 50)
            .background(
                Circle()
                    .fill(.white)
                    .shadow(color: .black.opacity(0.15), radius: 0, x: 0, y: configuration.isPressed ? 1 : 4)
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
            .clickSound(configuration.isPressed)
    }
}

/// Plain press feedback for custom-looking buttons.
struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
            .clickSound(configuration.isPressed)
    }
}

private extension View {
    func clickSound(_ isPressed: Bool) -> some View {
        onChange(of: isPressed) { _, pressed in
            if pressed { SoundManager.shared.play(.click, volume: 0.6) }
        }
    }
}

struct CoinPill: View {
    let coins: Int
    var showsPlus = false

    var body: some View {
        HStack(spacing: 6) {
            Text("🪙")
            Text("\(coins)")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
            if showsPlus {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Palette.play)
            }
        }
        .foregroundStyle(Palette.ink)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(.white))
        .animation(.default, value: coins)
    }
}

struct MenuTile: View {
    let icon: String
    let title: String
    var showsBadge = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .bold))
                Text(title)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(Palette.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Palette.card)
                    .shadow(color: .black.opacity(0.12), radius: 0, x: 0, y: 4)
            )
            .overlay(alignment: .topTrailing) {
                if showsBadge {
                    Circle()
                        .fill(Palette.heartColor)
                        .frame(width: 16, height: 16)
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(PressableStyle())
    }
}
