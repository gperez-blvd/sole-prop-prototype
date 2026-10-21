import SwiftUI

/// A small secondary label — field group headers, source tags, inline
/// badges. Plain sentence case, no uppercase/tracking/monospacing — see
/// `Tokens.Typography`'s note on why: the all-caps tracked-mono treatment
/// this used to apply was a holdover from the retired design system and
/// read as more "system" than "her app."
struct TrackedLabel: View {
    var text: String
    var font: Font = Tokens.Typography.label
    var color: Color = Tokens.Color.textTertiary

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(color)
    }
}
