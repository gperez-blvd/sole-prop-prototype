import SwiftUI

/// Empty scaffold for a navigation destination that doesn't have a design yet.
/// Uses a plain back-arrow icon (no text) instead of the system back button.
struct PlaceholderScreen: View {
    @Environment(Router.self) private var router
    var title: String

    var body: some View {
        ZStack {
            Tokens.Color.background.ignoresSafeArea()
            Text("\(title) — not designed yet")
                .font(Tokens.Typography.bodyRegular)
                .foregroundStyle(Tokens.Color.textTertiary)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .backIconButton { router.pop() }
    }
}

#Preview {
    NavigationStack {
        PlaceholderScreen(title: "Clients")
    }
    .environment(Router())
}
