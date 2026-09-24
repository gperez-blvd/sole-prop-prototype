import Foundation

/// CUE — one thing DETAIL said. Its core content is a single sentence;
/// everything else about it is relationship — here, the ACTION it reports.
struct Cue: Identifiable, Hashable {
    let id = UUID()
    var spokenText: String
    var action: DetailAction?

    /// Type `milestone` — a first-of-its-kind moment (first booking, Nth
    /// appointment) worth a small visual beat on Home rather than only
    /// being spoken and gone. Everything else about the card is identical.
    var isMilestone: Bool = false
}
