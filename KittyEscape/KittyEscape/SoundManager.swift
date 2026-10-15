import AVFoundation

final class SoundManager {
    enum Effect: String, CaseIterable {
        case pop, bump, wake, win, coin, click, unlock
        case meow1, meow2, meow3
    }

    static let shared = SoundManager()

    var soundOn = true

    var musicOn = true {
        didSet {
            if musicOn {
                startMusic()
            } else {
                music?.pause()
            }
        }
    }

    private var pools: [Effect: [AVAudioPlayer]] = [:]
    private var music: AVAudioPlayer?

    private init() {
        // Ambient: respects the silent switch and mixes with the player's own music.
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)

        for effect in Effect.allCases {
            guard let url = Self.url(for: effect.rawValue) else { continue }
            pools[effect] = (0..<4).compactMap { _ -> AVAudioPlayer? in
                guard let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
                player.enableRate = true
                player.prepareToPlay()
                return player
            }
        }

        if let url = Self.url(for: "music"),
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.numberOfLoops = -1
            player.volume = 0.3
            player.prepareToPlay()
            music = player
        }
    }

    private static func url(for name: String) -> URL? {
        Bundle.main.url(forResource: name, withExtension: "wav")
            ?? Bundle.main.url(forResource: name, withExtension: "wav", subdirectory: "Sounds")
    }

    func play(_ effect: Effect, volume: Float = 1, pitch: Float = 1) {
        guard soundOn, let pool = pools[effect],
              let player = pool.first(where: { !$0.isPlaying }) ?? pool.first else { return }
        player.volume = volume
        player.rate = pitch
        player.currentTime = 0
        player.play()
    }

    func meow() {
        play([Effect.meow1, .meow2, .meow3].randomElement() ?? .meow1, volume: 0.7)
    }

    func startMusic() {
        guard musicOn, let music, !music.isPlaying else { return }
        music.play()
    }
}
