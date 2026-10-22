import Foundation

/// One line in the Logs screen's activity feed — "what I did," in her
/// words, with nothing underneath it to drill into yet. Placeholder
/// shape only — see `HomeMockData+Logs.swift` for seed content.
struct LogEntry: Identifiable, Hashable {
    let id = UUID()
    var text: String
    var timestamp: Date
}
