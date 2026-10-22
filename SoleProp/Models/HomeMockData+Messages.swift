import Foundation

/// Placeholder content for `MessagesView` — enough to show the list's
/// shape, not a real messaging thread store. Stage-independent on purpose,
/// same reasoning as `clientDirectory`.
extension HomeMockData {
    static var messageThreads: [ClientMessage] {
        let now = Date()
        let calendar = Calendar.current
        return [
            ClientMessage(
                clientName: "Priya S.",
                preview: "Running about 10 minutes behind, sorry!",
                timestamp: calendar.date(byAdding: .minute, value: -6, to: now) ?? now,
                isUnread: true
            ),
            ClientMessage(
                clientName: "Dani R.",
                preview: "Can we do Friday at 2 instead?",
                timestamp: calendar.date(byAdding: .hour, value: -1, to: now) ?? now,
                isUnread: true
            ),
            ClientMessage(
                clientName: "Tasha W.",
                preview: "Thank you, see you in five weeks!",
                timestamp: calendar.date(byAdding: .day, value: -1, to: now) ?? now
            ),
            ClientMessage(
                clientName: "Maya K.",
                preview: "Is there anything I should do before my appointment?",
                timestamp: calendar.date(byAdding: .day, value: -2, to: now) ?? now
            ),
        ]
    }
}
