import AVFoundation

@Observable
final class AudioPlayer {
    private var player: AVAudioPlayer?

    init() {
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
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = Float(volume)
            player?.play()
        } catch {
            assertionFailure("Failed to play audio: \(error)")
        }
    }
}
