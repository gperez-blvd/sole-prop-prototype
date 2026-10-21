import SwiftUI

/// First screen anyone sees. Two doors, nothing else — create an account
/// (walks into Day 0 onboarding) or log in (drops straight into Home).
///
/// The one screen in the app that gets a hero entrance rather than the
/// shared `.staggerAppear` cascade alone: "Cue" — in the app's own DM
/// Sans, not a script face — draws itself on left-to-right behind a
/// soft-edged wipe with a thin accent "pen tip" leading the reveal and a
/// light defocus that sharpens as it resolves, so it reads as a clean,
/// modern draw-on rather than a plain fade. Everything else on the
/// screen (tagline, buttons, footer) still uses the same ordinary
/// staggered fade used everywhere else — this one moment is special-cased
/// on purpose, not a new pattern to repeat per screen.
struct AuthLandingView: View {
    var onCreateAccount: () -> Void
    var onLogIn: () -> Void

    /// 0 = nothing drawn yet, 1 = fully revealed.
    @State private var titleReveal: CGFloat = 0

    private let titleDrawDuration: Double = 1.1
    /// Everything below the title starts cascading in only once the
    /// title has mostly finished drawing, not at the same moment.
    private var contentStartDelay: Double { titleDrawDuration * 0.65 }

    var body: some View {
        ZStack {
            AtmosphereBackground(style: .dark).ignoresSafeArea()

            VStack(spacing: Tokens.Spacing.xl) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Cue")
                        .font(.dmSans(72, weight: .semibold))
                        .foregroundStyle(Tokens.Color.fog)
                        .blur(radius: (1 - titleReveal) * 3)
                        .mask(penWipeMask)
                        .overlay(alignment: .leading) { penTip }
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
                        .font(.dmSans(11, weight: .medium))
                        .foregroundStyle(Tokens.Color.fog.opacity(0.45))
                        .staggerAppear(3, baseDelay: 0.12, startDelay: contentStartDelay)
                }
            }
            .padding(.horizontal, Tokens.Spacing.lg)
            .padding(.bottom, Tokens.Spacing.xl)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: titleDrawDuration)) {
                titleReveal = 1
            }
        }
    }

    /// A soft-edged left-to-right wipe — solid through most of the
    /// reveal, then a short gradient falloff right at the leading edge
    /// of `titleReveal` — rather than a hard clip, so the word's edge
    /// looks like it's resolving into focus rather than a window shade
    /// snapping open.
    private var penWipeMask: some View {
        GeometryReader { geo in
            LinearGradient(
                stops: [
                    .init(color: .white, location: 0),
                    .init(color: .white, location: max(0, titleReveal - 0.1)),
                    .init(color: .clear, location: min(1, titleReveal + 0.02)),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    /// A thin accent bar riding right at the reveal's leading edge — the
    /// one deliberate "being drawn" cue, since DM Sans itself has no
    /// stroke path to literally trace. Fades out once the word is fully
    /// revealed so it doesn't linger as a stray mark.
    private var penTip: some View {
        GeometryReader { geo in
            Capsule()
                .fill(Tokens.Color.ochre)
                .frame(width: 3, height: geo.size.height * 0.7)
                .position(x: geo.size.width * titleReveal, y: geo.size.height / 2)
                .opacity(titleReveal < 0.97 ? 1 : 0)
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    AuthLandingView(onCreateAccount: {}, onLogIn: {})
}
