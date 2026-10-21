import SwiftUI

/// A labeled text field — a soft filled surface rather than a bottom
/// hairline, matching the rest of the app's "elevation, not borders"
/// treatment (see `Tokens.swift`). Used on the Welcome screen for
/// name/Instagram/phone, and elsewhere in onboarding.
///
/// The fill is a very low-opacity wash of the brand accent rather than
/// `Tokens.Color.silt`'s neutral gray — enough to read as "this app's
/// own input," not enough to read as a tappable button (no border, no
/// shadow, no saturation anywhere near button-strength). `ochre` itself
/// is fixed-brightness in both appearances, so this same low opacity
/// reads as a pale mint wash on light and a deep teal-tinted glass on
/// dark without needing separate light/dark values.
struct OnboardingField: View {
    var label: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TrackedLabel(text: label)
            TextField("", text: $text)
                .font(Tokens.Typography.value)
                .foregroundStyle(Tokens.Color.textPrimary)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Tokens.Color.ochre.opacity(0.12), in: RoundedRectangle(cornerRadius: Tokens.Radius.md))
    }
}
