import SwiftUI

/// The voice assistant's entry point / speaking-listening indicator.
/// **Paused** (`isActive == false`): a plain, calm gradient ring — solid
/// and still. **Listening** (`isActive == true`): several interwoven,
/// independently-flowing glowing ribbon strands with traveling light
/// particles, modeled on the reference art George shared
/// (dribbble.com/shots/27188223's braided-light-ring look). `level` (0...1,
/// live mic amplitude) widens the strands and speeds/brightens everything
/// further while active.
struct VoiceOrb: View {
    var size: CGFloat = 53
    var level: Double = 0
    var isActive: Bool = false

    @State private var time: Double = 0

    private struct Strand {
        let waves: Double
        let speed: Double
        let tiltDegrees: Double
        let colors: [Color]
        let lineWidthFactor: CGFloat
        let particleOffsets: [Double] // 0...1 positions along the ribbon, at t=0
    }

    // Bluish/greenish/purplish only — no orange/pink.
    private static let strands: [Strand] = [
        Strand(waves: 3, speed: 1.0, tiltDegrees: 0,
               colors: [Color(hex: "#4C6BFF"), Color(hex: "#22D3AA"), Color(hex: "#4C6BFF")],
               lineWidthFactor: 0.05, particleOffsets: [0, 0.5]),
        Strand(waves: 3, speed: -0.7, tiltDegrees: 55,
               colors: [Color(hex: "#8B5CF6"), Color(hex: "#34D399"), Color(hex: "#8B5CF6")],
               lineWidthFactor: 0.045, particleOffsets: [0.25, 0.75]),
        Strand(waves: 4, speed: 0.5, tiltDegrees: 115,
               colors: [Color(hex: "#22D3EE"), Color(hex: "#8B5CF6"), Color(hex: "#4C6BFF"), Color(hex: "#22D3EE")],
               lineWidthFactor: 0.035, particleOffsets: [0.1, 0.6]),
    ]

    private static let idleGradientColors: [Color] = [
        Color(hex: "#4C6BFF"), Color(hex: "#22D3AA"), Color(hex: "#8B5CF6"), Color(hex: "#4C6BFF"),
    ]

    var body: some View {
        ZStack {
            if isActive {
                activeContent
            } else {
                idleContent
            }
        }
        .compositingGroup()
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                time = 12 * (2 * .pi)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: level)
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }

    /// Plain, calm, solid-reading ring — no motion, no particles. Reads as
    /// "off" without going fully invisible.
    private var idleContent: some View {
        Circle()
            .stroke(
                AngularGradient(colors: Self.idleGradientColors, center: .center),
                lineWidth: size * 0.07
            )
            .frame(width: size, height: size)
    }

    private var activeContent: some View {
        let energy = level

        return ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#4C6BFF").opacity(0.35 + energy * 0.25), .clear],
                        center: .center, startRadius: 0, endRadius: size * 0.75
                    )
                )
                .frame(width: size * 1.7, height: size * 1.7)
                .blur(radius: size * 0.16)

            ForEach(Array(Self.strands.enumerated()), id: \.offset) { _, strand in
                let strandPhase = time * strand.speed

                FlowingRibbon(phase: strandPhase, waves: strand.waves)
                    .stroke(
                        AngularGradient(colors: strand.colors, center: .center),
                        lineWidth: size * (strand.lineWidthFactor + energy * 0.025)
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(strand.tiltDegrees))
                    .blur(radius: size * 0.012)

                ForEach(Array(strand.particleOffsets.enumerated()), id: \.offset) { _, startT in
                    let t = (startT + time * 0.05 * (strand.speed >= 0 ? 1 : -1)).truncatingRemainder(dividingBy: 1)
                    let local = FlowingRibbon.point(
                        at: t < 0 ? t + 1 : t, phase: strandPhase, waves: strand.waves, radius: size / 2
                    )
                    // Rotate the sampled point by the strand's tilt manually — an
                    // `.offset` this small can't be corrected by `.rotationEffect`
                    // (that rotates the view around its own center, not the offset).
                    let tiltRadians = strand.tiltDegrees * .pi / 180
                    let x = local.x * cos(tiltRadians) - local.y * sin(tiltRadians)
                    let y = local.x * sin(tiltRadians) + local.y * cos(tiltRadians)

                    Circle()
                        .fill(strand.colors.first ?? .white)
                        .frame(width: size * (0.05 + energy * 0.02), height: size * (0.05 + energy * 0.02))
                        .blur(radius: size * 0.01)
                        .offset(x: x, y: y)
                }
            }
        }
    }
}

/// A closed, wobbling ring — the base shape each active `VoiceOrb` strand
/// animates through. Distinct wave counts/speeds/tilts per strand (see
/// `VoiceOrb`) are what make several of these read as loosely braided
/// flowing ribbons rather than concentric circles. `point(at:)` samples the
/// same curve so particles can travel exactly along a strand's rendered path.
private struct FlowingRibbon: Shape {
    var phase: Double
    var waves: Double

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let steps = 140
        var path = Path()

        for i in 0...steps {
            let t = Double(i) / Double(steps)
            let offset = Self.point(at: t, phase: phase, waves: waves, radius: radius)
            let point = CGPoint(x: center.x + offset.x, y: center.y + offset.y)
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }

    /// The ribbon's offset from center at fraction `t` (0...1) around the
    /// loop, for the given `phase`/`waves` — a plain function so both the
    /// `Shape` outline and travelling particles sample identical geometry.
    static func point(at t: Double, phase: Double, waves: Double, radius: Double) -> CGPoint {
        let theta = t * 2 * .pi
        let wobble = 1 + 0.16 * sin(theta * waves + phase) + 0.06 * sin(theta * (waves + 1) - phase * 1.3)
        let r = radius * wobble
        return CGPoint(x: r * cos(theta), y: r * sin(theta))
    }
}

#Preview {
    VStack(spacing: 40) {
        VoiceOrb(size: 53, isActive: false)
        VoiceOrb(size: 53, level: 0.6, isActive: true)
        VoiceOrb(size: 90, level: 0.6, isActive: true)
    }
    .padding()
    .background(Color.black)
}
