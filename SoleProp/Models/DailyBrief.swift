import Foundation

struct DailyBriefRow: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let isHighlighted: Bool

    init(label: String, value: String, isHighlighted: Bool = false) {
        self.label = label
        self.value = value
        self.isHighlighted = isHighlighted
    }
}

/// The car-mode Brief Cue plays each morning — read out loud, shown as a
/// visual companion. Pulled from the DETAIL/CUE prototype's own `d742`
/// (morning-drive) screen.
struct DailyBrief {
    let route: String
    let greeting: String
    let rows: [DailyBriefRow]
    /// What Cue actually speaks — the same information as `rows`, in the
    /// natural spoken phrasing rather than the visual row labels.
    let spokenText: String
}
