import SwiftUI

enum OnboardingStep: Int, CaseIterable {
    case welcome
    case searching
    case found
    case clients
    case live
}

/// Hosts the five Day 0 onboarding screens (Welcome → Searching → Found →
/// Clients → Live), matching the "Boulevard Secret Service" prototype's
/// onboarding act. `onFinished` fires once Jazz taps Continue on the Live screen.
struct OnboardingFlowView: View {
    var onFinished: () -> Void

    @State private var state = OnboardingState()
    @State private var step: OnboardingStep = .welcome

    var body: some View {
        ZStack {
            Tokens.Color.background.ignoresSafeArea()

            Group {
                switch step {
                case .welcome:
                    WelcomeView(state: state) { advance(to: .searching) }
                case .searching:
                    SearchingView(state: state) { advance(to: .found) }
                case .found:
                    FoundView(state: state) { advance(to: .clients) }
                case .clients:
                    ClientsView(state: state) { advance(to: .live) }
                case .live:
                    LiveView(state: state, onContinue: onFinished)
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

    private func advance(to next: OnboardingStep) {
        step = next
    }
}

#Preview {
    OnboardingFlowView(onFinished: {})
}
