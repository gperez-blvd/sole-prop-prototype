import SwiftUI

/// The voice assistant's entry point / speaking-listening indicator —
/// several interwoven, independently-flowing glowing ribbon strands plus a
/// handful of twinkling sparkle particles, modeled on the reference art
/// George shared (dribbble.com/shots/27188223's braided-light-ring look).
/// No filled core — hollow, abstract, and always in motion. `level` (0...1,
/// live mic amplitude) widens the strands and speeds/brightens everything
/// while listening; with no level driving it, it still flows continuously
/// on its own, just gently.
struct VoiceOrb: View {
    var size: CGFloat = 48
    var level: Double = 0

    @State private var time: Double = 0
    @State private var sparkles: [Sparkle] = (0..<7).map { _ in Sparkle() }

    private struct Sparkle {
        let angle = Double.random(in: 0...(2 * .pi))
        let radiusFraction = Double.random(in: 0.15...0.55)
        let twinkleOffset = Double.random(in: 0...(2 * .pi))
        let twinkleSpeed = Double.random(in: 0.8...1.6)
    }

    private struct Strand {
        let waves: Double
        let speed: Double
        let tiltDegrees: Double
        let colors: [Color]
        let lineWidthFactor: CGFloat
    }

    private static let strands: [Strand] = [
        Strand(waves: 3, speed: 1.0, tiltDegrees: 0,
               colors: [Color(hex: "#4C6BFF"), Color(hex: "#8B5CF6"), Color(hex: "#4C6BFF")],
               lineWidthFactor: 0.05),
        Strand(waves: 3, speed: -0.7, tiltDegrees: 55,
               colors: [Color(hex: "#8B5CF6"), Color(hex: "#E879F9"), Color(hex: "#8B5CF6")],
               lineWidthFactor: 0.045),
        Strand(waves: 4, speed: 0.5, tiltDegrees: 115,
               colors: [Color(hex: "#F5A96B"), Color(hex: "#4C6BFF"), Color(hex: "#F5A96B")],
               lineWidthFactor: 0.035),
    ]

    var body: some View {
        let energy = level

        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#6B7BFF").opacity(0.3 + energy * 0.25), .clear],
                        center: .center, startRadius: 0, endRadius: size * 0.75
                    )
                )
                .frame(width: size * 1.7, height: size * 1.7)
                .blur(radius: size * 0.16)

            ForEach(Array(Self.strands.enumerated()), id: \.offset) { _, strand in
                FlowingRibbon(phase: time * strand.speed, waves: strand.waves)
                    .stroke(
                        AngularGradient(colors: strand.colors, center: .center),
                        lineWidth: size * (strand.lineWidthFactor + energy * 0.025)
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(strand.tiltDegrees))
                    .blur(radius: size * 0.012)
            }

            ForEach(Array(sparkles.enumerated()), id: \.offset) { _, sparkle in
                let twinkle = 0.4 + 0.6 * max(0, sin(time * sparkle.twinkleSpeed + sparkle.twinkleOffset))
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.035, height: size * 0.035)
                    .opacity(twinkle * (0.5 + energy * 0.5))
                    .offset(
                        x: cos(sparkle.angle + time * 0.3) * size * sparkle.radiusFraction,
                        y: sin(sparkle.angle + time * 0.3) * size * sparkle.radiusFraction
                    )
            }
        }
        .compositingGroup()
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                time = 12 * (2 * .pi)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: level)
    }
}

/// A closed, wobbling ring — the base shape each `VoiceOrb` strand animates
/// through. Distinct wave counts/speeds/tilts per strand (see `VoiceOrb`)
/// are what make several of these read as loosely braided flowing ribbons
/// rather than concentric circles.
private struct FlowingRibbon: Shape {
    var phase: Double
    var waves: Double

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2
        let steps = 140
        var path = Path()

        for i in 0...steps {
            let theta = (Double(i) / Double(steps)) * 2 * .pi
            let wobble = 1 + 0.16 * sin(theta * waves + phase) + 0.06 * sin(theta * (waves + 1) - phase * 1.3)
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
        VoiceOrb(size: 48)
        VoiceOrb(size: 90, level: 0.6)
    }
    .padding()
    .background(Color.black)
}
