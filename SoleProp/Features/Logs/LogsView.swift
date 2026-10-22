import SwiftUI

/// Placeholder architecture for Logs — the "Behind" tier CLAUDE.md
/// describes: a flat, read-only feed of what DETAIL did, in her words.
/// No row action and no icon on purpose — this is meant to read as a
/// plain audit trail she reaches only if she doubts, not another
/// interactive list competing with Notifications/Messages.
struct LogsView: View {
    @Environment(Router.self) private var router

    private var entries: [LogEntry] { HomeMockData.activityLog }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(entries) { entry in
                    row(entry)
                }
            }
        }
        .background(Tokens.Color.background)
        .navigationTitle("Logs")
        .navigationBarTitleDisplayMode(.inline)
        .backIconButton { router.pop() }
    }

    private func row(_ entry: LogEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.text)
                .font(Tokens.Typography.body)
                .foregroundStyle(Tokens.Color.textPrimary)
            Text(RelativeTime.label(for: entry.timestamp))
                .font(Tokens.Typography.labelSmall)
                .foregroundStyle(Tokens.Color.textTertiary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, Tokens.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
                .padding(.leading, Tokens.Spacing.lg)
        }
    }
}

#Preview {
    NavigationStack {
        LogsView()
    }
    .environment(Router())
}
