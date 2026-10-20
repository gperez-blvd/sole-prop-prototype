import SwiftUI

/// A bottom-anchored gradient that fades scrolled content out to the
/// screen's background color before it reaches the fixed voice orb —
/// content should never be visibly readable/overlapping behind the orb.
/// Place this in a ZStack above the scrollable content and below the orb
/// itself, both anchored to the bottom.
struct OrbBackdropFade: View {
    var color: Color = Tokens.Color.background
    var height: CGFloat = 260

    var body: some View {
        VStack(spacing: 0) {
            // Reaches full opacity well before the orb's own halo starts
            // (not just before its solid core) — the halo is considerably
            // wider than the blob itself, and a softer, later-opaque curve
            // let scrolled content show faintly through it.
            LinearGradient(
                stops: [
                    .init(color: color.opacity(0), location: 0),
                    .init(color: color.opacity(0.12), location: 0.15),
                    .init(color: color.opacity(0.35), location: 0.28),
                    .init(color: color.opacity(0.65), location: 0.38),
                    .init(color: color, location: 0.48),
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
