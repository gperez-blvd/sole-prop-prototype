import SwiftUI

struct QuickActionButton: View {
    var title: String
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .medium))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(BUITokens.Color.textPrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .background(BUITokens.Color.background)
        .clipShape(Capsule())
        .shadow(color: BUITokens.Shadow.medium, radius: 20, x: 0, y: 6)
    }
}
