import AVFoundation
import Speech

enum SpeechRecognitionError: LocalizedError {
    case speechRecognitionDenied
    case microphoneDenied
    case recognizerUnavailable

    var errorDescription: String? {
        switch self {
        case .speechRecognitionDenied:
            return "Speech Recognition is off for this app. Settings > Privacy & Security > Speech Recognition > Sole Prop Prototype."
        case .microphoneDenied:
            return "Microphone access is off for this app. Settings > Privacy & Security > Microphone > Sole Prop Prototype."
        case .recognizerUnavailable:
            return "Speech recognition isn't available right now (no recognizer for this locale, or Siri/Dictation is disabled on this device)."
        }
    }
}

/// On-device speech-to-text and live mic amplitude, used to both transcribe
/// what the user says and drive the voice orb's reactive animation. Kept
/// separate from ElevenLabs — that service only handles the assistant's
/// spoken replies (text-to-speech).
@Observable
final class SpeechRecognitionService: NSObject {
    private(set) var transcript: String = ""
    private(set) var audioLevel: Double = 0
    private(set) var isListening = false

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var onFinalCallback: ((String) -> Void)?
    private var didFinalize = false
    private var lastResultAt = Date.distantPast
    private var watchdogGeneration = 0

    /// Checks/requests both permissions Speech needs — they're separate iOS
    /// settings (Microphone and Speech Recognition), and it's easy for only
    /// one to be granted without noticing, which silently breaks listening
    /// with no obvious symptom beyond "nothing happens." Throws instead of
    /// returning a bare Bool so the caller can tell the operator which one.
    ///
    /// Checks the current status first and only calls the OS's `request*`
    /// APIs when it's genuinely undetermined — continuous listening calls
    /// this once per cycle (every few seconds), and re-prompting an already
    /// -decided permission on every cycle is both pointless and, on device,
    /// adds a noticeable stall before the mic re-engages.
    func requestPermission() async throws {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            break
        case .notDetermined:
            let status = await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    continuation.resume(returning: status)
                }
            }
            guard status == .authorized else {
                throw SpeechRecognitionError.speechRecognitionDenied
            }
        case .denied, .restricted:
            throw SpeechRecognitionError.speechRecognitionDenied
        @unknown default:
            throw SpeechRecognitionError.speechRecognitionDenied
        }

        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            break
        case .undetermined:
            let granted = await withCheckedContinuation { continuation in
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
            guard granted else {
                throw SpeechRecognitionError.microphoneDenied
            }
        case .denied:
            throw SpeechRecognitionError.microphoneDenied
        @unknown default:
            throw SpeechRecognitionError.microphoneDenied
        }
    }

    func startListening(onFinal: @escaping (String) -> Void) throws {
        guard let recognizer, recognizer.isAvailable else {
            throw SpeechRecognitionError.recognizerUnavailable
        }

        transcript = ""
        didFinalize = false
        onFinalCallback = onFinal
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.request = request

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
        try session.setActive(true)

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.request?.append(buffer)
            self?.updateLevel(from: buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        isListening = true
        lastResultAt = Date()
        watchdogGeneration += 1
        startSilenceWatchdog(generation: watchdogGeneration)

        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            if let result {
                self.transcript = result.bestTranscription.formattedString
                self.lastResultAt = Date()
                if result.isFinal {
                    self.finish()
                }
            }
            if error != nil {
                // Errors here are routinely just "recognition request was
                // cancelled" once we've already finished — finish() is a
                // no-op by then. When they arrive first, this still hands
                // back whatever partial transcript was captured instead of
                // dropping it.
                self.finish()
            }
        }
    }

    /// iOS's own silence-based `isFinal` didn't reliably fire for short,
    /// one-off commands during on-device testing — recognition would keep
    /// the mic open indefinitely with a correct partial transcript that
    /// never got handed off. This finalizes on our own schedule instead of
    /// depending solely on that: soon after speech stops once something's
    /// been said, or after a longer cap if nothing was ever heard at all
    /// (letting continuous listening's empty-transcript cycle restart
    /// rather than listening forever).
    private func startSilenceWatchdog(generation: Int) {
        Task { [weak self] in
            while true {
                try? await Task.sleep(for: .milliseconds(250))
                guard let self, generation == self.watchdogGeneration, !self.didFinalize else { return }
                let quiet = Date().timeIntervalSince(self.lastResultAt)
                let hasSpeech = !self.transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                if (hasSpeech && quiet > 1.2) || quiet > 8 {
                    self.finish()
                    return
                }
            }
        }
    }

    /// The orb's "tap to stop" action. On-device speech recognition only
    /// calls the recognizer's own completion with `isFinal` after it
    /// detects a pause — a deliberate manual stop needs to finalize
    /// whatever's been transcribed so far itself, or everything the user
    /// just said gets silently discarded.
    func stopListening() {
        finish()
    }

    private func finish() {
        guard isListening, !didFinalize else { return }
        didFinalize = true
        let finalText = transcript
        let callback = onFinalCallback
        teardownAudio()
        // Always report back, even an empty transcript (silence timeout) —
        // continuous listening needs to know a session ended either way so
        // it can restart the mic instead of going silent forever.
        callback?(finalText)
    }

    private func teardownAudio() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        task = nil
        request = nil
        onFinalCallback = nil
        isListening = false
        audioLevel = 0
    }

    private func updateLevel(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)
        var sum: Float = 0
        for i in 0..<frameCount { sum += channelData[i] * channelData[i] }
        let rms = frameCount > 0 ? sqrt(sum / Float(frameCount)) : 0
        let normalized = min(1, Double(rms) * 12)
        Task { @MainActor [weak self] in
            self?.audioLevel = normalized
        }
    }
}
