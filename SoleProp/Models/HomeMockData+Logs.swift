import Foundation

/// Placeholder content for `LogsView` — the audit trail CLAUDE.md's
/// "Behind" tier describes, in her words, not the underlying object
/// model's. Not stage-dependent; this is the list's shape, not today's.
extension HomeMockData {
    static var activityLog: [LogEntry] {
        let now = Date()
        let calendar = Calendar.current
        return [
            LogEntry(text: "Let Priya S. know you're running a few minutes behind.", timestamp: calendar.date(byAdding: .minute, value: -12, to: now) ?? now),
            LogEntry(text: "Moved your cleanup window after your 1:30 ran late.", timestamp: calendar.date(byAdding: .hour, value: -2, to: now) ?? now),
            LogEntry(text: "Texted Dani R. to confirm her move to Friday.", timestamp: calendar.date(byAdding: .hour, value: -3, to: now) ?? now),
            LogEntry(text: "Sent a follow-up after yesterday's consult.", timestamp: calendar.date(byAdding: .day, value: -1, to: now) ?? now),
            LogEntry(text: "Reminded Maya K. about her first tox appointment.", timestamp: calendar.date(byAdding: .day, value: -1, to: now) ?? now),
            LogEntry(text: "Held your 90-minute opening for a walk-in call.", timestamp: calendar.date(byAdding: .day, value: -2, to: now) ?? now),
        ]
    }
}
