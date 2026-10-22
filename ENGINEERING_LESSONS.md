# ENGINEERING_LESSONS.md — mistakes we've made once, and the rule that stops them recurring

This file is hand-maintained, not generated. It exists because the same few classes of bug
and misuse keep resurfacing across sessions — a fix lands, the lesson lives only in that one
conversation's context, and a few weeks later the same shape of bug shows up again under a
different file name. Writing the rule down here is cheaper than re-discovering it.

**How to use this file:**
- Read it before touching animation, custom `Shape`s, scrollable rows with selection state, or
  anything that reuses a component across a forced-dark / forced-light context.
- When you (Claude or anyone) hit something that wasted real time — a bug, a bad pattern, a
  tooling gotcha — add an entry here before moving on. Lead with the rule, then **Why**, then
  **How to apply**. Keep entries platform-general when the lesson isn't actually iOS-specific;
  split out a "Swift/SwiftUI-specific" section only for the mechanics that really don't
  translate.
- This is the intended baseline for the Android build too. Section one is written to survive
  the platform switch as-is; section two is where the iOS-only mechanics live.

---

## 1. Platform-general rules (apply on iOS today, and on Android when we get there)

### Never render the "same" visual as two independent layout systems
**Rule:** if two things need to look like one coherent shape (an outline trace and its own
fill, an icon and its mask, a skeleton and its loaded content), they must be derived from a
**single** geometry/data value, never two separately-computed views that are merely *supposed*
to match.
**Why:** we shipped a screen where a traced outline (`GlyphPathShape`, fit to a `rect` via
CoreText) and a filled `Text("Cue")` (laid out by the font's own metrics) were assumed to line
up because they were "the same word." They are two unrelated layout systems with no shared
source of truth, and in practice they rendered as two visibly different "Cue"s stacked on each
other. The fix was to fill *and* stroke the exact same shape value.
**How to apply:** whenever a design calls for two visual treatments of "the same thing," ask
what the single shared value is that both treatments read from. If there isn't one, that's the
bug, not a rendering detail to debug later. On Android this is the same question for
`Path`/`Canvas` + `Text`, or any Compose `Modifier.drawWithContent` pairing.

### Slow, deliberate motion needs an asymmetric curve, not `easeInOut` stretched longer
**Rule:** a "considered, high-quality" animation (a hero reveal, a splash wordmark) should use a
strong deceleration curve — fast start, long confident settle — not a symmetric ease-in-ease-out
stretched to a longer duration.
**Why:** our first pass at the "Cue" draw-on animation used `.easeInOut` at 1.4s; lengthening the
duration alone made it read as *slow*, not *expressive* — it still had the mechanical,
start-stop-start-stop quality of a loading spinner. Switching to a cubic-bezier deceleration
curve (`timingCurve(0.16, 1, 0.3, 1, duration:)`) at 2.6s is what actually read as "handwriting."
**How to apply:** for anything meant to feel crafted rather than functional, reach for an
asymmetric/deceleration curve before reaching for a longer duration. Duration and easing are not
substitutes for each other.

### A scrollable row with a "lifts when selected" state needs room to lift in
**Rule:** if an item inside a scroll container scales or translates on selection, the container
must reserve padding in the direction of that transform — it cannot be sized flush to the item's
resting bounds.
**Why:** our appointment-time pills scale to 1.08× when selected. With the scroll container's
content sized exactly to the pills' resting height, the scaled-up state got its top and bottom
visually clipped — a real, shippable-looking bug, not a cosmetic nit.
**How to apply:** any time a list/row item animates size or position on interaction, add
padding (or an inset) to the scrolling axis's cross-dimension equal to at least the max growth,
before the feature is considered done — not after QA catches the clipping.

### A truncated scrollable row should fade, not guillotine
**Rule:** when a horizontally-scrolling row of items can run past a fixed-width container (a
"See more" affordance sits at the end, or the row is simply narrower than its content), mask the
truncated edge with a gradient fade rather than letting content end in a hard, mid-shape cut.
**Why:** a pill sliced cleanly in half at the container's edge reads as a layout bug even when
it's "working as intended" (there's more to scroll to). A soft fade signals "there's more here"
instead of "something broke."
**How to apply:** default to a trailing (or both-edge, if the row doesn't start at the content's
true beginning) alpha gradient mask on any horizontally-scrolling row that sits next to a fixed
affordance or a card edge. This is a `Modifier.graphicsLayer` + `Brush` fade on Android — same
rule, different API.

