import Foundation

/// Generates Cue's replies from `HomeMockData` using simple keyword
/// matching — a stand-in for a real LLM until one is wired up. Swap this out
/// once we decide on an actual model/backend for Cue's reasoning.
struct MockAssistantEngine {
    /// `nil` means the prompt doesn't match anything this mock data covers
    /// — Cue stays silent rather than saying so out loud every time, since
    /// with a real model behind it there'd always be *some* answer. Every
    /// match here is safe to say again: none of it depends on prior state.
    func respond(to query: String) -> String? {
        let text = query.lowercased()

        if isNextClientQuery(text) {
            return nextClientAnswer()
        }

        if text.contains("checkout") || text.contains("check out") {
            return checkoutAnswer(for: text)
        }

        if isQuarterlyRecapQuery(text) {
            return quarterlyRecapAnswer()
        }

        if text.contains("how many") && text.contains("appointment") {
            return "You have \(HomeMockData.todaysAppointments.count) appointments today."
        }

        if text.contains("schedule") || text.contains("today") {
            let names = HomeMockData.todaysAppointments.map(\.clientName).joined(separator: ", ")
            return "Today you're seeing \(names)."
        }

        if text.contains("first time") || text.contains("new client") {
            let firstTimers = HomeMockData.todaysAppointments.filter(\.isFirstTime).map(\.clientName)
            if firstTimers.isEmpty {
                return "No first-time clients today."
            }
            return "\(firstTimers.joined(separator: ", ")) — first time today."
        }

        return nil
    }

    /// Matches "when is my next client", "who's my next appointment",
    /// "next client", "who's next", etc. — anything asking who/when is next.
    private func isNextClientQuery(_ text: String) -> Bool {
        let mentionsNext = text.contains("next client") || text.contains("next appointment")
            || text.contains("who's next") || text.contains("who is next")
            || (text.contains("next") && (text.contains("who") || text.contains("when")))
        return mentionsNext
    }

    private func nextClientAnswer() -> String {
        guard let next = HomeMockData.nextAppointment else {
            return "You don't have any more appointments today."
        }

        let time = next.startTime.formatted(date: .omitted, time: .shortened)
        let countdown = timeUntil(next.startTime)
        return "Your next client is \(next.clientName) at \(time) for \(next.service) — \(countdown)."
    }

    private func checkoutAnswer(for text: String) -> String {
        guard let appointment = HomeMockData.appointment(matching: text) else {
            return "No one to check out right now."
        }
        if let recommendation = HomeMockData.checkoutRecommendation(for: appointment) {
            return "\(recommendation.reason) and I added it to the checkout for you to review."
        }
        let price = appointment.price.formatted(.currency(code: "USD"))
        return "Pulling up checkout for \(appointment.clientName) — \(appointment.service), \(price)."
    }

    /// Matches "how have we been doing the last 3 months", "how did this
    /// quarter go", "last quarter", etc.
    private func isQuarterlyRecapQuery(_ text: String) -> Bool {
        (text.contains("3 months") || text.contains("three months") || text.contains("quarter"))
            && (text.contains("how") || text.contains("doing") || text.contains("recap") || text.contains("go"))
    }

    private func quarterlyRecapAnswer() -> String {
        let brief = HomeMockData.quarterlyBrief
        let revenue = brief.revenue.formatted(.currency(code: "USD").precision(.fractionLength(0)))
        return """
        You had a great 3 months. Here's a recap.

        You made \(revenue), saw \(brief.clientsSeen) clients, \(brief.newClients) of which were new. That's \(brief.newClientFraction) and is no small feat. Based on your ratings and reviews from those customers, I think we can safely say they're about to be your regulars!

        I have a few ideas for your business for next quarter. Which one of these would you like to hear more about?
        """
    }

    /// "in 45 minutes", "in 1 hour, 20 minutes", "starting now", "running late — started 10 minutes ago".
    private func timeUntil(_ date: Date, from now: Date = Date()) -> String {
        let seconds = date.timeIntervalSince(now)

        if seconds <= 60 && seconds >= -60 {
            return "starting now"
        }

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        formatter.maximumUnitCount = 2

        let duration = formatter.string(from: abs(seconds)) ?? "a bit"

        if seconds > 0 {
            return "that's in \(duration)"
        } else {
            return "that started \(duration) ago"
        }
    }
}
