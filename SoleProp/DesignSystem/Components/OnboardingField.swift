import SwiftUI

/// The reference's `.field` — a tracked label above a borderless, bottom-hairline
/// text input. Used on the Welcome screen for name/Instagram/phone.
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
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Tokens.Color.hairline)
                .frame(height: 1)
        }
    }
}
