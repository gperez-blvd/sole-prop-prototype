import AVFoundation

/// One persistent `AVAudioSession` configuration, shared by
/// `SpeechRecognitionService` and `AudioPlaybackService`, activated once
/// and never touched again — rather than switching category between
/// `.playAndRecord` (to listen) and `.playback` (to speak) every single
/// turn, the way both services used to.
///
/// Changing a session's category/activation is a real audio-route
/// reconfiguration, not a flag flip — iOS tears down and rebuilds the
/// audio I/O graph. That normally settles in well under 100ms, so
/// switching it twice per exchange was never obviously broken in
/// everyday testing. It falls apart the moment something else holds an
/// audio tap on the device — recording or mirroring the screen (e.g.
/// QuickTime) — which makes every route change far slower and less
/// predictable. Playback was starting (`player.play()`) before the
/// route had actually finished reconnecting, so the first portion of
/// Cue's reply played into a sink that wasn't live yet: it sounded like
/// the reply came in late, already half spoken, or only caught its
/// last word. `.voiceChat` mode is the one Apple designs for exactly
/// this call-and-response shape — alternating recording and playback on
/// the same session — rather than `.measurement` (tuned for recording
/// alone) or `.default` (tuned for playback alone).
enum AudioSession {
    private static var isConfigured = false

    static func activate() {
        guard !isConfigured else { return }
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .voiceChat, options: [.duckOthers, .defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
            isConfigured = true
        } catch {
            // Leave `isConfigured` false — the next listen/speak call
            // retries instead of silently assuming this one succeeded.
        }
    }
}
