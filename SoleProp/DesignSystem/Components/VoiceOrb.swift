import SwiftUI

/// The voice assistant's entry point / speaking-listening indicator.
///
/// Replaces the earlier flat line-art braid with a lit, volumetric-reading
/// blob — modeled on the Figma reference's glossy sphere (soft ambient
/// glow, specular sheen, bright hot spot) but deliberately not a sphere.
/// **Two independent layers of motion, always both running:**
/// - A constant, gentle flow — never stops, never changes with
///   `isActive`/`level` — that's what gives it the ethereal, "always
///   alive" quality rather than reading as a dormant button.
/// - A pulse (scale + glow + a little extra shape amplitude) riding on
///   top, driven only by `level` (0...1 — live mic amplitude while
///   listening, live playback amplitude while Cue talks) — zero at rest,
///   so it's visibly reacting only when it's actually hearing or saying
///   something, without ever interrupting the constant flow underneath.
///
/// Every number driving its shape is computed directly from elapsed wall
/// -clock time inside the `TimelineView` tick — deliberately *not* via
/// SwiftUI's `withAnimation`/`.animation(value:)` system. Mixing that
/// system with a value that's already changing every frame (the phase)
/// means every incoming `level` update starts a brand new interpolation
/// racing against the phase that's already mid-flight, which is exactly
/// what caused the jittery, stuck-looking motion this replaces — two
/// animation systems fighting over the same `Shape.animatableData`. Plain
/// time-based easing can't fight itself.
struct VoiceOrb: View {
    /// The one size used everywhere this appears — Home's entry point and
    /// the full conversation screen both use this so the button reads as
    /// the same control throughout the app, not a smaller stand-in.
    static let standardSize: CGFloat = 72
    /// The bottom inset used wherever the orb is pinned to the bottom of
    /// a screen — shared so Home and the full conversation screen place
    /// it at exactly the same height, not just the same size.
    static let standardBottomInset: CGFloat = 4

    var size: CGFloat = VoiceOrb.standardSize
    var level: Double = 0
    var isActive: Bool = false

    // Smoothly-chased copies of `isActive`/`level`, each computed as a
    // plain eased function of elapsed time since it last changed — see
    // `smoothedEnergy`/`smoothedLevel` below.
    @State private var energyTransitionStart = Date.distantPast
    @State private var energyTransitionFrom: Double = 0
    @State private var lastIsActive = false

    @State private var levelTransitionStart = Date.distantPast
    @State private var levelTransitionFrom: Double = 0
    @State private var lastLevel: Double = 0

