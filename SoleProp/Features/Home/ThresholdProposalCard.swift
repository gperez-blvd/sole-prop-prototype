import SwiftUI

/// DETAIL proactively raising a PROPOSAL that would tune a THRESHOLD, while
/// it's still learning her preference — e.g. "want to know at 10 minutes
/// late, or 20?" Deliberately not a settings screen: it's one question,
/// nested on today, gone as soon as she answers it once.
///
/// Simplified on purpose: this used to also carry a "Why are you asking?"
/// disclosure and a "Not now" decline action. Both are gone — a one
/// -question card that already reads as "pick one of these two things" is
/// not the place for a third, fourth path out of it, and reasoning-on
/// -demand belongs at the "Behind" tier (see CLAUDE.md), not bolted onto
/// every card that could theoretically justify itself. The only way out
/// of this card now is picking an option.
struct ThresholdProposalCard: View {
    var proposal: Proposal
    var onAccept: (ThresholdOption) -> Void

    @State private var confirmedOption: ThresholdOption?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let confirmedOption {
                Text("Got it — I'll flag it at \(confirmedOption.label) late.")
                    .font(Tokens.Typography.body)
                    .foregroundStyle(Tokens.Color.textPrimary)
            } else {
                if let context = proposal.context {
                    Text(context)
                        .font(Tokens.Typography.labelSmall)
                        .foregroundStyle(Tokens.Color.accentText)
                }

                Text(proposal.spokenFraming)
                    .font(Tokens.Typography.body)
                    .foregroundStyle(Tokens.Color.textPrimary)

                HStack(spacing: 8) {
                    ForEach(proposal.options) { option in
                        CardChoiceButton(title: option.label) {
                            select(option)
                        }
                    }
                }
            }
        }
        .cardStyle()
    }

    private func select(_ option: ThresholdOption) {
        withAnimation { confirmedOption = option }
        Task {
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            onAccept(option)
        }
    }
}

#Preview {
    ThresholdProposalCard(
        proposal: HomeMockData.pendingThresholdProposal!,
        onAccept: { _ in }
    )
    .padding(28)
    .background(Tokens.Color.background)
}
