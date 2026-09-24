import AVFoundation
import Speech

enum SpeechRecognitionError: LocalizedError {
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone or speech recognition permission was denied."
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

    func requestPermission() async -> Bool {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        guard speechStatus == .authorized else { return false }

        return await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func startListening(onFinal: @escaping (String) -> Void) throws {
        guard let recognizer, recognizer.isAvailable else {
            throw SpeechRecognitionError.permissionDenied
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

        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            if let result {
                self.transcript = result.bestTranscription.formattedString
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
