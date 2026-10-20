import SwiftUI

/// A bottom-anchored gradient that fades scrolled content out to the
/// screen's background color before it reaches the fixed voice orb —
/// content should never be visibly readable/overlapping behind the orb.
/// Place this in a ZStack above the scrollable content and below the orb
/// itself, both anchored to the bottom.
struct OrbBackdropFade: View {
    var color: Color = Tokens.Color.background
    var height: CGFloat = 220

    var body: some View {
        VStack(spacing: 0) {
            // More stops, eased rather than linear — reaching full
            // opacity gradually instead of over a short, sharp-reading
            // stretch partway down.
            LinearGradient(
                stops: [
                    .init(color: color.opacity(0), location: 0),
                    .init(color: color.opacity(0.06), location: 0.25),
                    .init(color: color.opacity(0.22), location: 0.45),
                    .init(color: color.opacity(0.5), location: 0.65),
                    .init(color: color.opacity(0.82), location: 0.82),
                    .init(color: color, location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: height)

            // Solid fill down through the home indicator's safe area —
            // the gradient above already reaches full opacity by its own
            // end, but without this the safe-area strip below it isn't
            // covered and scrolled content shows through underneath it.
            // Fixed height, not left to size itself: an unconstrained
            // Color in this VStack expands to fill the whole ZStack
            // (blanking out everything scrolled above it, not just the
            // safe-area sliver below the gradient).
            color.frame(height: 40)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea(edges: .bottom)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
