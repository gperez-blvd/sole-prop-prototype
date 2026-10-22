import SwiftUI

/// The one entrance treatment used everywhere content "loads in" — a
/// gentle fade plus a small upward settle, staggered by `index` so a
/// group of rows/cards/sections cascades in one after another instead of
/// popping in all at once. Meant to be the shared convention: reach for
/// this on any new screen's initial content rather than inventing a new
/// appear animation per screen.
///
/// This is a ONE-SHOT appear, driven by a state flag that flips exactly
/// once on `onAppear` — not a continuously-updating value — so it
/// doesn't run into the animation-fighting problem documented on
/// `VoiceOrb` (where mixing SwiftUI's implicit animation system with a
/// value that changes every frame caused jittery, stuck-looking motion).
/// A plain `withAnimation` is the right tool here specifically because
/// nothing here changes again after it fires.
private struct StaggerAppearModifier: ViewModifier {
    var index: Int
    var baseDelay: Double
    var startDelay: Double
    var duration: Double
    var distance: CGFloat

    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : distance)
            .onAppear {
                withAnimation(.easeOut(duration: duration).delay(startDelay + Double(index) * baseDelay)) {
                    hasAppeared = true
                }
            }
    }
}

extension View {
    /// - Parameters:
    ///   - index: position in the cascade — 0 is first, 1 follows
    ///     `baseDelay` later, and so on. Pass a `ForEach` row's index,
    ///     or a small hand-picked constant for a handful of fixed
    ///     sections (header, title, body, CTA).
    ///   - baseDelay: gap between each step. 0.06s reads as "cascading
    ///     together"; stretch it toward 0.1–0.12s for a more deliberate,
    ///     one-at-a-time reveal on a shorter list.
    ///   - startDelay: a flat offset added before the cascade begins —
    ///     for when something else (a hero title drawing itself in, a
    ///     splash) needs to finish first.
    func staggerAppear(_ index: Int, baseDelay: Double = 0.06, startDelay: Double = 0, duration: Double = Tokens.Motion.Duration.moderate, distance: CGFloat = 10) -> some View {
        modifier(StaggerAppearModifier(index: index, baseDelay: baseDelay, startDelay: startDelay, duration: duration, distance: distance))
    }
}
