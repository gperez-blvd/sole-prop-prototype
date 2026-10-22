import SwiftUI

struct WelcomeView: View {
    var state: OnboardingState
    var onContinue: () -> Void

    var body: some View {
        OnboardingScreen(primaryCTA: .init("Find my business", action: onContinue)) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome to Cue")
                    .font(Tokens.Typography.largeTitle)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .staggerAppear(0)
                Text("The secret behind your service")
                    .font(.dmSans(16, weight: .medium))
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .tracking(-0.2)
                    .staggerAppear(1)
            }
            .padding(.bottom, 6)

            VStack(spacing: 8) {
                OnboardingField(label: "Your name", text: Binding(get: { state.name }, set: { state.name = $0 }))
                    .staggerAppear(2)
                OnboardingField(
                    label: "Instagram", text: Binding(get: { state.instagram }, set: { state.instagram = $0 }),
                    keyboardType: .default
                )
                .staggerAppear(3)
                OnboardingField(
                    label: "Mobile", text: Binding(get: { state.phone }, set: { state.phone = $0 }),
                    keyboardType: .phonePad, textContentType: .telephoneNumber
                )
                .staggerAppear(4)
            }
        }
    }
}

#Preview {
    WelcomeView(state: OnboardingState(), onContinue: {})
}