    // Friendly bluegreen/teal — ties to Tokens.Color.ochre (the app's new
    // accent) at the core, lightening toward a cyan-white highlight.
    private static let deepShadow = Color(hex: "#042F2E")
    private static let base = Color(hex: "#0D9488")
    private static let mid = Color(hex: "#2DD4BF")
    private static let bright = Color(hex: "#99F6E4")
    private static let hotSpot = Color(hex: "#F0FFFC")

    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date
            let phase = now.timeIntervalSinceReferenceDate * (2 * .pi / 7)
            let energy = smoothedEnergy(at: now)
            let lvl = smoothedLevel(at: now)
            orbContent(phase: phase, activeEnergy: energy, level: lvl)
                // Pins the *layout* size to exactly `size x size`,
                // regardless of how far the glow visually bleeds beyond
                // it (blur/offset rendering can paint outside a view's
                // frame without affecting layout — but only once
                // something actually declares that frame; nothing did
                // here before, so every parent layout (an HStack next to
                // the greeting text, Home's padding-based placement) was
                // sizing this view by its *biggest* child, the glow,
                // which is ~4x the nominal size).
                .frame(width: size, height: size)
        }
        .onAppear {
            lastIsActive = isActive
            lastLevel = level
            energyTransitionFrom = isActive ? 1 : 0
            levelTransitionFrom = level
        }
        .onChange(of: isActive) { _, newValue in
            energyTransitionFrom = smoothedEnergy(at: Date())
            energyTransitionStart = Date()
            lastIsActive = newValue
        }
        .onChange(of: level) { _, newValue in
            levelTransitionFrom = smoothedLevel(at: Date())
            levelTransitionStart = Date()
            lastLevel = newValue
        }
    }

    /// `isActive` eased smoothly over 0.6s rather than snapped to 0/1 —
    /// computed fresh from elapsed time, not from an animation transaction.
    private func smoothedEnergy(at date: Date) -> Double {
        let target: Double = lastIsActive ? 1 : 0
        let t = min(1, date.timeIntervalSince(energyTransitionStart) / 0.6)
        let eased = t * t * (3 - 2 * t) // smoothstep
        return energyTransitionFrom + (target - energyTransitionFrom) * eased
    }

    /// `level` chases its latest value over 0.25s instead of jumping on
    /// every ~60ms metering sample — this (not a SwiftUI animation) is
    /// what keeps the mic/playback amplitude from reading as jittery.
    private func smoothedLevel(at date: Date) -> Double {
        let t = min(1, date.timeIntervalSince(levelTransitionStart) / 0.25)
        let eased = t * t * (3 - 2 * t)
        return levelTransitionFrom + (lastLevel - levelTransitionFrom) * eased
    }

    private func orbContent(phase: Double, activeEnergy: Double, level: Double) -> some View {
        // The constant flow — always on, same whether idle, listening, or
        // speaking. This is what reads as "ethereal"; it never pauses and
        // never ramps with activity.
        let constantFlow = 0.1
        // The pulse — zero at rest, rides on top of the constant flow the
        // moment there's real sound (hearing you, or Cue's own voice).
        // Weighted well above the constant flow on every term (wobble,
        // glow, scale) so it unmistakably reads as "reacting to sound"
        // rather than blending into the ambient motion — the original
        // coefficients here (0.1 / 0.3 / 0.07 on scale below) were too
        // close to the idle baseline to notice at a glance.
        let pulse = level
        let wobble = constantFlow + pulse * 0.45
        let glow = 0.22 + activeEnergy * 0.08 + pulse * 0.55

        return ZStack {
            // A much wider, very faint second layer underneath the main
            // halo — many gradient stops easing out gently rather than
            // two stops dropping to clear, so the light appears to just
            // dissolve into the background with no point where a visible
            // "edge of the glow" ring would otherwise show.
            // (Opacities here read much fainter than they look in a
            // black-background preview — this sits on a white/light page,
            // which needs noticeably more opacity for the same visible
            // effect, not less.)
            Circle()
                .fill(
                    RadialGradient(
                        stops: [
                            .init(color: Self.mid.opacity(glow * 0.8), location: 0),
                            .init(color: Self.mid.opacity(glow * 0.45), location: 0.35),
                            .init(color: Self.mid.opacity(glow * 0.22), location: 0.65),
                            .init(color: Self.mid.opacity(glow * 0.08), location: 0.85),
                            .init(color: .clear, location: 1),
                        ],
                        center: .center, startRadius: 0, endRadius: size * 0.95
                    )
                )
                .frame(width: size * 1.9, height: size * 1.9)
                .blur(radius: size * 0.15)

            // The main, somewhat tighter halo — lightened (lower peak
            // opacity than before) so it reads as a soft bloom rather
            // than a saturated ring, and blended by the wider layer above
            // instead of ending on its own hard blur boundary.
            Circle()
                .fill(
                    RadialGradient(
                        stops: [
                            .init(color: Self.mid.opacity(glow * 1.1), location: 0),
                            .init(color: Self.mid.opacity(glow * 0.6), location: 0.4),
                            .init(color: Self.mid.opacity(glow * 0.25), location: 0.7),
                            .init(color: .clear, location: 1),
                        ],
                        center: .center, startRadius: 0, endRadius: size * 0.62
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)
                .blur(radius: size * 0.1)

            // The core itself stays sharp — blurring the whole fill (what
            // was here before) softened away exactly the edge detail the
            // wobble animates, which is why it stopped reading as moving
            // at all, and flattened the organic bumps into a plain smooth
            // ball. Only the rim should be soft.
            blobFill(phase: phase, amplitude: wobble)
                .frame(width: size, height: size)

            // A blurred glow traced *along* the same silhouette's edge
            // only (a stroke, not the fill) — this is what dissolves the
            // boundary into whatever's behind it without touching the
            // solid, clearly-animating body inside it.
            BlobShape(phase: phase, amplitude: wobble)
                .stroke(Self.mid.opacity(0.65), lineWidth: size * 0.16)
                .blur(radius: size * 0.05)
                .frame(width: size, height: size)

            // Kept crisp on top — a touch of sharp dimensionality is what
            // keeps this reading as lit and glassy rather than a flat,
            // featureless smear. Each already clips/positions itself to
            // the same blob silhouette.
            ZStack {
                specularSheen(phase: phase, amplitude: wobble)
                hotSpotHighlight
            }
            .frame(width: size, height: size)
        }
        .compositingGroup()
        .scaleEffect(1 + pulse * 0.22)
    }

    private func blobFill(phase: Double, amplitude: Double) -> some View {
        BlobShape(phase: phase, amplitude: amplitude)
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
    private func specularSheen(phase: Double, amplitude: Double) -> some View {
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
            .clipShape(BlobShape(phase: phase, amplitude: amplitude))
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
/// irregular blob rather than a perfect circle. `amplitude` scales the
/// wobble continuously (0 = a plain circle). Values passed in are always
/// plain, already-eased numbers (see `VoiceOrb.smoothed*` above) — this
/// shape is never itself wrapped in a SwiftUI animation.
private struct BlobShape: Shape {
    var phase: Double
    var amplitude: Double

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxRadius = min(rect.width, rect.height) / 2
        // Coefficients sum to 1, so the biggest possible `wobble` below is
        // `1 + amplitude`. Deflating the base radius by that same factor
        // means the silhouette can never draw outside this shape's own
        // frame no matter how large `amplitude` gets — SwiftUI doesn't
        // clip a Shape to its frame on its own.
        let radius = maxRadius / (1 + amplitude)
        let steps = 120
        var path = Path()

        for i in 0...steps {
            let t = Double(i) / Double(steps)
            let theta = t * 2 * .pi
            // Two gentle, close-frequency terms — not three — so this
            // reads as a soft, slightly uneven droplet, not a lumpy,
            // concave blob shape.
            let wobble = 1
                + amplitude * 0.7 * sin(theta * 2 + phase)
                + amplitude * 0.3 * sin(theta * 3 - phase * 1.3)
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
