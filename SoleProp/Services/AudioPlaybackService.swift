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
/// bundled with the app (e.g. the daily brief's real voiceover). Both
/// `play` overloads suspend until playback finishes, so continuous
/// listening can wait for Cue to stop talking before re-arming the mic —
/// otherwise it would pick up its own reply as the next voice command.
final class AudioPlaybackService: NSObject {
    private var player: AVAudioPlayer?
    private var continuation: CheckedContinuation<Void, Never>?

    func play(_ data: Data) async throws {
        let player = try AVAudioPlayer(data: data)
        try await play(player)
    }

    func play(resource name: String, withExtension extension: String) async throws {
        guard let url = Bundle.main.url(forResource: name, withExtension: `extension`) else {
            throw AudioPlaybackError.resourceNotFound("\(name).\(`extension`)")
        }
        let player = try AVAudioPlayer(contentsOf: url)
        try await play(player)
    }

    /// Cuts off whatever's currently playing (e.g. the daily brief's
    /// voiceover, skipped by tapping "Okay" before it finishes) and
    /// releases any `play` call still awaiting completion.
    func stop() {
        player?.stop()
        player = nil
        continuation?.resume()
        continuation = nil
    }

    private func play(_ player: AVAudioPlayer) async throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [.duckOthers])
        try session.setActive(true)

        player.delegate = self
        self.player = player
        player.play()

        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
}

extension AudioPlaybackService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        continuation?.resume()
        continuation = nil
    }
}
