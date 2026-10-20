import SwiftUI

/// The voice assistant's entry point / speaking-listening indicator.
///
/// Replaces the earlier flat line-art braid with a lit, volumetric-reading
/// blob — modeled on the Figma reference's glossy sphere (soft ambient
/// glow, specular sheen, bright hot spot) but deliberately not a sphere:
/// the silhouette itself wobbles continuously (two summed, out-of-phase
/// sine terms, not one clean periodic wave) so it reads as organic/
/// amorphous rather than a perfect glass ball, and the palette is a
/// friendly teal/bluegreen rather than the reference's blue. `level`
/// (0...1, live mic amplitude) adds extra wobble and glow once listening;
/// `isActive` just changes how much energy the idle animation already has
/// — the blob is alive at rest too, never a static frozen image.
struct VoiceOrb: View {
    /// The one size used everywhere this appears — Home's entry point and
    /// the full conversation screen both use this so the button reads as
    /// the same control throughout the app, not a smaller stand-in.
    static let standardSize: CGFloat = 72

    var size: CGFloat = VoiceOrb.standardSize
    var level: Double = 0
    var isActive: Bool = false

    @State private var time: Double = 0
    @State private var activeEnergy: Double = 0

    // Friendly bluegreen/teal — ties to Tokens.Color.ochre (the app's new
    // accent) at the core, lightening toward a cyan-white highlight.
    private static let deepShadow = Color(hex: "#042F2E")
    private static let base = Color(hex: "#0D9488")
    private static let mid = Color(hex: "#2DD4BF")
    private static let bright = Color(hex: "#99F6E4")
    private static let hotSpot = Color(hex: "#F0FFFC")

    var body: some View {
        let wobble = 0.16 + activeEnergy * 0.14 + level * 0.1
        let glow = 0.3 + activeEnergy * 0.25 + level * 0.25

        ZStack {
            // Ambient halo — soft glow bleeding onto whatever's behind it.
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Self.mid.opacity(glow * 0.6), Self.mid.opacity(glow * 0.18), .clear],
                        center: .center, startRadius: 0, endRadius: size * 0.95
                    )
                )
                .frame(width: size * 2.2, height: size * 2.2)
                .blur(radius: size * 0.18)

            blobFill(amplitude: wobble)
                .overlay(specularSheen(amplitude: wobble))
                .overlay(hotSpotHighlight)
                .frame(width: size, height: size)
                .shadow(color: Self.base.opacity(0.45), radius: size * 0.2, y: size * 0.06)
        }
        .compositingGroup()
        .scaleEffect(1 + level * 0.06)
        .onAppear {
            activeEnergy = isActive ? 1 : 0
            withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                time = 18 * (2 * .pi)
            }
        }
        .onChange(of: isActive) { _, newValue in
            withAnimation(.easeInOut(duration: 0.6)) {
                activeEnergy = newValue ? 1 : 0
            }
        }
        .animation(.easeInOut(duration: 0.2), value: level)
    }

    private func blobFill(amplitude: Double) -> some View {
        BlobShape(phase: time, amplitude: amplitude)
            .fill(
                RadialGradient(
                    stops: [
                        .init(color: Self.bright, location: 0),
                        .init(color: Self.mid, location: 0.32),
                        .init(color: Self.base, location: 0.68),
                        .init(color: Self.deepShadow, location: 1),
                    ],
                    center: UnitPoint(x: 0.36, y: 0.32), startRadius: 0, endRadius: size * 0.64
                )
            )
    }

    /// A soft diagonal streak of light across the blob's upper half — the
    /// reference orb's glass-sheen look — clipped to the same wobbling
    /// silhouette so it reads as light on the blob's surface, not a shape
    /// floating on top of it.
    private func specularSheen(amplitude: Double) -> some View {
        Ellipse()
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.8), Color.white.opacity(0)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .frame(width: size * 0.62, height: size * 0.3)
            .rotationEffect(.degrees(-32))
            .offset(x: -size * 0.06, y: -size * 0.18)
            .blendMode(.screen)
            .blur(radius: size * 0.015)
            .clipShape(BlobShape(phase: time, amplitude: amplitude))
    }

    private var hotSpotHighlight: some View {
        Circle()
            .fill(Self.hotSpot)
            .frame(width: size * 0.1, height: size * 0.1)
            .blur(radius: size * 0.02)
            .offset(x: -size * 0.12, y: -size * 0.1)
            .blendMode(.screen)
    }
}

/// A closed, filled silhouette whose radius wobbles as the sum of two
/// out-of-phase sine terms at different frequencies — deliberately not a
/// single clean periodic wave, so the shape reads as an organic, slightly
/// irregular blob rather than a perfect circle or a uniform flower shape.
/// `amplitude` scales the wobble continuously (0 ≈ a plain circle), so it
/// animates smoothly as part of one `animatableData` transaction rather
/// than switching between discrete shapes.
private struct BlobShape: Shape {
    var phase: Double
    var amplitude: Double

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(phase, amplitude) }
        set {
            phase = newValue.first
            amplitude = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let steps = 120
        var path = Path()

        for i in 0...steps {
            let t = Double(i) / Double(steps)
            let theta = t * 2 * .pi
            let wobble = 1
                + amplitude * 0.5 * sin(theta * 3 + phase)
                + amplitude * 0.3 * sin(theta * 5 - phase * 1.4)
                + amplitude * 0.2 * sin(theta * 2 + phase * 0.7)
            let r = radius * wobble
            let point = CGPoint(x: center.x + r * cos(theta), y: center.y + r * sin(theta))
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(spacing: 40) {
        VoiceOrb(size: 72, isActive: false)
        VoiceOrb(size: 72, level: 0.6, isActive: true)
        VoiceOrb(size: 120, level: 0.6, isActive: true)
    }
    .padding()
    .background(Color.black)
}
