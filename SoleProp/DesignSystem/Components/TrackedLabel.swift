import SwiftUI

/// The reference's small uppercase mono label (`.lbl`, `.lb`, `.src`) — used for
/// field labels, section headers, and source tags throughout onboarding.
struct TrackedLabel: View {
    var text: String
    var font: Font = Tokens.Typography.label
    var color: Color = Tokens.Color.textTertiary

    var body: some View {
        Text(text.uppercased())
            .font(font)
            .foregroundStyle(color)
            .kerning(1.4)
    }
}

/// `Boulevard` bold wordmark + a right-aligned tracked section name — the
/// `hdr()` treatment reused at the top of every onboarding screen.
struct OnboardingHeader: View {
    var section: String

    var body: some View {
        HStack {
            Text("Boulevard")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Tokens.Color.textPrimary)
            Spacer()
            TrackedLabel(text: section)
        }
    }
}
