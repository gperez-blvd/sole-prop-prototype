import SwiftUI

/// Common chrome for every onboarding screen — the `Boulevard` header, a
/// scrollable content area, and consistent side padding (the reference's
/// `.view` container).
struct OnboardingScreen<Content: View>: View {
    var section: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            OnboardingHeader(section: section)
                .padding(.top, Tokens.Spacing.lg)

            ScrollView {
                VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
                    content()
                }
                .padding(.bottom, Tokens.Spacing.lg)
            }
        }
        .padding(.horizontal, Tokens.Spacing.lg)
    }
}
