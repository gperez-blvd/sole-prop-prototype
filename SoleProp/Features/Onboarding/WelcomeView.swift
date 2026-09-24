import SwiftUI

struct WelcomeView: View {
    var state: OnboardingState
    var onContinue: () -> Void

    var body: some View {
        OnboardingScreen(section: "Welcome") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome to Boulevard")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Tokens.Color.textPrimary)
                Text("The Secret Behind Your Service")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .tracking(-0.2)
            }
            .padding(.bottom, 6)

            VStack(spacing: 0) {
                OnboardingField(label: "Your name", text: Binding(get: { state.name }, set: { state.name = $0 }))
                OnboardingField(
                    label: "Instagram", text: Binding(get: { state.instagram }, set: { state.instagram = $0 }),
                    keyboardType: .default
                )
                OnboardingField(
                    label: "Mobile", text: Binding(get: { state.phone }, set: { state.phone = $0 }),
                    keyboardType: .phonePad, textContentType: .telephoneNumber
                )
            }

            PillButton(title: "Find my business", action: onContinue)
                .padding(.top, Tokens.Spacing.md)
        }
    }
}

#Preview {
    WelcomeView(state: OnboardingState(), onContinue: {})
}
