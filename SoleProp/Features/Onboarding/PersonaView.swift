import SwiftUI

/// Persona changes the delivery. Never the capability. Same intelligence,
/// same actions — only the voice changes.
struct PersonaView: View {
    var state: OnboardingState
    var onDone: () -> Void

    private let sample: [CuePersona: String] = [
        .fixer: "Your 1:30 is running 12 minutes late. I moved your cleanup window and texted your 2:30. Nothing you need to do.",
        .concierge: "Jazz, a quick note. Your 1:30 arrived about twelve minutes late, so I've moved your cleanup window and let your 2:30 know to come at 2:40. Nothing you need to do.",
        .shadow: "1:30 ran twelve late. 2:30 moved to 2:40. Handled.",
        .hype: "Okay, your 1:30 showed up twelve late, classic. Already sorted: cleanup moved, your 2:30 knows to come at 2:40.",
    ]

    var body: some View {
        OnboardingScreen(section: "Cues") {
            Text("Customize your Cues.")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.textPrimary)

            Text("Same intelligence. Pick the voice you want in your ear.")
                .font(Tokens.Typography.bodyRegular)
                .foregroundStyle(Tokens.Color.textSecondary)

            FlowLayout(spacing: 8) {
                ForEach(CuePersona.allCases, id: \.self) { persona in
                    ChoiceChip(title: persona.displayName, isSelected: state.persona == persona) {
                        state.persona = persona
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                TrackedLabel(text: "Sample · 1:38 PM")
                Text(sample[state.persona] ?? "")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Tokens.Color.textPrimary)
            }
            .padding(14)
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Tokens.Color.hairline, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.top, Tokens.Spacing.sm)

            PillButton(title: "Sounds right", action: onDone)
                .padding(.top, Tokens.Spacing.md)
        }
    }
}

#Preview {
    PersonaView(state: OnboardingState(), onDone: {})
}
