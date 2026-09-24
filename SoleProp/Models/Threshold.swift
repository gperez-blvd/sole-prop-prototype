import Foundation

/// THRESHOLD — a rule governing what DETAIL may do without asking, e.g.
/// "lateness under 15 min: handle it, don't ask." Learned from observed
/// behavior rather than set from a settings screen — see `Proposal`, which is
/// how DETAIL asks to create or tune one.
struct Threshold: Identifiable, Hashable {
    let id = UUID()
    var ruleStatement: String
    var boundaryValue: Int
    var unit: String
    var confidence: Confidence
    var evidenceCount: Int

    enum Confidence {
        case low
        case medium
        case high
    }
}
