import SwiftUI

/// A one-shot confetti burst — small rects that fall and rotate, fading out.
/// Fires once whenever `trigger` flips to true; does nothing under Reduce Motion.
struct ConfettiView: View {
    var trigger: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pieces: [Piece] = []
    @State private var fallen = false

    private struct Piece: Identifiable {
        let id = UUID()
        let x: CGFloat
        let delay: Double
        let color: Color
        let rotation: Double
    }

    private static let colors = [Tokens.Color.ochre, Color(hex: "#183E43"), Tokens.Color.ink, Tokens.Color.silt]

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                ForEach(pieces) { piece in
                    Rectangle()
                        .fill(piece.color)
                        .frame(width: 6, height: 10)
                        .rotationEffect(.degrees(fallen ? piece.rotation : 0))
                        .position(
                            x: piece.x * proxy.size.width,
                            y: fallen ? proxy.size.height + 40 : -40
                        )
                        .opacity(fallen ? 0 : 1)
                        .animation(.easeIn(duration: 1.4).delay(piece.delay), value: fallen)
                }
            }
        }
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, newValue in
            guard newValue, !reduceMotion else { return }
            pieces = (0..<28).map { _ in
                Piece(
                    x: .random(in: 0...1),
                    delay: .random(in: 0...0.3),
                    color: Self.colors.randomElement() ?? Tokens.Color.ochre,
                    rotation: .random(in: 90...360)
                )
            }
            fallen = false
            DispatchQueue.main.async { fallen = true }
        }
    }
}
