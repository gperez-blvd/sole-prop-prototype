import Foundation

/// A product Cue proactively adds to a checkout, flagged for the operator to
/// review rather than silently included. Mock-only for now — tied to the
/// "Checkout Tasha" demo scenario in `MockAssistantEngine`.
struct RecommendedItem: Identifiable {
    let id = UUID()
    let name: String
    let price: Decimal
    let reason: String
}
