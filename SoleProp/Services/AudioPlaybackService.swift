import AVFoundation

enum AudioPlaybackError: LocalizedError {
    case resourceNotFound(String)

    var errorDescription: String? {
        switch self {
        case .resourceNotFound(let name):
            return "Couldn't find bundled audio resource \"\(name)\"."
        }
    }
}

/// Plays back the MP3 data ElevenLabs returns, or a pre-recorded clip
/// bundled with the app (e.g. the daily brief's real voiceover).
final class AudioPlaybackService {
    private var player: AVAudioPlayer?

    func play(_ data: Data) throws {
        let player = try AVAudioPlayer(data: data)
        self.player = player
        player.play()
    }

    /// Plays a bundled audio file by name (without extension) and extension,
    /// e.g. `play(resource: "daily-brief", withExtension: "mp3")`.
    func play(resource name: String, withExtension extension: String) throws {
        guard let url = Bundle.main.url(forResource: name, withExtension: `extension`) else {
            throw AudioPlaybackError.resourceNotFound("\(name).\(`extension`)")
        }
        let player = try AVAudioPlayer(contentsOf: url)
        self.player = player
        player.play()
    }
}
