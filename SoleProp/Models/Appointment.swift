import Foundation

struct Appointment: Identifiable, Hashable {
    let id = UUID()
    let clientName: String
    let service: String
    let startTime: Date
    let durationMinutes: Int
    let isFirstTime: Bool
    let note: String?
    let price: Decimal

    var endTime: Date {
        startTime.addingTimeInterval(TimeInterval(durationMinutes * 60))
    }

    /// A playful, service-specific icon for the "<service> – <time>" line
    /// wherever an appointment is shown — chosen from SF Symbols (the same
    /// icon system every other glyph in this app already uses, so stroke
    /// weight and style stay consistent) rather than a generic calendar
    /// glyph that says nothing about what's actually happening. Matches by
    /// substring so a new service name still lands somewhere sensible
    /// rather than rendering nothing until a case is added for it.
    var serviceIcon: String {
        let name = service.lowercased()
        if name.contains("tox") || name.contains("botox") {
            return "syringe"
        } else if name.contains("filler") || name.contains("lip") {
            return "mouth"
        } else if name.contains("hydra") || name.contains("facial") {
            return "drop"
        } else if name.contains("peel") {
            return "sparkles"
        } else {
            return "hand.sparkles"
        }
    }
}
