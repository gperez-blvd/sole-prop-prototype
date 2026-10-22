import Foundation

/// Placeholder content for `NotificationsView` — enough to show the list's
/// shape and a believable mix of types, not a real notification feed.
/// Stage-independent on purpose, same reasoning as `clientDirectory`: this
/// is what the list looks like, not what today produced.
extension HomeMockData {
    static var notificationFeed: [AppNotification] {
        let now = Date()
        let calendar = Calendar.current
        return [
            AppNotification(
                icon: "calendar.badge.exclamationmark",
                title: "Dani R. rescheduled",
                detail: "Moved from Thursday to Friday at 2:00 pm.",
                timestamp: calendar.date(byAdding: .minute, value: -18, to: now) ?? now,
                isUnread: true
            ),
            AppNotification(
                icon: "dollarsign.circle",
                title: "Your money lands Thursday",
                detail: "$1,240 from this week's appointments.",
                timestamp: calendar.date(byAdding: .hour, value: -3, to: now) ?? now,
                isUnread: true
            ),
            AppNotification(
                icon: "star",
                title: "Tasha W. left a review",
                detail: "\"Best HydraFacial I've had — already booked my next one.\"",
                timestamp: calendar.date(byAdding: .hour, value: -6, to: now) ?? now
            ),
            AppNotification(
                icon: "checkmark.circle",
                title: "Maya confirmed her 11:00",
                detail: "First-time tox, referred by Dani.",
                timestamp: calendar.date(byAdding: .day, value: -1, to: now) ?? now
            ),
            AppNotification(
                icon: "person.crop.circle.badge.plus",
                title: "A new client found you",
                detail: "Priya S. booked through your booking link.",
                timestamp: calendar.date(byAdding: .day, value: -2, to: now) ?? now
            ),
        ]
    }
}
