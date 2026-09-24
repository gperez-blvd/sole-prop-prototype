import Foundation

enum ConversationInputMode {
    case voice
    case text
}

@Observable
final class VoiceConversationViewModel {
    var messages: [ConversationMessage] = []
    var inputMode: ConversationInputMode = .voice
    /// Whether the orb is switched on. While true, Cue keeps re-arming the
    /// mic after every reply — no re-tap needed between prompts. The user
    /// turns it off the same way they turned it on: tapping the orb.
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

    /// True from the moment the orb is switched on until it's switched
    /// off — spans any number of listen → reply → re-listen cycles.
    private var isEnabled = false
    /// A monotonically increasing token so a stale cycle (from before the
    /// orb was switched off) can't re-arm the mic after the fact.
    private var sessionToken = 0

    /// The orb's tap action — switches continuous listening on if it's
    /// off, or off if it's on. Long-pressing the orb instead opens the
    /// full transcript (`VoiceConversationView`), which shares this same
    /// instance.
    func toggleListening() {
        isEnabled ? stopListening() : startListening()
    }

    func startListening() {
        guard !isEnabled else { return }
        isEnabled = true
        sessionToken += 1
        listenCycle(token: sessionToken)
    }

    func stopListening() {
        isEnabled = false
        sessionToken += 1
        speech.stopListening()
        isListening = false
    }

    private func listenCycle(token: Int) {
        guard isEnabled, token == sessionToken else { return }
        Task {
            let granted = await speech.requestPermission()
            guard token == sessionToken else { return }
            guard granted else {
                errorMessage = "Microphone and speech recognition access are needed for voice mode."
                stopListening()
                return
            }
            do {
                isListening = true
                try speech.startListening { [weak self] finalTranscript in
                    guard let self, token == self.sessionToken else { return }
                    self.isListening = false
                    let trimmed = finalTranscript.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else {
                        // Silence timeout with nothing said — just keep
                        // listening rather than treating it as a command.
                        self.listenCycle(token: token)
                        return
                    }
                    Task {
                        await self.handleUserUtterance(finalTranscript)
                        self.listenCycle(token: token)
                    }
                }
            } catch {
                guard token == self.sessionToken else { return }
                isListening = false
                errorMessage = error.localizedDescription
                stopListening()
            }
        }
    }

    func submitText(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        Task { await handleUserUtterance(text) }
    }

    private func handleUserUtterance(_ text: String) async {
        messages.append(ConversationMessage(role: .user, text: text))
        let reply = assistant.respond(to: text)
        messages.append(ConversationMessage(role: .assistant, text: reply))
        await speak(reply)

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
        Task {
            do {
                try await player.play(resource: "daily-brief", withExtension: "mp3")
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    /// Cuts off the daily brief's voiceover — called when "Okay" is
    /// tapped before it finishes playing on its own.
    func skipDailyBriefAudio() {
        player.stop()
    }

    /// Called when the operator taps a growth idea on `QuarterlyBriefSheet`
    /// to hear more — logs Cue's elaboration to the transcript and speaks it,
    /// same as any other reply.
    func elaborate(on idea: GrowthIdea) {
        messages.append(ConversationMessage(role: .assistant, text: idea.elaboration))
        Task { await speak(idea.elaboration) }
    }

    private func speak(_ text: String) async {
        guard ElevenLabsConfig.isConfigured else {
            messages.append(ConversationMessage(role: .system, text: "Voice reply not spoken — ElevenLabs API key isn't configured yet."))
            return
        }
        do {
            let audio = try await tts.synthesize(text: text)
            try await player.play(audio)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
