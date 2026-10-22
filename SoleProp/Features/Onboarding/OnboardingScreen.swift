import SwiftUI

/// Common chrome for every onboarding screen — matches the same plain,
/// chrome-light pattern as the rest of the app (see `DailyBriefView`):
/// scrollable content, no header bar, no brand wordmark, no all-caps
/// section label in the corner. The one thing every onboarding screen
/// gets for free is a CTA pinned to the exact same spot at the bottom of
/// the screen, so the primary action is always reachable at the same
/// reach/thumb position regardless of how much content is above it.
struct OnboardingScreen<Content: View>: View {
    struct CTA {
        var title: String
        var style: PillButton.Style = .primary
        var isDisabled: Bool = false
        var action: () -> Void

        init(_ title: String, style: PillButton.Style = .primary, isDisabled: Bool = false, action: @escaping () -> Void) {
            self.title = title
            self.style = style
            self.isDisabled = isDisabled
            self.action = action
        }
    }

    var primaryCTA: CTA?
    /// Rendered above `primaryCTA` in the same fixed footer — a "Skip"/
    /// "Back to home" ghost action, not a second primary action.
    var secondaryCTA: CTA?
    @ViewBuilder var content: () -> Content

    private var hasFooter: Bool { primaryCTA != nil || secondaryCTA != nil }

    var body: some View {
        ZStack {
            Tokens.Color.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
                    content()
                }
                .padding(.horizontal, Tokens.Spacing.lg)
                .padding(.top, Tokens.Spacing.lg)
                // Reserves room so the last row never sits under the fixed
                // footer below.
                .padding(.bottom, hasFooter ? 110 : Tokens.Spacing.lg)
            }

            if hasFooter {
                VStack(spacing: Tokens.Spacing.sm) {
                    if let secondaryCTA {
                        PillButton(title: secondaryCTA.title, style: secondaryCTA.style, isDisabled: secondaryCTA.isDisabled, action: secondaryCTA.action)
                    }
                    if let primaryCTA {
                        PillButton(title: primaryCTA.title, style: primaryCTA.style, isDisabled: primaryCTA.isDisabled, action: primaryCTA.action)
                    }
                }
                .padding(.horizontal, Tokens.Spacing.lg)
                .padding(.top, Tokens.Spacing.sm)
                .padding(.bottom, Tokens.Spacing.xl)
                .background(
                    LinearGradient(
                        stops: [
                            .init(color: Tokens.Color.background.opacity(0), location: 0),
                            .init(color: Tokens.Color.background, location: 1),
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(height: 28)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .allowsHitTesting(false)
                )
                .background(Tokens.Color.background)
                .frame(maxHeight: .infinity, alignment: .bottom)
                // Trails slightly behind whatever's staggering in above
                // it (a screen's title/fields use index 0, 1, 2…) rather
                // than appearing at the same moment as the content —
                // this is the one footer every onboarding/auth screen
                // shares, so it's the one place this fires for free.
                .staggerAppear(0, startDelay: Tokens.Motion.Duration.quick, duration: Tokens.Motion.Duration.standard, distance: 6)
            }
        }
    }
}
