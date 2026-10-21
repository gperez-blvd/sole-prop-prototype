import SwiftUI

struct QuickActionButton: View {
    var title: String
    var systemImage: String
    /// Smaller footprint for the conversation screen's bottom bar, where it
    /// sits alongside the input toggle and orb rather than as a standalone
    /// Home control.
    var isCompact: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: isCompact ? 5 : 8) {
                Image(systemName: systemImage)
                    .font(.system(size: isCompact ? 12 : 15, weight: .medium))
                Text(title)
                    .font(.dmSans(isCompact ? 12.5 : 14, weight: .medium))
            }
            .foregroundStyle(Tokens.Color.onPrimaryFill)
            .padding(.horizontal, isCompact ? 14 : 20)
            .padding(.vertical, isCompact ? 8 : 12)
        }
        .buttonStyle(.plain)
        // Same adaptive fill every other solid button in the app uses —
        // a fixed `.onyx` pill here would have the same near-invisible
        // contrast problem on a dark page background already fixed
        // elsewhere (PillButton, DailyBriefView's CTA, etc.).
        .background(Tokens.Color.primaryFill)
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.button))
    }
}
