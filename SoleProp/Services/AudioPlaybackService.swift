import AVFoundation

/// Plays back the MP3 data ElevenLabs returns.
final class AudioPlaybackService {
    private var player: AVAudioPlayer?

    func play(_ data: Data) throws {
        let player = try AVAudioPlayer(data: data)
        self.player = player
        player.play()
    }
}
