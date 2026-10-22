import SwiftUI

/// First screen anyone sees. Two doors, nothing else — create an account
/// (walks into Day 0 onboarding) or log in (drops straight into Home).
///
/// The one screen in the app that gets a hero entrance rather than the
/// shared `.staggerAppear` cascade alone: "Cue" draws on using its real
/// DM Sans glyph outlines (`GlyphPathShape`, extracted via CoreText — an
/// actual vector path, the same as an SVG `<text>` turned into a
/// `<path>`) traced with `.trim(from:to:)`, the same technique an
/// animated SVG stroke-dasharray reveal uses. The traced line hands off
/// to the normal solid-filled wordmark as it finishes, then fades away.
/// Everything else on the screen (tagline, buttons, footer) still uses
/// the ordinary staggered fade used everywhere else — this one moment is
/// special-cased on purpose, not a new pattern to repeat per screen.
struct AuthLandingView: View {
    var onCreateAccount: () -> Void
    var onLogIn: () -> Void

    /// 0 = nothing traced yet, 1 = the full word is traced.
    @State private var traceProgress: CGFloat = 0
    /// The solid wordmark underneath fades in as the trace finishes
    /// rather than snapping on, so the hand-off doesn't look like a cut.
    @State private var fillOpacity: Double = 0
    /// The traced line itself fades away once the fill has fully taken
    /// over, so it doesn't linger as a stray outline.
    @State private var traceOpacity: Double = 1

    private let titleDrawDuration: Double = 1.4
    /// Everything below the title starts cascading in only once the
    /// title has mostly finished drawing, not at the same moment.
    private var contentStartDelay: Double { titleDrawDuration * 0.7 }

    private var titleFont: UIFont {
        UIFont(name: "DMSans-9ptRegular", size: 100) ?? .systemFont(ofSize: 100, weight: .semibold)
    }

    var body: some View {
        ZStack {
            AtmosphereBackground(style: .dark).ignoresSafeArea()

            VStack(spacing: Tokens.Spacing.xl) {
                Spacer()

                VStack(spacing: 8) {
                    ZStack {
                        GlyphPathShape(text: "Cue", font: titleFont)
                            .trim(from: 0, to: traceProgress)
                            .stroke(Tokens.Color.ochre, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                            .opacity(traceOpacity)

                        Text("Cue")
                            .font(.dmSans(72, weight: .semibold))
                            .foregroundStyle(Tokens.Color.fog)
                            .opacity(fillOpacity)
                    }
                    .frame(width: 220, height: 100)

                    Text("The Secret Behind Your Service")
                        .font(Tokens.Typography.body)
                        .foregroundStyle(Tokens.Color.fog.opacity(0.65))
                        .tracking(-0.2)
                        .staggerAppear(0, baseDelay: 0.12, startDelay: contentStartDelay)
                }

                Spacer()

                VStack(spacing: Tokens.Spacing.md) {
                    VStack(spacing: Tokens.Spacing.sm) {
                        PillButton(title: "Create account", style: .primaryLight, action: onCreateAccount)
                            .staggerAppear(1, baseDelay: 0.12, startDelay: contentStartDelay)
                        PillButton(title: "Log in", style: .ghostLight, action: onLogIn)
                            .staggerAppear(2, baseDelay: 0.12, startDelay: contentStartDelay)
                    }

                    Text("powered by Boulevard")
                        .font(.dmSans(14, weight: .medium))
                        .foregroundStyle(Tokens.Color.fog.opacity(0.45))
                        .staggerAppear(3, baseDelay: 0.12, startDelay: contentStartDelay)
                }
            }
            .padding(.horizontal, Tokens.Spacing.lg)
            .padding(.bottom, Tokens.Spacing.xl)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: titleDrawDuration)) {
                traceProgress = 1
            }
            withAnimation(.easeIn(duration: titleDrawDuration * 0.4).delay(titleDrawDuration * 0.55)) {
                fillOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.35).delay(titleDrawDuration + 0.05)) {
                traceOpacity = 0
            }
        }
    }
}

#Preview {
    AuthLandingView(onCreateAccount: {}, onLogIn: {})
}
