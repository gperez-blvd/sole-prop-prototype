import SwiftUI

/// DETAIL speaking a CUE — one thing it noticed — plus the ACTION it
/// already took in response. Stays until she dismisses it herself, by
/// "Got it" or a swipe — never on its own.
struct CueCard: View {
    var cue: Cue
    var onAcknowledge: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 8) {
                if cue.isMilestone {
                    Image(systemName: "sparkle")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Tokens.Color.ochre)
                        .padding(.top, 2)
                }
                Text(cue.spokenText)
                    .font(Tokens.Typography.body)
                    .foregroundStyle(Tokens.Color.textPrimary)
            }

            if let action = cue.action {
                VStack(alignment: .leading, spacing: 4) {
                    Text("What I did")
                        .font(Tokens.Typography.labelSmall)
                        .foregroundStyle(Tokens.Color.textTertiary)
                        .textCase(.uppercase)
                        .kerning(1.2)
                    Text(action.description)
                        .font(Tokens.Typography.caption)
                        .foregroundStyle(Tokens.Color.textSecondary)
                }
            }

            HStack {
                Spacer()
                Button("Got it", action: onAcknowledge)
                    .font(Tokens.Typography.caption)
                    .foregroundStyle(Tokens.Color.textSecondary)
            }
        }
        .padding(16)
        .background(Tokens.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.card)
                .strokeBorder(Tokens.Color.hairline)
        )
    }
}

#Preview {
    CueCard(cue: HomeMockData.pendingCue!, onAcknowledge: {})
        .padding(28)
        .background(Tokens.Color.background)
}
