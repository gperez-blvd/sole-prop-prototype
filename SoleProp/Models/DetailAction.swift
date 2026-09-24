import Foundation

/// ACTION — something DETAIL did on her behalf, reported inside a CUE.
/// Counterpart to CUE: a cue is what was said, an action is what was done.
struct DetailAction: Identifiable, Hashable {
    let id = UUID()
    var description: String
}
