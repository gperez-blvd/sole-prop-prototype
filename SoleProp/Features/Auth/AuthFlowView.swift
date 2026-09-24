import SwiftUI

private enum AuthStep: Equatable {
    case landing
    case createAccount
    case logIn
}

/// Hosts the two doors before anything else: create an account (which hands
/// off to Day 0 onboarding) or log in (which drops straight into Home).
/// `onCreateAccount` fires once she authenticates on Create account;
/// `onLogIn` fires once she authenticates on Log in.
struct AuthFlowView: View {
    var onCreateAccount: () -> Void
    var onLogIn: () -> Void

    @State private var step: AuthStep = .landing

    var body: some View {
        ZStack {
            Tokens.Color.background.ignoresSafeArea()

            Group {
                switch step {
                case .landing:
                    AuthLandingView(
                        onCreateAccount: { go(.createAccount) },
                        onLogIn: { go(.logIn) }
                    )
                case .createAccount:
                    CreateAccountView(onBack: { go(.landing) }, onAuthenticated: onCreateAccount)
                case .logIn:
                    LogInView(onBack: { go(.landing) }, onLoggedIn: onLogIn)
                }
            }
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .move(edge: .trailing)),
                removal: .opacity.combined(with: .move(edge: .leading))
            ))
            .id(step)
        }
        .animation(.easeInOut(duration: 0.3), value: step)
    }

    private func go(_ next: AuthStep) {
        step = next
    }
}

#Preview {
    AuthFlowView(onCreateAccount: {}, onLogIn: {})
}
