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
                    .font(BUITokens.Typography.cardTitle)
                    .foregroundStyle(BUITokens.Color.textPrimary)
            } else {
                if let context = proposal.context {
                    Text(context.uppercased())
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(BUITokens.Color.disabled)
                        .kerning(0.6)
                }

                Text(proposal.spokenFraming)
                    .font(BUITokens.Typography.cardTitle)
                    .foregroundStyle(BUITokens.Color.textPrimary)

                HStack(spacing: 8) {
                    ForEach(proposal.options) { option in
                        optionChip(option)
                    }
                }

                HStack {
                    Button(showReasoning ? "Hide why" : "Why are you asking?") {
                        withAnimation { showReasoning.toggle() }
                    }
                    .font(.system(size: 12))
                    .foregroundStyle(BUITokens.Color.textStrong)

                    Spacer()

                    Button("Not now", action: onDecline)
                        .font(.system(size: 12))
                        .foregroundStyle(BUITokens.Color.disabled)
                }

                if showReasoning {
                    Text(proposal.finding)
                        .font(.system(size: 12))
                        .foregroundStyle(BUITokens.Color.textStrong)
                        .transition(.opacity)
                }
            }
        }
        .padding(16)
        .background(BUITokens.Color.background)
        .clipShape(RoundedRectangle(cornerRadius: BUITokens.Radius.card))
        .shadow(color: BUITokens.Shadow.medium, radius: BUITokens.Shadow.mediumRadius, x: 0, y: BUITokens.Shadow.mediumY)
    }

    private func optionChip(_ option: ThresholdOption) -> some View {
        Button {
            select(option)
        } label: {
            Text(option.label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(BUITokens.Color.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .overlay(
                    Capsule().strokeBorder(BUITokens.Color.textPrimary.opacity(0.25))
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
    .background(BUITokens.Color.background)
}
