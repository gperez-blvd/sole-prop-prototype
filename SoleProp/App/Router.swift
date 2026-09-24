import SwiftUI

enum Route: Hashable {
    case home
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
