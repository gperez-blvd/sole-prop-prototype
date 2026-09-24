import SwiftUI

/// A full-width outlined pill for "Continue with Apple/Google" — same shape as
/// `PillButton.ghost`, with a leading mark. Kept monochrome (ink on fog) to match
/// the rest of the auth chrome rather than each provider's brand color.
struct SocialAuthButton: View {
    enum Provider {
        case apple
        case google

        var label: String {
            switch self {
            case .apple: return "Continue with Apple"
            case .google: return "Continue with Google"
            }
        }
    }

    var provider: Provider
    var isDisabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                mark
                Text(provider.label)
                    .font(Tokens.Typography.button)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .foregroundStyle(Tokens.Color.ink)
        .overlay(
            Capsule().strokeBorder(Tokens.Color.ink.opacity(0.4), lineWidth: 1)
        )
        .opacity(isDisabled ? 0.4 : 1)
        .disabled(isDisabled)
    }

    @ViewBuilder
    private var mark: some View {
        switch provider {
        case .apple:
            Image(systemName: "apple.logo")
                .font(.system(size: 15, weight: .medium))
        case .google:
            Text("G")
                .font(.system(size: 14, weight: .bold, design: .rounded))
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SocialAuthButton(provider: .apple, action: {})
        SocialAuthButton(provider: .google, action: {})
    }
    .padding()
    .background(Tokens.Color.background)
}
