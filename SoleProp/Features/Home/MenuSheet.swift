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
/// dismisses the sheet and pushes onto the root `NavigationStack`; `HomeView`
/// re-presents this same sheet when the stack pops back to it after a
/// menu-originated push, so backing out of a destination returns here
/// instead of to a bare Home.
///
/// Just the six rows now — no Appearance, no PROTOTYPE section. Both moved
/// to `ProfileView`: they're genuinely settings, not things that belong on
/// a menu that reopens every time she navigates.
///
/// **On sizing this precisely, the hard way first:** the obvious-looking
/// approach — measure the content's real height with a `GeometryReader`/
/// `PreferenceKey` and feed that back into `.presentationDetents` — does
/// NOT work here. `measuredHeight` starts at 0 before the first layout
/// pass, so the sheet opens at the `.medium` fallback (~50% of the
/// screen); updating `presentationDetents` on an *already-presented*
/// sheet doesn't reliably resize it afterward, so it was visibly stuck at
/// that oversized height with six short rows floating inside a mostly
/// empty sheet — the exact "still looks very tall" bug this replaced.
/// The fix is to know the height up front: six rows at a fixed, explicit
/// per-row height, computed once, correct on the very first frame.
struct MenuSheet: View {
    var onSelect: (Route) -> Void

    private let items: [MenuItem] = [
        MenuItem(.profile, "Profile / Settings", "person.circle"),
        MenuItem(.clients, "Clients", "person.2"),
        MenuItem(.schedule, "Schedule", "calendar"),
        MenuItem(.wallet, "Wallet", "wallet.pass"),
        MenuItem(.performance, "Performance", "chart.bar"),
        MenuItem(.help, "Help", "questionmark.circle"),
    ]

    /// Apple's own tap-target minimum — also this row's actual height,
    /// not just its floor, since every row uses `.frame(height:)` below
    /// rather than `minHeight`: a fixed height is what makes the total
    /// sheet height below exactly predictable.
    private let rowHeight: CGFloat = 44
    private let topPadding: CGFloat = 12
    private let bottomPadding: CGFloat = 8

    private var sheetHeight: CGFloat {
        topPadding + CGFloat(items.count) * rowHeight + bottomPadding
    }

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
                            .foregroundStyle(Tokens.Color.textTertiary)
                    }
                    .foregroundStyle(Tokens.Color.textPrimary)
                    // A fixed height, not just a `minHeight` floor — see
                    // `sheetHeight` above, which depends on this being
                    // exact, not merely "at least" 44.
                    .frame(height: rowHeight)
                    .padding(.horizontal, 24)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        // A soft frosted-glass backdrop for the whole sheet — rows and
        // the home-indicator sliver alike, via `presentationBackground`
        // rather than a per-content `.background`, so there's one
        // consistent surface instead of a flat fill under the rows and
        // a different treatment below it. `.ultraThinMaterial` supplies
        // the blur; the near-opaque tint on top keeps it subtle (barely
        // any of Home shows through) rather than a loud glass effect.
        .presentationBackground {
            Tokens.Color.background.opacity(0.9)
                .background(.ultraThinMaterial)
        }
        .presentationDetents([.height(sheetHeight)])
        .presentationDragIndicator(.visible)
    }
}
