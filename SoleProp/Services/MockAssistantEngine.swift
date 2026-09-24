import Foundation

/// Generates the assistant's replies from `HomeMockData` using simple keyword
/// matching — a stand-in for a real LLM until one is wired up. Swap this out
/// once we decide on an actual model/backend for the assistant's reasoning.
struct MockAssistantEngine {
    func respond(to query: String) -> String {
        let text = query.lowercased()

        if text.contains("next appointment") || text.contains("who's next") || text.contains("who is next") {
            guard let next = HomeMockData.nextAppointment else {
                return "You don't have any more appointments today."
            }
            let time = next.startTime.formatted(date: .omitted, time: .shortened)
            return "Your next appointment is \(next.clientName) at \(time) for \(next.service)."
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

        return "I don't have an answer for that yet — this is running on mock data, not a real model."
    }
}
