import SwiftUI

struct RootView: View {
    @State private var router = Router()
    @State private var onboardingComplete = false

    var body: some View {
        Group {
            if onboardingComplete {
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
            } else {
                OnboardingFlowView {
                    onboardingComplete = true
                }
            }
        }
    }
}
