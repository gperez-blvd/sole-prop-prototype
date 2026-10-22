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
@Observable
final class AudioPlaybackService: NSObject {
    /// Live playback amplitude (0...1), updated while audio is playing —
    /// drives the orb's "Cue is talking" motion the same way `audioLevel`
    /// drives its "listening to you" motion. Zero whenever nothing's
    /// playing.
    private(set) var level: Double = 0

    private var player: AVAudioPlayer?
    private var continuation: CheckedContinuation<Void, Never>?
    private var meteringTask: Task<Void, Never>?

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
        meteringTask?.cancel()
        meteringTask = nil
        level = 0
        player?.stop()
        player = nil
        continuation?.resume()
        continuation = nil
    }

    private func play(_ player: AVAudioPlayer) async throws {
        AudioSession.activate()

        player.delegate = self
        player.isMeteringEnabled = true
        self.player = player
        player.play()
        startMetering(for: player)

        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    /// Polls the player's own metering rather than faking a level — real
    /// amplitude, so the orb's motion actually tracks what's being said
    /// (louder/quieter syllables) instead of an arbitrary animation.
    private func startMetering(for player: AVAudioPlayer) {
        meteringTask?.cancel()
        meteringTask = Task { [weak self] in
            while !Task.isCancelled {
                player.updateMeters()
                // Decibels (roughly -160...0) to a 0...1 linear-ish level —
                // -50dB and quieter reads as silence, 0dB as full.
                let decibels = player.averagePower(forChannel: 0)
                let normalized = max(0, min(1, (decibels + 50) / 50))
                await MainActor.run { self?.level = Double(normalized) }
                try? await Task.sleep(for: .milliseconds(60))
            }
        }
    }

    private func teardownMetering() {
        meteringTask?.cancel()
        meteringTask = nil
        level = 0
    }
}

extension AudioPlaybackService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        teardownMetering()
        continuation?.resume()
        continuation = nil
    }
}
