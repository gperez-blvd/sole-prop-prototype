import Foundation

struct DailyBriefRow: Identifiable {
    let id = UUID()
    /// SF Symbol shown leading the row — gives each item a recognizable
    /// shape to scan for instead of relying on reading every word, and
    /// means the list stays easy to scan as more rows are added.
    let icon: String
    let label: String
    let value: String
    let isHighlighted: Bool

    init(icon: String, label: String, value: String, isHighlighted: Bool = false) {
        self.icon = icon
        self.label = label
        self.value = value
        self.isHighlighted = isHighlighted
    }
}

/// The Brief Cue plays each morning — read out loud, shown as a visual
/// companion. Pulled from the DETAIL/CUE prototype's own `d742`
/// (morning-drive) screen.
struct DailyBrief {
    /// What it's playing through right now, e.g. "I-65 South" — shown
    /// next to a car icon as a lightweight "still listening" cue, not a
    /// label anyone needs to read closely.
    let route: String
    let greeting: String
    let rows: [DailyBriefRow]
    /// What Cue actually speaks — the same information as `rows`, in the
    /// natural spoken phrasing rather than the visual row labels.
    let spokenText: String
}
