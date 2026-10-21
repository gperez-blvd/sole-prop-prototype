import SwiftUI

/// Log in with Apple/Google, or username + password. Any of the three drops
/// straight into Home — no onboarding, no review. Auth is fake; a short
/// delay just makes the tap feel real.
struct LogInView: View {
    var onBack: () -> Void
    var onLoggedIn: () -> Void

    @State private var username = ""
    @State private var password = ""
    @State private var isAuthenticating = false

    var body: some View {
        OnboardingScreen(
            primaryCTA: .init(
                isAuthenticating ? "Logging in…" : "Log in",
                isDisabled: username.isEmpty || password.isEmpty || isAuthenticating,
                action: authenticate
            ),
            secondaryCTA: .init("Back", style: .ghost, isDisabled: isAuthenticating, action: onBack)
        ) {
            Text("Log in")
                .font(Tokens.Typography.largeTitle)
                .foregroundStyle(Tokens.Color.textPrimary)
                .padding(.bottom, 6)

            VStack(spacing: Tokens.Spacing.sm) {
                SocialAuthButton(provider: .apple, isDisabled: isAuthenticating) {
                    authenticate()
                }
                SocialAuthButton(provider: .google, isDisabled: isAuthenticating) {
                    authenticate()
                }
            }

            Text("or")
                .font(Tokens.Typography.label)
                .foregroundStyle(Tokens.Color.textTertiary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, Tokens.Spacing.xs)

            VStack(spacing: 8) {
                OnboardingField(label: "Username", text: $username, textContentType: .username)
                OnboardingField(label: "Password", text: $password, textContentType: .password)
            }
        }
    }

    private func authenticate() {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            onLoggedIn()
        }
    }
}

#Preview {
    LogInView(onBack: {}, onLoggedIn: {})
}
