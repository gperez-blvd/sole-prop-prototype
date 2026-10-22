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
    // Bumped by the PROTOTYPE section's "Reset demo data" button — folded
    // into the same `.id()` below so a reset forces the same full
    // reseed/rebuild even when the stage itself doesn't change (e.g.
    // resetting while already on "Steady" wouldn't otherwise change
    // `lifecycleStageRawValue`, so nothing would rebuild on its own).
    @AppStorage("prototype.resetToken") private var resetToken = 0
    /// The app's real (non-prototype) display setting — see `MenuSheet`'s
    /// Appearance section and `AppearanceSetting`.
    @AppStorage("settings.appearance") private var appearanceRawValue = AppearanceSetting.dark.rawValue

    private var appearance: AppearanceSetting {
        AppearanceSetting(rawValue: appearanceRawValue) ?? .system
    }

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
                                ClientListView()
                            case .client(let memory):
                                ClientDetailView(memory: memory)
                                    .backIconButton { router.pop() }
                            case .schedule:
                                ScheduleView()
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
                .id("\(lifecycleStageRawValue)_\(resetToken)")
            }
        }
        .preferredColorScheme(appearance.colorScheme)
    }
}
