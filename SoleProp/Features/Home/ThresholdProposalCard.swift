import SwiftUI

/// DETAIL proactively raising a PROPOSAL that would tune a THRESHOLD, while
/// it's still learning her preference — e.g. "want to know at 10 minutes
/// late, or 20?" Deliberately not a settings screen: it's one question,
/// nested on today, gone as soon as she answers it once.
struct ThresholdProposalCard: View {
    var proposal: Proposal
    var onAccept: (ThresholdOption) -> Void
    var onDecline: () -> Void

    @State private var confirmedOption: ThresholdOption?
    @State private var showReasoning = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let confirmedOption {
                Text("Got it — I'll flag it at \(confirmedOption.label) late.")
                    .font(Tokens.Typography.body)
                    .foregroundStyle(Tokens.Color.fog)
            } else {
                if let context = proposal.context {
                    Text(context)
                        .font(Tokens.Typography.labelSmall)
                        .foregroundStyle(Tokens.Color.ochre)
                        .textCase(.uppercase)
                        .kerning(1.2)
                }

                Text(proposal.spokenFraming)
                    .font(Tokens.Typography.body)
                    .foregroundStyle(Tokens.Color.fog)

                HStack(spacing: 8) {
                    ForEach(proposal.options) { option in
                        optionChip(option)
                    }
                }

                HStack {
                    Button(showReasoning ? "Hide why" : "Why are you asking?") {
                        withAnimation { showReasoning.toggle() }
                    }
                    .font(Tokens.Typography.caption)
                    .foregroundStyle(Tokens.Color.silt)

                    Spacer()

                    Button("Not now", action: onDecline)
                        .font(Tokens.Typography.caption)
                        .foregroundStyle(Tokens.Color.silt.opacity(0.7))
                }

                if showReasoning {
                    Text(proposal.finding)
                        .font(Tokens.Typography.caption)
                        .foregroundStyle(Tokens.Color.silt)
                        .transition(.opacity)
                }
            }
        }
        .padding(16)
        .background(Tokens.Color.ink)
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.card)
                .strokeBorder(Color.white.opacity(0.12))
        )
    }

    private func optionChip(_ option: ThresholdOption) -> some View {
        Button {
            select(option)
        } label: {
            Text(option.label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Tokens.Color.fog)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .overlay(
                    Capsule().strokeBorder(Tokens.Color.ochre.opacity(0.7))
                )
        }
        .buttonStyle(.plain)
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
        onAccept: { _ in },
        onDecline: {}
    )
    .padding(28)
    .background(Tokens.Color.background)
}
