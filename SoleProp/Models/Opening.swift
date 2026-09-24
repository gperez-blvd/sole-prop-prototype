import Foundation

/// OPENING — bookable empty time with a value attached. Not a cancelled
/// appointment; negative space that can be sold. Surfaced on Home as
/// revenue at risk, priced, so filling it is a decision rather than
/// something she has to notice on her own.
struct Opening: Identifiable, Hashable {
    let id = UUID()
    var slotLabel: String
    var durationMinutes: Int
    var estimatedValue: Decimal
}
