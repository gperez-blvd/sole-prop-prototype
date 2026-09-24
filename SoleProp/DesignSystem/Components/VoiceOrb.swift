import SwiftUI

/// The voice assistant's entry point / speaking-listening indicator — a
/// glossy sphere with a slowly rotating glowing ring, inspired by
/// dribbble.com/shots/27188223 ("Sphere — AI Voice Interaction Design").
/// `level` (0...1, live mic amplitude) speeds up the ring's rotation and
/// brightens the glow while listening; with no level driving it, it idles
/// with a slow rotation and a gentle breathing pulse.
struct VoiceOrb: View {
    var size: CGFloat = 64
    var level: Double = 0

    @State private var rotation: Double = 0
    @State private var breathe = false

    private static let ringColors: [Color] = [
        Color(hex: "#3B5BFF"), Color(hex: "#7B4CFF"), Color(hex: "#C24CFF"),
        Color(hex: "#FF7A4C"), Color(hex: "#3B5BFF"),
    ]

    var body: some View {
        let energy = max(breathe ? 0.15 : 0, level)

        ZStack {
            // Outer glow halo.
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#5B6BFF").opacity(0.55 + energy * 0.3), .clear],
                        center: .center, startRadius: 0, endRadius: size * 0.85
                    )
                )
                .frame(width: size * 1.7, height: size * 1.7)
                .blur(radius: size * 0.12)

            // Rotating glowing ring.
            Circle()
                .stroke(
                    AngularGradient(colors: Self.ringColors, center: .center),
                    lineWidth: size * (0.09 + energy * 0.03)
                )
                .frame(width: size * (1.08 + energy * 0.1), height: size * (1.08 + energy * 0.1))
                .rotationEffect(.degrees(rotation))
                .blur(radius: size * 0.02)

            // Glossy sphere core with an offset specular highlight.
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#0A0F3D"), Color(hex: "#1B2A78"), Color(hex: "#3B5BFF")],
                        center: .center, startRadius: 0, endRadius: size * 0.55
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.85), .white.opacity(0)],
                                center: UnitPoint(x: 0.32, y: 0.3), startRadius: 0, endRadius: size * 0.32
                            )
                        )
                )
                .scaleEffect(1 + energy * 0.12)
        }
        .animation(.easeInOut(duration: 0.15), value: level)
        .onAppear {
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                breathe = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        VoiceOrb(size: 64)
        VoiceOrb(size: 159, level: 0.6)
    }
    .padding()
    .background(Color.white)
}
