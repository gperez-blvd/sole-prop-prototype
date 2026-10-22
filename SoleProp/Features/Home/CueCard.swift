import SwiftUI

/// DETAIL speaking a CUE — one thing it noticed — plus the ACTION it
/// already took in response. Stays until she dismisses it herself, by
/// "Got it" or a swipe — never on its own.
///
/// A step past the plain card: an icon badge gives the sentence somewhere
/// to anchor visually, the "What I did" aside reads as a quiet accent rule
/// rather than a second paragraph competing with the first, and dismissal
/// is a real tactile pill rather than bare text — decorative enough to
/// have presence, simple enough to stay out of CLAUDE.md's "never a badge,
/// never a counter" territory. A milestone still gets its own warmer
/// treatment, just carried by the badge and a touch more border/wash
/// rather than an extra icon bolted onto the sentence itself.
struct CueCard: View {
    var cue: Cue
    var onAcknowledge: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                iconBadge
                Text(cue.spokenText)
                    .font(Tokens.Typography.body)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let action = cue.action {
                HStack(alignment: .top, spacing: 8) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Tokens.Color.accentBorderStrong)
                        .frame(width: 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("What I did")
                            .font(Tokens.Typography.labelSmall)
                            .foregroundStyle(Tokens.Color.accentText)
                        Text(action.description)
                            .font(Tokens.Typography.caption)
                            .foregroundStyle(Tokens.Color.textSecondary)
                    }
                }
                .padding(.leading, 2)
            }

            HStack {
                Spacer()
                Button(action: onAcknowledge) {
                    HStack(spacing: 5) {
                        Text("Got it")
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .font(Tokens.Typography.caption)
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Tokens.Color.accentTint, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Tokens.Color.surface,
                    Tokens.Color.accentTint.opacity(cue.isMilestone ? 0.4 : 0.14),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: Tokens.Radius.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.card)
                .strokeBorder(Tokens.Color.accentBorder.opacity(cue.isMilestone ? 0.5 : 0.18), lineWidth: 1)
        )
        .shadow(color: Tokens.Shadow.medium.color, radius: Tokens.Shadow.medium.radius, x: 0, y: Tokens.Shadow.medium.y)
    }

    private var iconBadge: some View {
        Image(systemName: cue.isMilestone ? "sparkle" : "quote.bubble.fill")
            .font(.system(size: 12, weight: .semibold))
            // `accentSoft`/`accentSoftTint`, not `accentText`/`accentTint`
            // — see ENGINEERING_LESSONS.md's rule on decorative icon
            // circles: the raw accent at full saturation reads neon
            // once it's filling a badge rather than a hairline border.
            // The milestone badge stays on `primaryFill` (a neutral
            // ink/white fill, not the accent hue at all), so it isn't
            // affected by this softening.
            .foregroundStyle(cue.isMilestone ? Tokens.Color.onPrimaryFill : Tokens.Color.accentSoft)
            .frame(width: 26, height: 26)
            .background(cue.isMilestone ? Tokens.Color.primaryFill : Tokens.Color.accentSoftTint, in: Circle())
    }
}

#Preview {
    VStack(spacing: 16) {
        CueCard(cue: HomeMockData.pendingCue!, onAcknowledge: {})
        CueCard(cue: Cue(spokenText: "You just booked your 100th appointment.", action: nil, isMilestone: true), onAcknowledge: {})
    }
    .padding(28)
    .background(Tokens.Color.background)
}
