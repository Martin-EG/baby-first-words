import AVFoundation

@Observable
final class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    /// Gap after a word finishes before another play request is honored —
    /// stops a toddler's rapid re-taps from chopping the word into overlapping bits.
    private static let cooldown: TimeInterval = 1.5

    private(set) var isPlaying = false
    private var player: AVAudioPlayer?

    override init() {
        super.init()
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func play(word: Word, language: AppLanguage, volume: Double) {
        let folder = language == .english ? "en" : "es"
        let fileName = word.audioFileName(for: language)
        guard let url = Bundle.main.url(
            forResource: (fileName as NSString).deletingPathExtension,
            withExtension: (fileName as NSString).pathExtension,
            subdirectory: "Audio/\(folder)"
        ) else {
            assertionFailure("Missing audio file: Audio/\(folder)/\(fileName)")
            return
        }
        play(fileAt: url, volume: volume)
    }

    /// Plays an arbitrary audio file on disk — used for parent-recorded
    /// family voices, which live outside the app bundle. Ignored while a
    /// word is already playing or still in its post-playback cooldown.
    func play(fileAt url: URL, volume: Double) {
        guard !isPlaying else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.volume = Float(volume)
            player?.play()
            isPlaying = true
        } catch {
            assertionFailure("Failed to play audio at \(url): \(error)")
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.cooldown) { [weak self] in
            self?.isPlaying = false
        }
    }
}
