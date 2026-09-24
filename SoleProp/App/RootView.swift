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
                            case .home:
                                HomeView()
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
