import SwiftUI

struct HomeHeaderBar: View {
    var businessName: String
    var onMenuTap: () -> Void
    var onMessagesTap: () -> Void
    var onNotificationsTap: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onMenuTap) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(BUITokens.Color.textPrimary)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            Text(businessName)
                .font(BUITokens.Typography.headerTitle)
                .foregroundStyle(BUITokens.Color.textPrimary)
                .frame(maxWidth: .infinity)

            HStack(spacing: 4) {
                BadgedIconButton(systemImage: "message", count: 0, action: onMessagesTap)
                BadgedIconButton(systemImage: "bell", count: HomeMockData.unreadNotificationCount, action: onNotificationsTap)
            }
        }
    }
}
