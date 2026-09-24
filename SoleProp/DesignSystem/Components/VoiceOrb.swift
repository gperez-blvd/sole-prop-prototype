import SwiftUI

/// The voice assistant's entry point / speaking-listening indicator — a
/// small, hollow, abstract wavy ring, inspired by
/// dribbble.com/shots/27188223 ("Sphere — AI Voice Interaction Design").
/// No filled core — the ring itself wobbles continuously via a handful of
/// animated sine terms. `level` (0...1, live mic amplitude) increases the
/// wobble amplitude and rotation speed while listening; with no level
/// driving it, it idles with a slow rotation and a gentle wobble.
struct VoiceOrb: View {
    var size: CGFloat = 44
    var level: Double = 0

    @State private var rotation: Double = 0
    @State private var wobblePhase: Double = 0

    private static let ringColors: [Color] = [
        Color(hex: "#4C6BFF"), Color(hex: "#8B5CF6"), Color(hex: "#4C6BFF"),
    ]

    var body: some View {
        let energy = level

        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#6B7BFF").opacity(0.35 + energy * 0.25), .clear],
                        center: .center, startRadius: 0, endRadius: size * 0.7
                    )
                )
                .frame(width: size * 1.6, height: size * 1.6)
                .blur(radius: size * 0.15)

            WavyRing(phase: wobblePhase, amplitude: 0.05 + energy * 0.09, waves: 5)
                .stroke(
                    AngularGradient(colors: Self.ringColors, center: .center),
                    lineWidth: size * 0.07
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotation))
                .blur(radius: size * 0.01)
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false)) {
                wobblePhase = .pi * 2
            }
        }
        .animation(.easeInOut(duration: 0.2), value: level)
    }
}

/// A closed ring whose radius wobbles sinusoidally around its circumference
/// — an abstract, organic alternative to a plain `Circle`.
private struct WavyRing: Shape {
    var phase: Double
    var amplitude: Double
    var waves: Double

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2
        let steps = 120
        var path = Path()

        for i in 0...steps {
            let theta = (Double(i) / Double(steps)) * 2 * .pi
            let wobble = 1 + amplitude * sin(theta * waves + phase)
            let radius = baseRadius * wobble
            let point = CGPoint(x: center.x + radius * cos(theta), y: center.y + radius * sin(theta))
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
        VoiceOrb(size: 44)
        VoiceOrb(size: 72, level: 0.6)
    }
    .padding()
    .background(Color.white)
}
