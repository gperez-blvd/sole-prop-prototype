import Foundation

/// One value DETAIL could set a THRESHOLD's boundary to — e.g. "10 minutes"
/// as one of the two choices in "want to know at 10 minutes late, or 20?"
struct ThresholdOption: Identifiable, Hashable {
    let id = UUID()
    var boundaryValue: Int
    var label: String
}

/// PROPOSAL — something DETAIL recommends but won't do alone. This is the
/// `threshold_tuning` case: DETAIL is still learning the threshold's
/// boundary, so it asks rather than infers silently.
struct Proposal: Identifiable, Hashable {
    let id = UUID()
    var spokenFraming: String
    var finding: String
    var options: [ThresholdOption]
    var threshold: Threshold
}
