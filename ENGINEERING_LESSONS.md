# ENGINEERING_LESSONS.md — mistakes we've made once, and the rule that stops them recurring

This file is hand-maintained, not generated. It exists because the same few classes of bug
and misuse keep resurfacing across sessions — a fix lands, the lesson lives only in that one
conversation's context, and a few weeks later the same shape of bug shows up again under a
different file name. Writing the rule down here is cheaper than re-discovering it.

**How to use this file:**
- Read it before touching animation, custom `Shape`s, scrollable rows with selection state,
  stacked/layered cards, or anything that reuses a component across a forced-dark /
  forced-light context.
- When you (Claude or anyone) hit something that wasted real time — a bug, a bad pattern, a
  tooling gotcha, a design decision that had to be walked back — add an entry here before
  moving on, filed under whichever of the two categories below actually fits. Lead with the
  rule, then **Why**, then **How to apply**.
- This is the intended baseline for the Android build too. Sections 1 and 2 are written to
  survive the platform switch as-is; sections 3 and 4 are where the iOS-only mechanics and
  tooling notes live.

**The two categories, and why they're kept separate:**
- **§1 Bugs & Errors** — something that was factually broken, independent of taste: a
  rendering defect, a value computed wrong, a stuck UI state, a direct violation of an
  explicit written rule (CLAUDE.md). Nobody would defend the old behavior as "a reasonable
  choice that didn't work out" — it was simply incorrect.
- **§2 Unoptimized / Suboptimal Design Choices** — something that worked exactly as coded, and
  wasn't *wrong*, but turned out to be the weaker call once it was actually seen: an
  inconsistent visual language between two sibling components, a pattern that invited drift,
  a feature that over-built a card past what it needed. These are worth recording separately
  from bugs because the fix isn't "find the defect," it's "recognize the same weaker pattern
  before choosing it again."

When adding an entry, ask: *if nobody had ever looked at this, would it have stayed wrong
forever (bug), or would it have kept working, just not as well as the alternative (design
choice)?* That answer decides which section it goes in.

---

## 1. Bugs & Errors

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

### A scrollable row with a "lifts when selected" state needs room to lift in — in *every* axis the transform touches
**Rule:** if an item inside a scroll container scales or translates on selection, the container
must reserve padding in **every direction that transform actually moves**, not just the one
dimension that happened to get fixed first. `scaleEffect` grows a view in both width and height
at once — reserving buffer on only one axis still leaves the other to clip.
**Why:** our appointment-time pills scale to 1.08× when selected. The first pass reserved
vertical padding inside the horizontal `ScrollView`'s content (top/bottom no longer clipped),
but left no horizontal padding — so the *first* pill, sitting flush at the scroll content's
leading edge, had its left side clipped by the scroll view's own bounds the moment it scaled,
visible even before any scrolling happened. This is the same root cause as the original entry,
recurring because the fix was reasoned about one axis at a time instead of "what does this
transform actually do, in every dimension" — a rule already written down didn't prevent a
narrower-than-needed application of it.
**How to apply:** when a rule says "reserve padding for a transform," enumerate every axis that
transform moves before deciding the fix is complete — a `scaleEffect` always means *both* width
and height, a `rotationEffect` means a bounding-box change on both axes too, not just the one
that's visually obvious in the current layout direction.

### A truncated scrollable row should fade, not guillotine
**Rule:** when a horizontally-scrolling row of items can run past a fixed-width container (a
"See more" affordance sits at the end, or the row is simply narrower than its content), mask the
truncated edge with a gradient fade rather than letting content end in a hard, mid-shape cut.
**Why:** a pill sliced cleanly in half at the container's edge reads as a layout bug even when
it's "working as intended" (there's more to scroll to) — it is genuinely indistinguishable from
a defect without reading the code.
**How to apply:** default to a trailing (or both-edge, if the row doesn't start at the content's
true beginning) alpha gradient mask on any horizontally-scrolling row that sits next to a fixed
affordance or a card edge. This is a `Modifier.graphicsLayer` + `Brush` fade on Android — same
rule, different API.

