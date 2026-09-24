import SwiftUI

/// The queue of things DETAIL wants to surface right now — a CUE, then,
/// once she's seen it, whatever PROPOSAL followed from it. There's usually
/// just one; when there's more than one they render as a stack, with only
/// the front card live.
enum DetailMoment: Identifiable {
    case cue(Cue)
    case proposal(Proposal)

    var id: UUID {
        switch self {
        case .cue(let cue): cue.id
        case .proposal(let proposal): proposal.id
        }
    }
}

/// Renders `moments` as a stack — the front card interactive, the rest
/// peeking behind it, dimmed and inert. Dismissing the front card (by its
/// own buttons or a swipe, see `SwipeToDismissCard`) reveals the next one.
struct DetailMomentStack: View {
    var moments: [DetailMoment]
    var onDismissTop: () -> Void

    private let maxVisible = 3

    var body: some View {
        ZStack {
            ForEach(Array(moments.prefix(maxVisible).enumerated()), id: \.element.id) { index, moment in
                momentCard(for: moment)
                    .zIndex(Double(maxVisible - index))
                    .scaleEffect(1 - CGFloat(index) * 0.04, anchor: .top)
                    .offset(y: CGFloat(index) * 8)
                    .opacity(index == 0 ? 1 : 0.7)
                    .allowsHitTesting(index == 0)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: moments.map(\.id))
    }

    @ViewBuilder
    private func momentCard(for moment: DetailMoment) -> some View {
        switch moment {
        case .cue(let cue):
            SwipeToDismissCard(onDismiss: onDismissTop) { requestDismiss in
                CueCard(cue: cue, onAcknowledge: requestDismiss)
            }
        case .proposal(let proposal):
            // A proposal is a decision, not a notice — swiping can move it,
            // but only picking an option or "Not now" actually dismisses it.
            SwipeToDismissCard(onDismiss: onDismissTop, swipeToDismissEnabled: false) { requestDismiss in
                ThresholdProposalCard(
                    proposal: proposal,
                    onAccept: { _ in requestDismiss() },
                    onDecline: requestDismiss
                )
            }
        }
    }
}
