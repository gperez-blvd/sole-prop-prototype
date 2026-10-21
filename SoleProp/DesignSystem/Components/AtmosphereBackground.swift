import SwiftUI

/// A quiet atmospheric wash used behind the auth landing screen — a soft,
/// off-center glow (a sunrise/sunset, not a spotlight) in the brand
/// bluegreen, with a few blurred drifts of color so slow they read as
/// weather, not motion.
struct AtmosphereBackground: View {
    enum Style {
        /// Deepened a touch from `Tokens.Color.fog` so the glow has
        /// somewhere to sit — still light, just not paper-white. Pale
        /// enough that `Tokens.Color.textPrimary` drawn directly on top
        /// stays legible.
        case light
        /// An inverted, genuinely dark read of the same mood — same glow
        /// color and motion, just against near-black instead of near-
        /// white, so it reads as night rather than an off-tint of day.
        /// Anything drawn on top of this needs light text, not
        /// `Tokens.Color.textPrimary`.
        case dark
    }

    var style: Style = .light

    /// Exposed so anything that needs to fade into this background from
    /// the outside can match it instead of assuming plain fog.
    static let baseColor = Color(hex: "#F3F7F6")

    private var base: Color {
        switch style {
        case .light: Self.baseColor
        case .dark: Color(hex: "#0A1412")
        }
    }

    private var glow: Color { Tokens.Color.ochre }

    private var glowPeakOpacity: Double {
        switch style {
        case .light: 0.16
        // Brighter against the dark base, which otherwise swallows the
        // same opacities that read fine on light.
        case .dark: 0.5
        }
    }

    private struct Drift {
        let seed: Double
        let radius: CGFloat
        let period: Double
        let opacity: Double
    }

    private var drifts: [Drift] {
        switch style {
        case .light:
            [
                Drift(seed: 0, radius: 160, period: 52, opacity: 0.05),
                Drift(seed: 7, radius: 120, period: 68, opacity: 0.045),
                Drift(seed: 19, radius: 95, period: 61, opacity: 0.04),
            ]
        case .dark:
            [
                Drift(seed: 0, radius: 160, period: 52, opacity: 0.16),
                Drift(seed: 7, radius: 120, period: 68, opacity: 0.13),
                Drift(seed: 19, radius: 95, period: 61, opacity: 0.11),
            ]
        }
    }

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate

                ZStack {
                    base

                    // The off-center "sun" — a single soft radial glow, never
                    // sharp-edged, anchored high and to the side like a low
                    // sun rather than centered like a spotlight.
                    RadialGradient(
                        stops: [
                            .init(color: glow.opacity(glowPeakOpacity), location: 0),
                            .init(color: glow.opacity(glowPeakOpacity * 0.56), location: 0.4),
                            .init(color: glow.opacity(glowPeakOpacity * 0.19), location: 0.7),
                            .init(color: .clear, location: 1),
                        ],
                        center: UnitPoint(x: 0.78, y: 0.1),
                        startRadius: 0,
                        endRadius: 420
                    )

                    ForEach(Array(drifts.enumerated()), id: \.offset) { _, drift in
                        driftCircle(drift, at: t, in: proxy.size)
                    }
                }
                .compositingGroup()
            }
        }
    }

    private func driftCircle(_ drift: Drift, at t: Double, in size: CGSize) -> some View {
        // Each particle wanders a slow, lazy Lissajous-ish loop — never a
        // straight repeat, never fast enough to notice moving, only that
        // it's somewhere slightly different than before.
        let angle = (t / drift.period + drift.seed) * 2 * .pi
        let x = 0.5 + 0.32 * cos(angle)
        let y = 0.28 + 0.2 * sin(angle * 0.7 + drift.seed)

        return Circle()
            .fill(glow.opacity(drift.opacity))
            .frame(width: drift.radius * 2, height: drift.radius * 2)
            .blur(radius: drift.radius * 0.9)
            .position(x: size.width * x, y: size.height * y)
    }
}

#Preview("Light") {
    AtmosphereBackground(style: .light).ignoresSafeArea()
}

#Preview("Dark") {
    AtmosphereBackground(style: .dark).ignoresSafeArea()
}
