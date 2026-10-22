import SwiftUI

/// DETAIL speaking a CUE — one thing it noticed — plus the ACTION it
/// already took in response. Stays until she dismisses it herself, by
/// "Got it" or a swipe — never on its own.
///
/// **A transparency bug worth keeping as a lesson:** the previous version's
/// background was a `LinearGradient` from `Tokens.Color.surface` to
/// `Tokens.Color.accentTint.opacity(0.14)`. `accentTint` is itself already
/// `ochre.opacity(0.12)` — stacking a second `.opacity()` on an already
/// -translucent color compounds down to roughly 0.017 alpha, which reads as
/// "this corner of the card is just... see-through." That's exactly what
/// it looked like: the stacked card behind it (see `DetailMomentStack`)
/// bleeding through the front card's own body, not merely peeking around
/// its edges. The fix below never blends an already-translucent color
/// into a gradient stop; the base fill is a single fully-opaque neutral
/// color, full stop, and the only thing layered on top of it is a sheen
/// `overlay` that fades to `.clear` — fading an *overlay* to transparent
/// just reveals the opaque base under it, which is a completely different
/// thing from a base color itself having near-zero alpha.
///
/// Redesigned for a more actionable, contrasting read: a solid neutral
/// surface (not an accent-tinted wash) with a very soft diagonal sheen —
/// metallic in spirit, deliberately restrained in execution so it reads as
/// "considered" rather than "shiny." No border, no side accent rule. The
/// icon is a plain line glyph with no badge chip around it, so it sits
/// flush in the card rather than floating on top of it; the dismiss
/// action uses the same `CardChoiceButton` teal treatment as
/// `ThresholdProposalCard`'s options, rather than each card inventing
/// its own idea of what a CTA looks like.
struct CueCard: View {
    var cue: Cue
    var onAcknowledge: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: cue.isMilestone ? "sparkle" : "quote.bubble.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Tokens.Color.accentSoft)
                    .frame(width: 20, alignment: .center)
                    .padding(.top, 1)
                Text(cue.spokenText)
                    .font(Tokens.Typography.body)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let action = cue.action {
                VStack(alignment: .leading, spacing: 2) {
                    Text("What I did")
                        .font(Tokens.Typography.labelSmall)
                        .foregroundStyle(Tokens.Color.textTertiary)
                    Text(action.description)
                        .font(Tokens.Typography.caption)
                        .foregroundStyle(Tokens.Color.textSecondary)
                }
                .padding(.leading, 30)
            }

            HStack {
                Spacer()
                CardChoiceButton(title: "Got it", trailingIcon: "checkmark", action: onAcknowledge)
            }
        }
        .padding(16)
        .background(
            // A single fully-opaque neutral fill — never a gradient
            // toward a translucent color. See the type-level note above.
            Tokens.Color.surface,
            in: RoundedRectangle(cornerRadius: Tokens.Radius.card)
        )
        .overlay(sheen)
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.card))
        .shadow(
            color: Tokens.Shadow.medium.color,
            radius: cue.isMilestone ? Tokens.Shadow.high.radius : Tokens.Shadow.medium.radius,
            x: 0,
            y: cue.isMilestone ? Tokens.Shadow.high.y : Tokens.Shadow.medium.y
        )
    }

    /// The "metallic" part, kept deliberately quiet: a soft diagonal
    /// highlight that fades to fully `.clear` well before the opposite
    /// corner, over a `.plusLighter` blend so it can only ever brighten
    /// the surface under it, never darken or desaturate it. A milestone
    /// gets a touch more of it — still restrained, just a little brighter
    /// — rather than a different color altogether.
    private var sheen: some View {
        LinearGradient(
            stops: [
                .init(color: .white.opacity(cue.isMilestone ? 0.10 : 0.06), location: 0),
                .init(color: .white.opacity(0), location: 0.45),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .blendMode(.plusLighter)
        .allowsHitTesting(false)
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
