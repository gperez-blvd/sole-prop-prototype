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
                    .font(.system(size: isCompact ? 12.5 : 14, weight: .medium))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, isCompact ? 14 : 20)
            .padding(.vertical, isCompact ? 8 : 12)
        }
        .buttonStyle(.plain)
        .background(BUITokens.Color.contrastPrimary)
        .clipShape(Capsule())
        .shadow(color: BUITokens.Shadow.medium, radius: isCompact ? 10 : 20, x: 0, y: isCompact ? 3 : 6)
    }
}