### Prefer one continuous, state-driven screen over multiple navigated screens for one flow
**Rule:** when several "screens" are really one task with different stages (log in vs. sign up,
a multi-step form), model it as a single view switching on a state enum, not as separate view
types pushed/popped on a navigation stack.
**Why:** separate screens for log-in and create-account forced a back-button/navigation
affordance to exist purely to move between two things that are conceptually one door. Collapsing
them into one `Step`-driven view removed the need for that navigation chrome entirely and made
the transition between stages animatable as state, not as a screen cut.
**How to apply:** before building a second screen for a flow, ask whether it's actually a
different task or just a different state of the same task. If it's the latter, it's a `switch`
on an enum inside one view, not a new file in the navigation graph. This applies identically to
Android (one Composable + a sealed-class state, not a second Fragment/destination).

### A nav icon's badge count is a product-principle violation, not a style choice
**Rule:** a top-bar/nav icon (bell, message, tab) never renders a live count on itself — no
numeral, no "9+", nothing that totals anything at her. If presence needs signaling at all, that
belongs inside the list itself (unread rows), never as a number glued to the icon that opens it.
**Why:** a design-system sweep found `BadgedIconButton` rendering `HomeMockData
.unreadNotificationCount` as a literal red number on the bell icon — a direct violation of
CLAUDE.md's "Counts are never badges... It is never a number on an icon" and its smells list,
which names "a badge, an unread dot, a notification tray" outright. This wasn't a deliberate,
documented exception (compare the PROTOTYPE section, which *is* one) — it was a leftover from
before that rule was internalized, sitting in otherwise-compliant code for multiple sessions
without anyone noticing it violated the project's own stated principle.
**How to apply:** before adding any new icon with a presence signal attached, check the
product's own stated rules first, not just visual taste. A plain icon button
(`HeaderIconButton`) replaced it; the underlying mock-data counts were deleted outright rather
than left unused, per this repo's own no-vestigial-code convention. On Android, apply the same
check before reaching for a `BadgeDrawable` or notification-dot composable — the rule is about
the product's restraint principle, not a SwiftUI-specific API.

### A decorative accent at full saturation reads neon, not luxurious
**Rule:** small decorative icon chips and status dots should use a softened, desaturated variant
of the brand accent — never the raw hue at full saturation, and never that hue at low *opacity*
over a dark surface (opacity alone makes a hue muddier on dark backgrounds, not lighter).
**Why:** `Tokens.Color.ochre`/`accentText` is tuned for contrast-critical small text and
checkmarks, and on dark surfaces that tuning makes it *identical to the raw, fully-saturated
hue* — correct for a checkmark, wrong once that same value fills a notification's icon circle or
an unread dot. It read as neon, which fights the self-care/luxury tone the rest of the app is
going for.
**How to apply:** keep a second, genuinely-lightened token (we added `Tokens.Color.accentSoft` /
`accentSoftTint`, backed by their own asset-catalog colorsets, not a computed opacity) for
decorative icon treatments and status dots. Reserve the raw accent for things actually conveying
state through color at a size where contrast matters. This is a product-tone rule as much as a
technical one — re-apply it on Android with whatever that platform's equivalent of a muted
secondary-accent token is, rather than reaching for the primary brand color at full strength on
every small icon.

### A back action belongs where the user's hands already are, named for what it does
**Rule:** when a multi-step flow needs to go back, that control should go back **one step**, be
visibly labeled as a back action, and live right above the content it affects — not be an
implicit side-effect of tapping an unrelated element (a logo, a title), and not jump all the way
to the start regardless of how many steps were taken.
**Why:** our first instinct was tap-the-wordmark-to-reset-everything, both because the logo was
already shrinking there and because it removed the need for a literal label. In practice this
hid a real action behind an element that didn't look interactive, and it over-corrected by
always resetting to the very first step instead of just undoing the most recent one.
**How to apply:** a back control is cheap to make explicit (a small chevron + "Back"/"All"
label). Don't fold it into an unrelated element's tap target for the sake of visual minimalism,
and make sure it steps back one stage, clearing only that stage's own fields.

---

## 2. Swift / SwiftUI-specific mechanics

