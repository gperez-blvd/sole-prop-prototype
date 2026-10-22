import Foundation

/// One thread preview in the messages list reached from Home's message
/// icon. Placeholder shape only — see `HomeMockData+Messages.swift` for the
/// seed content and `MessagesView` for how it renders.
struct ClientMessage: Identifiable, Hashable {
    let id = UUID()
    var clientName: String
    var preview: String
    var timestamp: Date
    var isUnread: Bool = false
}
