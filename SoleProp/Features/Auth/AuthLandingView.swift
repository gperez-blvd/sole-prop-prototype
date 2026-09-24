import SwiftUI

/// First screen anyone sees. Two doors, nothing else — create an account
/// (walks into Day 0 onboarding) or log in (drops straight into Home).
struct AuthLandingView: View {
    var onCreateAccount: () -> Void
    var onLogIn: () -> Void

    var body: some View {
        ZStack {
            Tokens.Color.background.ignoresSafeArea()

            VStack(spacing: Tokens.Spacing.xl) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Boulevard")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(Tokens.Color.textPrimary)
                    Text("The Secret Behind Your Service")
                        .font(Tokens.Typography.body)
                        .foregroundStyle(Tokens.Color.textSecondary)
                        .tracking(-0.2)
                }

                Spacer()

                VStack(spacing: Tokens.Spacing.sm) {
                    PillButton(title: "Create account", action: onCreateAccount)
                    PillButton(title: "Log in", style: .ghost, action: onLogIn)
                }
            }
            .padding(.horizontal, Tokens.Spacing.lg)
            .padding(.bottom, Tokens.Spacing.xl)
        }
    }
}

#Preview {
    AuthLandingView(onCreateAccount: {}, onLogIn: {})
}