- **`GlyphPathShape` (CoreText path) + `.trim`/`.stroke`/`.fill`:** always construct the shape
  value once conceptually and apply both `.fill` and `.stroke` to it (two `View`s built from the
  same `Shape` call is fine; two *different* `Shape`/`Text` types claiming to represent the same
  word is not). See rule above.
- **`.scaleEffect` inside a `ScrollView`:** the scroll container clips to its content's laid-out
  bounds, not to the post-transform bounds. Add `.padding(.vertical, n)` (or horizontal, matching
  the scroll axis's cross-dimension) to the `HStack`/`VStack` *inside* the `ScrollView`, sized to
  the largest expected `scaleEffect` overflow.
- **Truncation fades:** `.mask(LinearGradient(stops: [...], startPoint:, endPoint:))` directly on
  the `ScrollView`, with a `.clear` stop a little before the far edge (we used `0.86 → 1.0`) reads
  as a soft fade rather than a visible gradient band.
- **Forcing a screen to always render in dark mode regardless of the app's own appearance
  setting:** apply `.environment(\.colorScheme, .dark)` at that screen's root. Any shared,
  adaptive-token component used on that screen (anything reading a `Tokens.Color` that resolves
  differently in light/dark) will otherwise risk resolving to the *app's* current setting, not
  the screen's own fixed design — e.g. ink-on-ink text if the user's app-wide setting is Light
  while the screen itself is designed as permanently dark.
- **Sizing a sheet to fit its own content exactly:** don't measure content height at runtime
  (`GeometryReader` + `PreferenceKey`) and feed that back into `.presentationDetents` on the same
  view — the measurement starts at 0 before the first layout pass, so the sheet opens at whatever
  fallback detent you gave it (e.g. `.medium`), and updating `presentationDetents` on an
  already-presented sheet does not reliably resize it afterward. The result is a sheet visibly
  stuck at the oversized fallback with real content floating inside a mostly-empty sheet — not a
  temporary flash, a persistent wrong state. Compute the height analytically instead: fixed
  per-row `.frame(height:)` (not `minHeight`) times a known row count, plus known padding/divider
  constants, so `.presentationDetents([.height(exactValue)])` is correct on the very first frame.
- **Custom deceleration easing:** `Animation.timingCurve(0.16, 1, 0.3, 1, duration:)` is our
  go-to "confident settle" curve — keep reaching for it (or a similarly shaped curve) rather than
  re-deriving `easeInOut` variants per screen.

---

## 3. Tooling / verification notes (not app bugs — but they cost real time if undiagnosed)

### iOS Simulator automation: tap coordinates are in device points, not screenshot pixels
A `screenshot` result's image is at the device's native pixel resolution (e.g. 1206×2622 for an
iPhone 17), but `tap`/`swipe`/`computer`-style coordinates must be in the **device's point space**
reported in the `attach`/`launch` result's "Coordinate space" line (e.g. 402×874). Reusing
numbers read off the screenshot image directly (or off a scaled display of it) will land taps in
the wrong place or off-screen — this looks exactly like "the simulator isn't registering input,"
and is a real, recurring source of wasted retries in this project's sessions. Before concluding a
tap is being swallowed by simulator flakiness, re-derive the coordinate from the reported point
space, not the screenshot's pixel dimensions.

That said: taps genuinely do go missing intermittently in this environment even with correct
coordinates (confirmed by UI state simply not changing across an otherwise-identical retry, with
no keyboard/focus change either). When a tap doesn't register after one correctly-computed retry,
don't burn further turns re-tapping blindly.

### Sanctioned workaround: temporarily default past a gate to verify downstream UI
When input flakiness (or an auth/onboarding gate) blocks reaching the screen you actually need to
verify, it's fine to temporarily flip the relevant `@State` default (e.g. `phase: AppPhase = .home`
instead of `.auth`, or `showDailyBrief = false`) to see the real screen, confirm the change, and
then **revert the temporary default before considering the task done** — never leave a debug
default committed. Always rebuild after reverting to confirm the revert is clean.

### Process checklist this project follows (restated here for one-stop reference)
- Build with zero errors/warnings before calling anything verified.
- Verify UI changes live in the simulator when at all possible; say plainly when you can't,
  rather than asserting something you didn't actually see.
- Never leave a temporary debug override (`RootView` phase, a `showX` flag, etc.) in the diff
  you hand off.
- Never commit or merge without being explicitly asked, even after a successful verification.
