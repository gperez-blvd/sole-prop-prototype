import SwiftUI

/// Placeholder architecture for the messages list reached from Home's
/// speech-bubble icon — the list's shape (avatar, client name, preview,
/// relative time, unread mark), not a real thread store. Follows
/// `ClientListView`'s row skeleton for visual consistency.
struct MessagesView: View {
    @Environment(Router.self) private var router

    private var threads: [ClientMessage] { HomeMockData.messageThreads }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(threads) { thread in
                    row(thread)
                }
            }
        }
        .background(Tokens.Color.background)
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
        .backIconButton { router.pop() }
    }

    private func row(_ thread: ClientMessage) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Avatar(name: thread.clientName, size: 36, photoURL: PersonPhoto.url(for: thread.clientName))

            VStack(alignment: .leading, spacing: 2) {
                Text(thread.clientName)
                    .font(Tokens.Typography.body)
                    .foregroundStyle(Tokens.Color.textPrimary)
                Text(thread.preview)
                    .font(Tokens.Typography.caption)
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 6) {
                Text(RelativeTime.label(for: thread.timestamp))
                    .font(Tokens.Typography.labelSmall)
                    .foregroundStyle(Tokens.Color.textTertiary)
                if thread.isUnread {
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
        MessagesView()
    }
    .environment(Router())
}
