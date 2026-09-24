import SwiftUI

enum Route: Hashable {
    case profile
    case clients
    case schedule
    case wallet
    case logs
    case help
    case notifications
    case messages
    case voiceConversation
}

@Observable
final class Router {
    var path: [Route] = []

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
