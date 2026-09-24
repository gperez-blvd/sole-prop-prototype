import SwiftUI

/// A top-bar icon button with an optional small red count badge — shared by
/// the notifications and messages entry points.
struct BadgedIconButton: View {
    var systemImage: String
    var count: Int
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .frame(width: 36, height: 36)

                if count > 0 {
                    Text(count > 9 ? "9+" : "\(count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Tokens.Color.onyx)
                        .padding(.horizontal, count > 9 ? 4 : 0)
                        .frame(minWidth: 16, minHeight: 16)
                        .background(Circle().fill(Tokens.Color.ochre))
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
