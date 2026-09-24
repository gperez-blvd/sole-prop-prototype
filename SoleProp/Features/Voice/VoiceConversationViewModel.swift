import Foundation

enum ConversationInputMode {
    case voice
    case text
}

@Observable
final class VoiceConversationViewModel {
    var messages: [ConversationMessage] = []
    var inputMode: ConversationInputMode = .voice
    var isListening = false
    var audioLevel: Double { speech.audioLevel }
    var errorMessage: String?

    /// Set whenever Cue detects a checkout request; `HomeView` watches this
    /// and presents `CheckoutSheet`, then clears it back to nil.
    var pendingCheckout: Appointment?

    private let speech = SpeechRecognitionService()
    private let tts = ElevenLabsTTSService()
    private let player = AudioPlaybackService()
    private let assistant = MockAssistantEngine()

    func startListening() {
        Task {
            let granted = await speech.requestPermission()
            guard granted else {
                errorMessage = "Microphone and speech recognition access are needed for voice mode."
                return
            }
            do {
                isListening = true
                try speech.startListening { [weak self] finalTranscript in
                    self?.isListening = false
                    self?.handleUserUtterance(finalTranscript)
                }
            } catch {
                isListening = false
                errorMessage = error.localizedDescription
            }
        }
    }

    func stopListening() {
        speech.stopListening()
        isListening = false
    }

    /// The Home orb's tap action — start listening if idle, stop if already
    /// listening. Long-pressing the orb instead opens the full transcript
    /// (`VoiceConversationView`), which shares this same instance.
    func toggleListening() {
        isListening ? stopListening() : startListening()
    }

    func submitText(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        handleUserUtterance(text)
    }

    private func handleUserUtterance(_ text: String) {
        messages.append(ConversationMessage(role: .user, text: text))
        let reply = assistant.respond(to: text)
        messages.append(ConversationMessage(role: .assistant, text: reply))
        speak(reply)

        let lower = text.lowercased()
        if lower.contains("checkout") || lower.contains("check out") {
            pendingCheckout = HomeMockData.appointment(matching: text)
        }
    }

    private func speak(_ text: String) {
        guard ElevenLabsConfig.isConfigured else {
            messages.append(ConversationMessage(role: .system, text: "Voice reply not spoken — ElevenLabs API key isn't configured yet."))
            return
        }
        Task {
            do {
                let audio = try await tts.synthesize(text: text)
                try player.play(audio)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
