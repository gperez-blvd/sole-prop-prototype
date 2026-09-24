import Foundation

/// A growth opportunity Cue surfaces at the end of the quarterly recap —
/// tapping one has Cue elaborate on it. DETAIL never acts on these on its
/// own; they're proposals for the operator to approve.
struct GrowthIdea: Identifiable {
    let id = UUID()
    let title: String
    let teaser: String
    let elaboration: String
}

struct QuarterlyBrief {
    let revenue: Decimal
    let clientsSeen: Int
    let newClients: Int
    let ideas: [GrowthIdea]

    var newClientFraction: String {
        "1 in \(clientsSeen / max(newClients, 1))"
    }
}
