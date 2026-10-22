import SwiftUI

/// Placeholder architecture for the notifications list reached from Home's
/// bell icon — the list's shape (icon, title, detail, relative time,
/// unread mark), not a real notification system. Follows `ClientListView`'s
/// row skeleton for visual consistency: leading mark, a two-line title +
/// detail stack, trailing time, hairline dividers.
struct NotificationsView: View {
    @Environment(Router.self) private var router

    private var notifications: [AppNotification] { HomeMockData.notificationFeed }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(notifications) { notification in
                    row(notification)
                }
            }
        }
        .background(Tokens.Color.background)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .backIconButton { router.pop() }
    }

    private func row(_ notification: AppNotification) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: notification.icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Tokens.Color.accentSoft)
                .frame(width: 32, height: 32)
                .background(Tokens.Color.accentSoftTint, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(Tokens.Typography.body)
                    .foregroundStyle(Tokens.Color.textPrimary)
                Text(notification.detail)
                    .font(Tokens.Typography.caption)
                    .foregroundStyle(Tokens.Color.textSecondary)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 6) {
                Text(RelativeTime.label(for: notification.timestamp))
                    .font(Tokens.Typography.labelSmall)
                    .foregroundStyle(Tokens.Color.textTertiary)
                if notification.isUnread {
                    Circle()
                        .fill(Tokens.Color.accentSoft)
                        .frame(width: 7, height: 7)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, Tokens.Spacing.lg)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
                .padding(.leading, Tokens.Spacing.lg)
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
    .environment(Router())
}