### Stacking `.opacity()` on an already-translucent color token is accidental transparency
**Rule:** before calling `.opacity(x)` on a color, check whether that color is itself already
partially transparent (e.g. a token like `accentTint` defined as `ochre.opacity(0.12)`). If so,
the two opacities multiply, not average — `accentTint.opacity(0.14)` isn't "a slightly fainter
accentTint," it's ~0.017 alpha, which reads as "this part of the view is just see-through."
**Why:** `CueCard`'s background used to be a `LinearGradient` from `Tokens.Color.surface` to
`Tokens.Color.accentTint.opacity(0.14)`. In a stacked-card layout (`DetailMomentStack`), the
nearly-invisible gradient stop let the card sitting behind it bleed straight through the front
card's own body — not peeking around its edges, visible *inside* its rounded rect. It looked
exactly like a transparency bug because it was one.
**How to apply:** a gradient or overlay that needs to fade to "nothing" should fade to `.clear`
(or to the page's own background color) layered *on top of* an already fully-opaque base — never
let the base fill itself be, or blend toward, a color with alpha < 1. A sheen/highlight effect
belongs in a separate `overlay()` that fades to `.clear` over an opaque base; it should never be
baked into the base fill's own gradient stops.

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
without anyone noticing it violated the project's own stated principle. A written rule being
violated in shipped code is a bug, not a matter of opinion about badges.
**How to apply:** before adding any new icon with a presence signal attached, check the
product's own stated rules first, not just visual taste. A plain icon button
(`HeaderIconButton`) replaced it; the underlying mock-data counts were deleted outright rather
than left unused, per this repo's own no-vestigial-code convention. On Android, apply the same
check before reaching for a `BadgeDrawable` or notification-dot composable.

### A computed property returning `Identifiable` structs needs a stable `id`, never `let id = UUID()`
**Rule:** if a model's instances are produced by a computed property or a function that runs
again on every view re-render (not cached, not stored in `@State`), its `id` must be derived
from the data itself (a label, a key, a hash of meaningful fields) — never `let id = UUID()`,
which mints a new identity on every single call, including calls that return "the same" data.
**Why:** `RevenuePoint` and `RankedMetric` both had `let id = UUID()`. Both types were produced
by computed properties (`HomeMockData.serviceMix`, `.productUsage`, `.revenueSeries(for:)`) that
SwiftUI calls again on every body re-evaluation — not just when the underlying range actually
changed. Every call produced brand-new UUIDs, so `ForEach`'s diffing saw "entirely different
items" constantly, not "the same items, new values." The visible symptom was bars that appeared
to pop in from nothing and grow, rather than an existing bar smoothly resizing — because as far
as SwiftUI's animation system was concerned, there was no existing bar to resize, only a new one
being inserted. This is a silent failure mode: the code compiles, the chart renders correctly at
rest, and it only breaks the one thing (cross-update animation) that's hard to notice without
actually watching a transition happen.
**How to apply:** for any `Identifiable` model backing a `ForEach` whose source is a computed
property/function rather than a stored, create-once value, make `id` a computed property derived
from a stable field (`var id: String { label }`), not a stored `UUID()`. If the data doesn't have
a natural stable key, that's a sign the modeling itself needs one before animation will ever work
right. The same rule applies to Compose's `key()`/`LazyColumn` item keys on Android — a freshly
-generated key per recomposition is the same bug under a different API.

### A system `Divider()` over a translucent/material background renders unpredictably
**Rule:** don't use SwiftUI's native `Divider()` on top of a `.presentationBackground` material,
a blurred backdrop, or any non-opaque-flat-color surface. Either draw an explicit hairline
(`Rectangle().fill(Tokens.Color.hairline).frame(height: 1)`, the pattern already used in
`ClientListView`/`NotificationsView`/etc.) or remove the divider altogether if row height alone
gives enough separation.
**Why:** `MenuSheet`'s rows used `Divider()` once the sheet's backdrop became a soft frosted
material (`.ultraThinMaterial` + a tint). The system control's separator color is computed per
-context and does not render predictably over a material — the dividers visibly faded/looked
broken rather than reading as a clean hairline. This was reported as "the dividers are fading
strangely," and it was: `Divider()`'s automatic color resolution is simply not designed for
that backdrop.
**How to apply:** treat `Divider()` as safe only over a flat, fully-opaque `Tokens.Color`
background. Anywhere a material/blur/gradient backdrop is in play, use an explicit hairline
`Rectangle` (full control over its exact color and opacity) or, as we did here, remove the
divider in favor of generous fixed row height.

### Measuring a sheet's content height at runtime to set its own detent does not work
**Rule:** don't measure a view's real height with `GeometryReader` + `PreferenceKey` and feed
that measurement back into `.presentationDetents` on the same sheet. Compute the height
analytically instead — fixed per-row `.frame(height:)` (not `minHeight`) times a known row
count, plus known padding/divider constants — so `.presentationDetents([.height(exactValue)])`
is correct on the very first frame.
**Why:** the measured value starts at `0` before the first layout pass, so the sheet opens at
whatever fallback detent was given (e.g. `.medium`, ~50% of the screen). Updating
`presentationDetents` on an *already-presented* sheet does not reliably resize it afterward, so
the sheet was visibly stuck at that oversized fallback with real content floating inside a
mostly-empty sheet — not a temporary flash on first open, a persistent wrong state for as long
as the sheet stayed up. This is exactly the "this menu still looks very tall" bug reported
against `MenuSheet`.
**How to apply:** know the height up front. If the content is dynamic enough that it truly
can't be computed analytically, don't use a custom `.height()` detent at all — fall back to
`.medium`/`.large` and accept the imprecision, rather than attempting runtime measurement that
SwiftUI won't act on in time.

### A sheet's own background must be set via `presentationBackground`, not `.background()` on its content
**Rule:** `.background(_:)` applied to a sheet's root content view only paints that content's own
laid-out area. Any extra space the system sheet reserves around it (most commonly the
home-indicator safe-area sliver at the bottom) is not part of that view and falls back to the
sheet's default system material. Use `.presentationBackground { ... }` to set the backdrop for
the whole sheet, content and reserved space alike.
**Why:** `MenuSheet` painted its rows with `.background(Tokens.Color.background)`, but the
sliver below the last row (reserved for the home indicator) kept showing the system's default
blurred material — a visible seam between "our background" and "the system's," reported as
"extremely strange... spacing at the top and bottom."
**How to apply:** for any sheet with a custom background — solid, tinted, or a frosted
material — set it with `.presentationBackground`, not a content-level `.background()`.

---

## 2. Unoptimized / Suboptimal Design Choices

### Slow, deliberate motion needs an asymmetric curve, not `easeInOut` stretched longer
**Rule:** a "considered, high-quality" animation (a hero reveal, a splash wordmark) should use a
strong deceleration curve — fast start, long confident settle — not a symmetric ease-in-ease-out
stretched to a longer duration.
**Why:** our first pass at the "Cue" draw-on animation used `.easeInOut` at 1.4s; lengthening the
duration alone made it read as *slow*, not *expressive* — it still had the mechanical,
start-stop-start-stop quality of a loading spinner. Nothing was broken — the animation ran
exactly as coded — it just wasn't the right feel. Switching to a cubic-bezier deceleration curve
(`timingCurve(0.16, 1, 0.3, 1, duration:)`) at 2.6s is what actually read as "handwriting."
**How to apply:** for anything meant to feel crafted rather than functional, reach for an
asymmetric/deceleration curve before reaching for a longer duration. Duration and easing are not
substitutes for each other.

### Prefer one continuous, state-driven screen over multiple navigated screens for one flow
**Rule:** when several "screens" are really one task with different stages (log in vs. sign up,
a multi-step form), model it as a single view switching on a state enum, not as separate view
types pushed/popped on a navigation stack.
**Why:** separate screens for log-in and create-account forced a back-button/navigation
affordance to exist purely to move between two things that are conceptually one door. Both
screens worked correctly — this wasn't a bug — but collapsing them into one `Step`-driven view
removed the need for that navigation chrome entirely and made the transition between stages
animatable as state, not as a screen cut.
**How to apply:** before building a second screen for a flow, ask whether it's actually a
different task or just a different state of the same task. If it's the latter, it's a `switch`
on an enum inside one view, not a new file in the navigation graph. This applies identically to
Android (one Composable + a sealed-class state, not a second Fragment/destination).

### A decorative accent at full saturation reads neon, not luxurious
**Rule:** small decorative icon chips and status dots should use a softened, desaturated variant
of the brand accent — never the raw hue at full saturation, and never that hue at low *opacity*
over a dark surface (opacity alone makes a hue muddier on dark backgrounds, not lighter).
**Why:** `Tokens.Color.ochre`/`accentText` is tuned for contrast-critical small text and
checkmarks, and on dark surfaces that tuning makes it *identical to the raw, fully-saturated
hue* — correct for a checkmark, a defensible-looking choice, but wrong in effect once that same
value filled a notification's icon circle or an unread dot. It read as neon, which fights the
self-care/luxury tone the rest of the app is going for. Nothing here was incorrect code; it was
the wrong token reused in the wrong context.
**How to apply:** keep a second, genuinely-lightened token (we added `Tokens.Color.accentSoft` /
`accentSoftTint`, backed by their own asset-catalog colorsets, not a computed opacity) for
decorative icon treatments and status dots. Reserve the raw accent for things actually conveying
state through color at a size where contrast matters. Re-apply this on Android with whatever
that platform's equivalent of a muted secondary-accent token is.

### A back action belongs where the user's hands already are, named for what it does
**Rule:** when a multi-step flow needs to go back, that control should go back **one step**, be
visibly labeled as a back action, and live right above the content it affects — not be an
implicit side-effect of tapping an unrelated element (a logo, a title), and not jump all the way
to the start regardless of how many steps were taken.
**Why:** our first instinct was tap-the-wordmark-to-reset-everything, both because the logo was
already shrinking there and because it removed the need for a literal label. It worked, in the
sense that it did take you back — but it hid a real action behind an element that didn't look
interactive, and it over-corrected by always resetting to the very first step instead of just
undoing the most recent one.
**How to apply:** a back control is cheap to make explicit (a small chevron + "Back"/"All"
label). Don't fold it into an unrelated element's tap target for the sake of visual minimalism,
and make sure it steps back one stage, clearing only that stage's own fields.

### A shared button/CTA style must be decided once, not reinvented per card
**Rule:** when a family of sibling components (here, Home's stacked `DetailMoment` cards —
`CueCard`, `ThresholdProposalCard`) each need an actionable button, define that treatment as one
shared component and have every card use it — never let each card's button evolve its own look
independently.
**Why:** `CueCard`'s "Got it" started as a neutral filled pill while `ThresholdProposalCard`'s
option chips were teal-outlined — both individually reasonable-looking choices, made at
different times without either one referencing the other. Sitting next to each other in the same
stack, they read as inconsistent: "this card's actions matter enough to be teal, that one's
don't." Neither version was broken; they just hadn't been decided *together*.
**How to apply:** the fix was `CardChoiceButton`, one shared component both cards now call for
their actionable buttons. Before giving a new card its own button styling, check whether a
sibling component in the same family already has one — reuse it rather than inventing a
visually-plausible-on-its-own variant.

### A new screen defaults to the type scale and spacing tokens, not ad hoc values
**Rule:** when building a new screen from scratch, reach for `Tokens.Typography`'s named steps
(`.label`, `.body`, `.value`, `.largeTitle`, …) and `Tokens.Spacing`'s named steps for every
piece of text and every gap — never a bespoke hardcoded font size or a bare integer like
`spacing: 14`. If a screen needs something the scale doesn't have, that's a signal to add a
token, not to freelance one inline.
**Why:** `LogsView`'s first pass used `.label`/`.labelSmall`/`.caption` (14/12/14pt) for chart
category names, counts, and axis labels, and `spacing: 14`/a `34pt` bar-row height picked by
eye — all individually defensible, all landing well below what the rest of the app actually
uses for primary content, and the accumulated effect was a screen that read as cramped and
undersized even on a large preview, on a screen whose entire job is to be read as data. This
happened on the *same pass* that also reused the full-saturation `accentText` for the bars —
a repeat of "A decorative accent at full saturation reads neon, not luxurious" above, in code
written after that rule already existed. Both are the same root cause: new code written
without checking the system already has an answer for the thing being built.
**How to apply:** before shipping a new screen, re-read it against `DESIGN_SYSTEM.md`'s scale
and ask whether each text style and each gap is a named step or a number that was eyeballed.
Category/row labels that are primary reading content belong at `.body` (16pt) or above, not
`.caption`/`.labelSmall` — those are for genuine metadata. Spacing between a card's major
sub-sections belongs on `Tokens.Spacing`'s scale (`.md`/`.lg`), not a bespoke `14`.

### Check for an existing branded component before reaching for a system control
**Rule:** before using a stock SwiftUI control (`.pickerStyle(.segmented)`, a default `Divider()`,
a system `Toggle`, etc.) for a UI pattern that already exists elsewhere in the app with its own
branded look, check whether that pattern has already been solved — and promote it to a shared
component rather than letting the system default and the branded version coexist.
**Why:** `ScheduleView` already had a branded Day/Week switch (a filled `primaryFill` pill in a
`silt` track) when `WalletView` needed its own Wallet/Transactions switch. Nothing was wrong with
reaching for `.pickerStyle(.segmented)` in isolation — it's a real, working system control — but
sitting in the same app as `ScheduleView`'s bespoke version, it reads as a different design
system entirely: a gray capsule with a system-tinted highlight next to a hand-tuned ink-filled
pill.
**How to apply:** the fix was extracting `ScheduleView`'s existing toggle into
`SegmentedToggle`, a shared component now used by both screens. Before implementing a UI pattern
a screen needs (a mode switch, a date picker, a segmented control), search the design system and
sibling screens for one first — the system default is rarely wrong on its own, but it's
frequently wrong *next to* a component this app already built for the exact same job.

### Don't bolt a disclosure-and-decline path onto every actionable card by default
**Rule:** a card built around one decision (pick option A or B) doesn't automatically need a
"why are you asking?" reasoning disclosure or a "not now" decline action just because those are
easy to add. Add them only when there's a real need to explain or defer the decision — not as a
default feature of "a card that asks something."
**Why:** `ThresholdProposalCard` shipped with both a `showReasoning` toggle ("Why are you
asking?" / "Hide why") and a "Not now" decline button, in addition to its two real options. Nothing
about this was incorrect — it worked, the toggle toggled, the decline declined — but it made a
one-question card into a four-path card (option A, option B, show reasoning, decline), which
is more surface than the actual decision needed. CLAUDE.md's own "Behind" tier already covers
reasoning-on-demand as a separate, deliberate disclosure level — bolting a miniature version of
it onto every proposal card duplicates that without being asked to.
**How to apply:** when designing a card around a decision, count the real paths out of it before
adding affordances. If the only two sane outcomes are "pick A" or "pick B," those are the only
two controls the card needs. Add a decline/defer path only when there's a concrete reason she'd
need one, not preemptively because the pattern is easy to copy from elsewhere.

---

## 3. Swift / SwiftUI-specific mechanics

- **`GlyphPathShape` (CoreText path) + `.trim`/`.stroke`/`.fill`:** always construct the shape
  value once conceptually and apply both `.fill` and `.stroke` to it (two `View`s built from the
  same `Shape` call is fine; two *different* `Shape`/`Text` types claiming to represent the same
  word is not). See §1.
- **`.scaleEffect` inside a `ScrollView`:** the scroll container clips to its content's laid-out
  bounds, not to the post-transform bounds. Add padding to the `HStack`/`VStack` *inside* the
  `ScrollView` on **both** the scroll axis and its cross-axis — `scaleEffect` grows a view in
  both width and height regardless of which way it scrolls, so padding only one side (e.g. just
  `.padding(.vertical,n)` on a horizontally-scrolling row) still clips the first/last item's
  scaled-up edge on the unpadded axis. See §1.
- **A multi-beat animation ("do X, then once that's visibly settled, do Y") needs its own
  explicit, sequenced `@State`, not one ambient `.animation(value:)`:** SwiftUI's implicit
  animation can express "this property changed, animate it," but not "change this property,
  wait, then change that one" — a single `.animation(value:)` modifier animates everything bound
  to that value in one simultaneous pass. For a staged transition (`AnimatedBarChart`'s width
  -reflow-then-height-resize when switching Week/Month/Year), own the intermediate state inside
  the component (`visibleCount` for phase 1, `displayedAmounts`/`displayedMax` for phase 2), fire
  phase 1 in an explicit `withAnimation`, then schedule phase 2's `withAnimation` after phase 1's
  own duration (`DispatchQueue.main.asyncAfter(deadline: .now() + phaseGap)`). The two
  animations' durations should be named constants referenced by both the animation itself and
  the delay, so they can't drift out of sync with each other.
- **Truncation fades:** `.mask(LinearGradient(stops: [...], startPoint:, endPoint:))` directly on
  the `ScrollView`, with a `.clear` stop a little before the far edge (we used `0.86 → 1.0`) reads
  as a soft fade rather than a visible gradient band.
- **Forcing a screen to always render in dark mode regardless of the app's own appearance
  setting:** apply `.environment(\.colorScheme, .dark)` at that screen's root. Any shared,
  adaptive-token component used on that screen (anything reading a `Tokens.Color` that resolves
  differently in light/dark) will otherwise risk resolving to the *app's* current setting, not
  the screen's own fixed design — e.g. ink-on-ink text if the user's app-wide setting is Light
  while the screen itself is designed as permanently dark.
- **Sizing a sheet to fit its own content exactly:** see §1's measure-then-resize entry — compute
  the height analytically, never via runtime `GeometryReader` measurement fed back into
  `presentationDetents`.
- **A sheet's background:** see §1 — `.presentationBackground`, not a content-level `.background()`.
- **Dividers over materials:** see §1 — an explicit hairline `Rectangle`, not `Divider()`, over
  any non-flat-opaque backdrop.
- **Custom deceleration easing:** `Animation.timingCurve(0.16, 1, 0.3, 1, duration:)` is our
  go-to "confident settle" curve — keep reaching for it (or a similarly shaped curve) rather than
  re-deriving `easeInOut` variants per screen.

---

## 4. Tooling / verification notes (not app bugs — but they cost real time if undiagnosed)

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
