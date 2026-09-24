import Foundation

enum MicroneedlingAnswer {
    case yes
    case no
}

/// Shared state threaded through the five Day 0 onboarding screens.
@Observable
final class OnboardingState {
    var name: String = "Jazz Aesthetics"
    var instagram: String = "@jazzaesthetics"
    var phone: String = "(615) 555-0148"

    var microneedling: MicroneedlingAnswer?
    var clientsImported: Bool = false
    var bookingLinkShared: Bool = false

    var firstName: String {
        name.split(separator: " ").first.map(String.init) ?? name
    }
}
