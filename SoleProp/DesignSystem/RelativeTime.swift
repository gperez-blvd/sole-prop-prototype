import Foundation

/// A single shared relative-time label ("6m", "3h", "Yesterday", a short
/// date) for any list row that needs one — notifications and messages
/// today, anything else later — rather than each screen formatting dates
/// its own way.
enum RelativeTime {
    static func label(for date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        let minutes = Int(seconds / 60)
        let hours = Int(seconds / 3600)

        if minutes < 1 {
            return "Now"
        } else if minutes < 60 {
            return "\(minutes)m"
        } else if hours < 24 {
            return "\(hours)h"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(.dateTime.month(.abbreviated).day())
        }
    }
}
