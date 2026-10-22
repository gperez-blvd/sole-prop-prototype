import SwiftUI

/// A full-width button, softly rounded (`Tokens.Radius.button`) rather than
/// a full capsule. `.primary` is solid ink/fog, `.ghost` is ink text with a
/// faint ink border.
struct PillButton: View {
    enum Style {
        case primary
        /// Same solid-fill treatment as `.primary`, inverted to a fog
        /// fill/ink text — `.primary`'s near-black fill is nearly
        /// invisible against a dark background like the auth landing
        /// screen's dark atmosphere, where this should be used instead.
        case primaryLight
        case ghost
        /// Same outline treatment as `.ghost`, inverted to white text/
        /// border — for a ghost button sitting on a dark background
        /// (e.g. the auth landing screen's dark atmosphere), where
        /// `.ghost`'s ink-on-ink outline would be invisible.
        case ghostLight
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
        .foregroundStyle(style == .primary ? Tokens.Color.onPrimaryFill : style == .primaryLight ? Tokens.Color.ink : style == .ghostLight ? Tokens.Color.fog : Tokens.Color.textPrimary)
        .background(
            RoundedRectangle(cornerRadius: Tokens.Radius.button)
                .fill(style == .primary ? Tokens.Color.primaryFill : style == .primaryLight ? Tokens.Color.fog : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.button)
                .strokeBorder(
                    style == .ghost ? Tokens.Color.textPrimary.opacity(0.35)
                        : style == .ghostLight ? Tokens.Color.fog.opacity(0.45) : .clear,
                    lineWidth: 1
                )
        )
        .opacity(isDisabled ? 0.4 : 1)
        .disabled(isDisabled)
    }
}

/// An inline, compact button for a tight context inside a card (accept/
/// dismiss a review item, a secondary action riding alongside other
/// content) — `PillButton`'s full-width treatment doesn't fit here, but
/// it's the same two-state (filled/outline) language, just sized down.
/// Used to be a private, one-off `MiniButtonStyle` duplicated inside
/// `MigrateDoneView`; promoted here so any screen needing this same
/// small-filled/small-outline pair reaches for one shared style.
struct CompactButtonStyle: ButtonStyle {
    var filled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.dmSans(14, weight: .semibold))
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .foregroundStyle(filled ? Tokens.Color.onPrimaryFill : Tokens.Color.textPrimary)
            .background(RoundedRectangle(cornerRadius: Tokens.Radius.button).fill(filled ? Tokens.Color.primaryFill : Color.clear))
            .overlay(RoundedRectangle(cornerRadius: Tokens.Radius.button).strokeBorder(filled ? .clear : Tokens.Color.textPrimary, lineWidth: 1))
            .opacity(configuration.isPressed ? 0.7 : 1)
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
                .font(.dmSans(14, weight: .medium))
                .padding(.horizontal, 13)
                .padding(.vertical, 8)
        }
        .foregroundStyle(isSelected ? Tokens.Color.onPrimaryFill : Tokens.Color.textPrimary)
        .background(
            RoundedRectangle(cornerRadius: Tokens.Radius.button).fill(isSelected ? Tokens.Color.primaryFill : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.button)
                .strokeBorder(isSelected ? .clear : Tokens.Color.textPrimary.opacity(0.3), lineWidth: 1)
        )
    }
}
