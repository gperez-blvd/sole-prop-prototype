import SwiftUI

/// A bottom-anchored gradient that fades scrolled content out to the
/// screen's background color before it reaches the fixed voice orb —
/// content should never be visibly readable/overlapping behind the orb.
/// Place this in a ZStack above the scrollable content and below the orb
/// itself, both anchored to the bottom.
struct OrbBackdropFade: View {
    var color: Color = Tokens.Color.background
    var height: CGFloat = 190

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: color.opacity(0), location: 0),
                .init(color: color, location: 0.55),
                .init(color: color, location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: height)
        .allowsHitTesting(false)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
