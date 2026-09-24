import SwiftUI

private enum AppPhase: Equatable {
    case auth
    case onboarding
    case home
}

struct RootView: View {
    @State private var router = Router()
    @State private var voiceAssistant = VoiceConversationViewModel()
    @State private var phase: AppPhase = .auth

    // Keys the Home stack below so the PROTOTYPE lifecycle switch (see
    // `MenuSheet`) reseeds and returns to Home: changing this identity tears
    // down and rebuilds the stack, which resets `Router.path` and dismisses
    // whatever sheet is open — no manual pop/dismiss wiring needed.
    @AppStorage("prototype.lifecycleStage") private var lifecycleStageRawValue = LifecycleStage.steady.rawValue

    var body: some View {
        Group {
            switch phase {
            case .auth:
                AuthFlowView(
                    onCreateAccount: { phase = .onboarding },
                    onLogIn: { phase = .home }
                )
            case .onboarding:
                OnboardingFlowView {
                    phase = .home
                }
            case .home:
                NavigationStack(path: $router.path) {
                    HomeView()
                        .navigationDestination(for: Route.self) { route in
                            switch route {
                            case .profile:
                                PlaceholderScreen(title: "Profile / Settings")
                            case .clients:
                                PlaceholderScreen(title: "Clients")
                            case .schedule:
                                PlaceholderScreen(title: "Schedule")
                            case .wallet:
                                PlaceholderScreen(title: "Wallet")
                            case .logs:
                                PlaceholderScreen(title: "Logs")
                            case .help:
                                PlaceholderScreen(title: "Help")
                            case .notifications:
                                PlaceholderScreen(title: "Notifications")
                            case .messages:
                                PlaceholderScreen(title: "Messages")
                            case .voiceConversation:
                                VoiceConversationView()
                            }
                        }
                }
                .environment(router)
                .environment(voiceAssistant)
                .id(lifecycleStageRawValue)
            }
        }
    }
}
