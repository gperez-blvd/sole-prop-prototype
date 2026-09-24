import SwiftUI

/// The reference's `.pbtn` — a full-width capsule button. `.primary` is solid
/// ink/fog, `.ghost` is ink text with a faint ink border (`.pbtn.ghost`).
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
            Capsule()
                .fill(style == .primary ? Tokens.Color.ink : Color.clear)
        )
        .overlay(
            Capsule()
                .strokeBorder(style == .ghost ? Tokens.Color.ink.opacity(0.4) : .clear, lineWidth: 1)
        )
        .opacity(isDisabled ? 0.4 : 1)
        .disabled(isDisabled)
    }
}

/// The reference's `.chip` — a small capsule toggle, filled ink when selected.
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
            Capsule().fill(isSelected ? Tokens.Color.ink : Color.clear)
        )
        .overlay(
            Capsule().strokeBorder(isSelected ? .clear : Color.black.opacity(0.3), lineWidth: 1)
        )
    }
}
