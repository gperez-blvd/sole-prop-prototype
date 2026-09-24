import SwiftUI

private struct MenuItem: Identifiable {
    let route: Route
    let title: String
    let icon: String

    var id: Route { route }

    init(_ route: Route, _ title: String, _ icon: String) {
        self.route = route
        self.title = title
        self.icon = icon
    }
}

/// The top-left menu — a sheet listing the six top-level destinations, none of
/// which have real designs yet (see `PlaceholderScreen`). Selecting one
/// dismisses the sheet and pushes onto the root `NavigationStack`.
struct MenuSheet: View {
    var onSelect: (Route) -> Void

    private let items: [MenuItem] = [
        MenuItem(.profile, "Profile / Settings", "person.circle"),
        MenuItem(.clients, "Clients", "person.2"),
        MenuItem(.schedule, "Schedule", "calendar"),
        MenuItem(.wallet, "Wallet", "wallet.pass"),
        MenuItem(.logs, "Logs", "list.bullet.rectangle"),
        MenuItem(.help, "Help", "questionmark.circle"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                Button {
                    onSelect(item.route)
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: item.icon)
                            .font(.system(size: 17))
                            .frame(width: 24)
                        Text(item.title)
                            .font(.system(size: 15, weight: .medium))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(BUITokens.Color.disabled)
                    }
                    .foregroundStyle(BUITokens.Color.textPrimary)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                }
                .buttonStyle(.plain)

                if item.route != items.last?.route {
                    Divider().padding(.leading, 24)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 24)
        .background(BUITokens.Color.background)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
