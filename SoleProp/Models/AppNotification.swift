import Foundation

/// One row in the notifications list reached from Home's bell icon.
/// Placeholder shape only — see `HomeMockData+Notifications.swift` for the
/// seed content and `NotificationsView` for how it renders.
struct AppNotification: Identifiable, Hashable {
    let id = UUID()
    var icon: String
    var title: String
    var detail: String
    var timestamp: Date
    var isUnread: Bool = false
}
