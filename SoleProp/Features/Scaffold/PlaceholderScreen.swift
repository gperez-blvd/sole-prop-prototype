import SwiftUI

/// Empty scaffold for a navigation destination that doesn't have a design yet.
/// Relies on `NavigationStack`'s own automatic back button — no custom chrome.
struct PlaceholderScreen: View {
    var title: String

    var body: some View {
        ZStack {
            BUITokens.Color.background.ignoresSafeArea()
            Text("\(title) — not designed yet")
                .font(.system(size: 13.5))
                .foregroundStyle(BUITokens.Color.disabled)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PlaceholderScreen(title: "Clients")
    }
}
