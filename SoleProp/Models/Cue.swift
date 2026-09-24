import Foundation

/// CUE — one thing DETAIL said. Its core content is a single sentence;
/// everything else about it is relationship — here, the ACTION it reports.
struct Cue: Identifiable, Hashable {
    let id = UUID()
    var spokenText: String
    var action: DetailAction?
}
