import SwiftUI

/// Create account with Apple or Google. There's no password to set and
/// nothing to review — whichever she taps opens straight into Day 0
/// onboarding. Auth is fake; a short delay just makes the tap feel real.
struct CreateAccountView: View {
    var onBack: () -> Void
    var onAuthenticated: () -> Void

    @State private var isAuthenticating = false

    var body: some View {
        OnboardingScreen(section: "Create account") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Create your account")
                    .font(Tokens.Typography.largeTitle)
                    .foregroundStyle(Tokens.Color.textPrimary)
                Text("We'll use this to find your business next.")
                    .font(Tokens.Typography.body)
                    .foregroundStyle(Tokens.Color.textSecondary)
            }
            .padding(.bottom, 6)

            VStack(spacing: Tokens.Spacing.sm) {
                SocialAuthButton(provider: .apple, isDisabled: isAuthenticating) {
                    authenticate()
                }
                SocialAuthButton(provider: .google, isDisabled: isAuthenticating) {
                    authenticate()
                }
            }
            .padding(.top, Tokens.Spacing.md)

            PillButton(title: "Back", style: .ghost, isDisabled: isAuthenticating, action: onBack)
                .padding(.top, Tokens.Spacing.sm)
        }
    }

    private func authenticate() {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            onAuthenticated()
        }
    }
}

#Preview {
    CreateAccountView(onBack: {}, onAuthenticated: {})
}
