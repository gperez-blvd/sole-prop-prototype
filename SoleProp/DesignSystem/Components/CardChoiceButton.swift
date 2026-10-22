import SwiftUI

/// The one actionable-choice treatment for Home's `DetailMoment` cards —
/// `CueCard`'s "Got it", `ThresholdProposalCard`'s options. A single
/// shared component so the two card types can't drift into two different
/// "this button matters" languages the way they did before this existed
/// (one neutral/filled, one teal-outlined) — see ENGINEERING_LESSONS.md.
/// Teal (`accentText`), outlined rather than filled, reads as "a real
/// choice" without competing with the sentence above it for attention.
struct CardChoiceButton: View {
    var title: String
    var trailingIcon: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(title)
                if let trailingIcon {
                    Image(systemName: trailingIcon)
                        .font(.system(size: 10, weight: .bold))
                }
            }
            .font(.dmSans(14, weight: .medium))
            .foregroundStyle(Tokens.Color.accentText)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.button)
                    .strokeBorder(Tokens.Color.accentBorderStrong)
            )
        }
        .buttonStyle(.plain)
    }
}
