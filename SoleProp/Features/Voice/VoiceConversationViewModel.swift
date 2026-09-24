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
    /// Set alongside `pendingCheckout` when Cue's checkout scenario includes
    /// a proactive product suggestion (see `HomeMockData.checkoutRecommendation`).
    var pendingCheckoutRecommendation: RecommendedItem?
    /// Set whenever Cue detects a quarterly-recap request ("how have we
    /// been doing the last 3 months?"); `HomeView` watches this and
    /// presents `QuarterlyBriefSheet`, then clears it back to false.
    var pendingQuarterlyBrief = false

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
            let appointment = HomeMockData.appointment(matching: text)
            pendingCheckout = appointment
            pendingCheckoutRecommendation = appointment.flatMap(HomeMockData.checkoutRecommendation(for:))
        } else if (lower.contains("3 months") || lower.contains("three months") || lower.contains("quarter"))
            && (lower.contains("how") || lower.contains("doing") || lower.contains("recap") || lower.contains("go")) {
            pendingQuarterlyBrief = true
        }
    }

    /// Plays the morning Brief's real pre-recorded voiceover (not ElevenLabs
    /// — a bundled clip) and logs its spoken text to the transcript, same
    /// as any other Cue reply.
    func announceDailyBrief(_ brief: DailyBrief) {
        messages.append(ConversationMessage(role: .assistant, text: brief.spokenText))
        do {
            try player.play(resource: "daily-brief", withExtension: "mp3")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Called when the operator taps a growth idea on `QuarterlyBriefSheet`
    /// to hear more — logs Cue's elaboration to the transcript and speaks it,
    /// same as any other reply.
    func elaborate(on idea: GrowthIdea) {
        messages.append(ConversationMessage(role: .assistant, text: idea.elaboration))
        speak(idea.elaboration)
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
