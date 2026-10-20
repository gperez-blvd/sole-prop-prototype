import SwiftUI

/// A full-width button, softly rounded (`Tokens.Radius.button`) rather than
/// a full capsule. `.primary` is solid ink/fog, `.ghost` is ink text with a
/// faint ink border.
struct PillButton: View {
    enum Style {
        case primary
        case ghost
    }

    var title: String
    var style: Style = .primary
    var isDisabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Tokens.Typography.button)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .foregroundStyle(style == .primary ? Tokens.Color.fog : Tokens.Color.ink)
        .background(
            RoundedRectangle(cornerRadius: Tokens.Radius.button)
                .fill(style == .primary ? Tokens.Color.ink : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.button)
                .strokeBorder(style == .ghost ? Tokens.Color.ink.opacity(0.4) : .clear, lineWidth: 1)
        )
        .opacity(isDisabled ? 0.4 : 1)
        .disabled(isDisabled)
    }
}

/// A small toggle button, filled ink when selected — same corner radius as
/// every other button, not a capsule chip.
struct ChoiceChip: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .padding(.horizontal, 13)
                .padding(.vertical, 8)
        }
        .foregroundStyle(isSelected ? Tokens.Color.fog : Tokens.Color.ink)
        .background(
            RoundedRectangle(cornerRadius: Tokens.Radius.button).fill(isSelected ? Tokens.Color.ink : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.button)
                .strokeBorder(isSelected ? .clear : Color.black.opacity(0.3), lineWidth: 1)
        )
    }
}
