import SwiftUI

/// A capability stated honestly rather than hidden — DETAIL says what it
/// can't do yet in terms of its own limitation, not as homework for her.
struct CapabilityNoteCard: View {
    var note: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lock")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Tokens.Color.textTertiary)
                .padding(.top, 2)
            Text(note)
                .font(Tokens.Typography.caption)
                .foregroundStyle(Tokens.Color.textSecondary)
        }
        .cardStyle()
    }
}

#Preview {
    CapabilityNoteCard(note: "I can't collect payment on my own yet — you'll still need to run cards yourself until that's connected.")
        .padding(28)
        .background(Tokens.Color.background)
}
