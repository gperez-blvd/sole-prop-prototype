import Foundation

enum CuePersona: String, CaseIterable {
    case concierge
    case fixer
    case shadow
    case hype

    var displayName: String {
        switch self {
        case .concierge: return "Concierge"
        case .fixer: return "Fixer"
        case .shadow: return "Shadow"
        case .hype: return "Hype"
        }
    }
}

enum ClientSource: String, CaseIterable, Identifiable {
    case instagram
    case contacts
    case file

    var id: String { rawValue }
}

struct MigrationReviewItem: Identifiable {
    let id: String
    let category: String
    let title: String
    let detail: String
    let suggestion: String
}

/// Shared state threaded through the Day 0 onboarding flow: Welcome → Searching
/// → Found → Clients → Live (Home), plus the sub-flows reached only from Home —
/// Book, Connect your calendar, Bring data from somewhere else, and Customize
/// your Cues. Nothing below Home is a corridor; each is a door she may or may
/// not open.
@Observable
final class OnboardingState {
    var name: String = "Jazz Aesthetics"
    var instagram: String = "@jazzaesthetics"
    var phone: String = "(615) 555-0148"

    // Clients
    var selectedClientSources: Set<ClientSource> = [.instagram]
    var importedClientSources: Set<ClientSource> = []
    var clientsImportRun: Bool = false

    var clientCount: Int {
        var n = 0
        if importedClientSources.contains(.instagram) { n += 2_000 }
        if importedClientSources.contains(.contacts) { n += 368 }
        if importedClientSources.contains(.file) { n += 212 }
        if migrationDone { n += 412 }
        return n
    }

    // Home / live
    var bookingLinkShared: Bool = false
    var helloSpoken: Bool = false

    // Calendar
    var googleCalendarConnected: Bool = false
    var iCalConnected: Bool = false

    // Bring data from somewhere else
    var migrationProvider: String?
    var migrationConnected: Bool = false
    var migrationExtracted: Bool = false
    var migrationDone: Bool = false
    var acceptedReviewIDs: Set<String> = []

    // A fact Boulevard discovered from the migrated data, not asked for up
    // front — surfaces only as a review item once she's brought her history over.
    var microneedlingAdded: Bool { acceptedReviewIDs.contains("svc") }

    // Booking
    var bookedAppointments: [String] = []

    // Cue persona
    var persona: CuePersona = .fixer

    var firstName: String {
        name.split(separator: " ").first.map(String.init) ?? name
    }

    let migrationReviewItems: [MigrationReviewItem] = [
        MigrationReviewItem(
            id: "dupe", category: "Clients",
            title: "Renee C. and Renee Castillo look like the same person",
            detail: "Both share the same phone number. One came from Instagram, the other from your old system with 14 visits.",
            suggestion: "Merge into one client and keep both histories"
        ),
        MigrationReviewItem(
            id: "svc", category: "Services",
            title: "Microneedling is not on your booking page",
            detail: "61 past bookings at $300, 45 minutes. It was never on your Linktree, so Boulevard never asked about it.",
            suggestion: "Add it to your menu at 45 min, $300"
        ),
        MigrationReviewItem(
            id: "gc", category: "Gift cards",
            title: "Gift card #4471 has no expiration date",
            detail: "$150 balance held by Tasha W. The expiration in your old system is blank.",
            suggestion: "Import with no expiration"
        ),
    ]
}
