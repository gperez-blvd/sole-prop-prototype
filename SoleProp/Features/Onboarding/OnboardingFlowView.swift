import SwiftUI

enum OnboardingStep: Equatable {
    case welcome
    case searching
    case found
    case clients
    case live
    // Reached only from Home. Each returns to `.live`.
    case cal
    case migrate
    case migrateConnect
    case migrateExtract
    case migrateDone
    case book
    case persona
}

/// Hosts the Day 0 onboarding screens. Welcome → Searching → Found → Clients →
/// Live is the one path she walks in order; Live is Home, and everything past
/// it (calendar, bringing over old data, booking, customizing Cues) is a door
/// she opens from there, never a corridor she's pushed into. `onFinished` fires
/// once Jazz taps Continue on Home.
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
                    WelcomeView(state: state) { go(.searching) }
                case .searching:
                    SearchingView(state: state) { go(.found) }
                case .found:
                    FoundView(state: state) { go(.clients) }
                case .clients:
                    ClientsView(state: state) { go(.live) }
                case .live:
                    LiveView(state: state, onOpen: go, onContinue: onFinished)
                case .cal:
                    CalendarConnectView(state: state) { go(.live) }
                case .migrate:
                    MigrateSourceView(state: state, onPicked: { go(.migrateConnect) }, onBack: { go(.live) })
                case .migrateConnect:
                    MigrateConnectView(state: state) { go(.migrateExtract) }
                case .migrateExtract:
                    MigrateExtractView(state: state) { go(.migrateDone) }
                case .migrateDone:
                    MigrateDoneView(state: state) { go(.live) }
                case .book:
                    BookAppointmentView(state: state, onOpenPersona: { go(.persona) }, onBack: { go(.live) })
                case .persona:
                    PersonaView(state: state) { go(.live) }
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

    private func go(_ next: OnboardingStep) {
        step = next
    }
}

#Preview {
    OnboardingFlowView(onFinished: {})
}
