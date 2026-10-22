import SwiftUI

/// A plain top-bar icon button — shared by the messages and notifications
/// entry points. Deliberately carries no badge, dot, or count: CLAUDE.md
/// is explicit that counts are never badges ("It is never a number on an
/// icon") and names "a badge, an unread dot, a notification tray" as a
/// smell outright. If something's worth her attention, DETAIL says it
/// (the spoken tier) or it's simply the first thing she sees once she
/// opens the list — the icon itself never counts at her.
///
/// Replaces `BadgedIconButton`, which rendered `HomeMockData
/// .unreadNotificationCount` as a literal red number on the bell —
/// found during a design-system sweep as a direct violation of the rule
/// above, not a deliberate exception to it.
struct HeaderIconButton: View {
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Tokens.Color.textPrimary)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
    }
}
