# Cue's design system

A native-first system, built from this app's own foundation rather than
adopted wholesale from anywhere else. Where it borrows, it borrows
**patterns** — how a mature product scales and ranges its tokens, not its
literal colors or exact pixel values. Airbnb was the explicit reference
point for that pattern language; nothing here uses Airbnb's actual brand
colors, type sizes, or radii.

All of it lives in code, not in a separate spec that can drift from the
app: `SoleProp/DesignSystem/Tokens.swift` is the source of truth, and
everything below describes what's already there and why.

> **A note on provenance.** Airbnb has never published an official,
> public design-system spec. Every "Airbnb uses X" claim anywhere in
> this document (and in the commit history that built it) is inferred
> from the live product and third-party reverse-engineering, and
> sources disagree with each other in places. Treat those claims as "the
> most consistent story across several teardowns," not ground truth.

---

## 1. Spacing

An 8px base grid — Airbnb's most consistently reported spacing
convention, across every source that disagreed on nearly everything
else.

```swift
Tokens.Spacing.xs    // 4
Tokens.Spacing.sm    // 8
Tokens.Spacing.md    // 16
Tokens.Spacing.lg    // 24
Tokens.Spacing.xl    // 32
Tokens.Spacing.xxl   // 48
Tokens.Spacing.xxxl  // 64
```

`xxl`/`xxxl` were added for screen-level gaps (hero sections, a landing
screen's top-to-bottom rhythm) that previously fell back to a magic
number because no token reached that far.

## 2. Corner radius

Tightened toward Airbnb's own corner language on purpose — their single
most consistently reported value, across every source, is an **8px
button radius**: crisp, not the soft/bubbly shape this app used before.

```swift
Tokens.Radius.sm      // 6  — small chips, checkboxes
Tokens.Radius.md       // 10 — compact tiles, input fields
Tokens.Radius.card     // 14 — every card/container
Tokens.Radius.lg       // 20 — larger sheets/surfaces
Tokens.Radius.pill     // 999
Tokens.Radius.button   // 8  — every tappable button
```

Every tappable control and every card in the app now draws from one of
these six numbers. The only literal `cornerRadius` values left in the
codebase are two deliberate micro-exceptions: `MenuSheet`'s PROTOTYPE
debug box (4pt — demo-only chrome, explicitly exempt from the "her
words, not ours" rules elsewhere too) and `RemainingAppointmentsCard`'s
tiny hour-bar decoration (2pt — a sliver of a status bar, not a UI
control).

## 3. Color

**One accent, used the way Airbnb uses Rausch** — carrying every
primary decorative moment (the orb, fills, borders, glows) as one fixed
hue, never diluted into secondary "brand" colors. We kept our own hue
(`#14B8A6`, a bluegreen) rather than adopting Rausch's red — the pattern
being borrowed is "one accent, disciplined," not "which accent."

```swift
Tokens.Color.ochre              // the fixed accent — fills, borders, glows, the orb
Tokens.Color.accentText         // ↓ see below
Tokens.Color.accentTint         // ochre @ 12% — selected-state washes
Tokens.Color.accentBorder       // ochre @ 50% — secondary outlines
Tokens.Color.accentBorderStrong // ochre @ 70% — emphasized outlines
```

**The one real accessibility finding in this whole audit:** `ochre` sits
at roughly **2.5:1 contrast against a white surface** — it fails even
the lenient 3:1 non-text minimum, let alone 4.5:1 for text — while
clearing ~7:1 against our dark surface. It was in use as foreground
text/icon color in 19 places. `accentText` is the fix: an
appearance-adaptive variant, darkened to `#0F766E` on light (passes AA),
identical to `ochre` on dark (where the raw hue already passes). Airbnb
follows the exact same discipline with Rausch — it's a decorative
accent, never what renders small text.

**Neutral ramp** — adaptive, backed by a real asset catalog
(`Colors.xcassets`), not a `UIColor { traitCollection in }` closure
(that approach looked correct in code but didn't reliably repaint when
the appearance setting changed — text kept resolving to its light-mode
value):

```swift
Tokens.Color.background     // page background
Tokens.Color.surface        // card/elevated fill
Tokens.Color.silt           // subtle pill/segment fill
Tokens.Color.textPrimary    // pure white in dark mode, not a soft gray
Tokens.Color.textSecondary
Tokens.Color.textTertiary
Tokens.Color.primaryFill    // a solid button's own fill (inverts per appearance)
Tokens.Color.onPrimaryFill  // that button's label color
Tokens.Color.hairline       // faint border, used sparingly — prefer Shadow
```

Dark mode is a **neutral charcoal** (`#161718`), deliberately not tinted
toward the accent's own hue — an earlier pass leaned the whole dark
palette green/teal, which read as overwhelming once it covered every
surface rather than sitting behind one hero gradient. The app now
defaults to dark; light/dark/auto is a real setting in the menu
(`AppearanceSetting`), not just a system fallback. The one deliberate
exception: the auth landing screen keeps its own fixed dark atmospheric
gradient regardless of that setting — it's a hero moment, not a
surface.

## 4. Typography

A discrete modular scale — **12 · 14 · 16 · 18 · 22 · 28 · 32** — same
spirit as Airbnb's own type scale: a tight ~1.1–1.2× step through the
body-text range, then a wider jump into display sizes, rather than
continuous per-screen numbers (11.5, 13, 13.5, 17, 20, 24, 30... all
existed in this app at one point).

```swift
Tokens.Typography.largeTitle   // 32, semibold — hero titles only, one per screen
Tokens.Typography.title        // 22, medium  — section/screen titles
Tokens.Typography.value        // 18, medium  — a card's own headline, a price, a count
Tokens.Typography.body         // 16, medium  — primary reading weight
Tokens.Typography.bodyRegular  // 16, regular — same step, lighter weight, longer copy
Tokens.Typography.button       // 16, medium  — button labels share body's step
Tokens.Typography.caption      // 14, regular
Tokens.Typography.label        // 14, regular
Tokens.Typography.labelSmall   // 12, regular — the floor for real content
```

Hierarchy comes from size and step, not weight — `.semibold` (used only
for `largeTitle`) is the heaviest weight anywhere in the scale.

Two documented exceptions, each with a reason: the landing screen's 72pt
"Cue" wordmark (a one-off hero size, not part of the reusable scale) and
the notification-count badge at 10pt (UI chrome, not reading content —
the same exemption icon glyphs already get).

**Dynamic Type.** This was the one real gap the accessibility pass
found: `Font.dmSans` was built on `Font.custom(_:size:)`, which renders
at a fixed point size no matter the user's text-size setting — every
screen in the app was silently ignoring it. Fixed via
`Font.custom(_:size:relativeTo:)`, which keeps the exact point size at
the default content size category but scales it along whichever system
text style's curve fits the role (`largeTitle`→`.largeTitle`,
`caption`/`label`→`.footnote`, `labelSmall`→`.caption2` — deliberately
the gentlest curve, so a small label can't outgrow body text at
accessibility sizes — everything else defaults to `.body`). Confirmed
live at the XXL system text size.

Two residual risks, not solved by this pass and worth knowing about:
- Ad hoc `.dmSans(size, weight:)` call sites across screens scale too
  (they inherit the `.body` default), but weren't individually mapped to
  a more precise style the way the seven semantic tokens were.
- Fixed-size containers (`Avatar`'s circle, icon buttons, the day/slot
  grid tiles in `BookAppointmentView`) don't grow with their text — at
  the largest accessibility sizes, content inside them could clip. A
  layout-level fix (dynamic frame sizing, `minimumScaleFactor`), not a
  token one.

## 5. Components

The actual catalog, in `SoleProp/DesignSystem/Components/`:

| Component | Role |
|---|---|
| `PillButton` | Full-width button — `.primary` / `.primaryLight` / `.ghost` / `.ghostLight` |
| `ChoiceChip` | Small toggle chip (filter/selection) |
| `CompactButtonStyle` | Inline filled/outline button pair for tight card contexts |
| `QuickActionButton` | Compact icon+label pill (chat composer's Book/Sale) |
| `OnboardingField` | Labeled text input, brand-tinted fill |
| `SocialAuthButton` | Apple/Google auth row |
| `BadgedIconButton` | Icon button with a notification-count dot |
| `BackIconButtonModifier` | Plain back-chevron nav bar replacement |
| `TrackedLabel` | Small secondary label (plain sentence case) |
| `Avatar` | Filled initials circle |
| `FlowLayout` | Wrapping row layout for chip groups |
| `StaggerAppear` | Shared entrance animation (see Motion) |
| `VoiceOrb`, `AtmosphereBackground`, `OrbBackdropFade`, `ConfettiView`, `GlyphPathShape` | Bespoke/decorative — one-offs by design, not a pattern to repeat |

**What the inventory audit found:** the primitives were solid, but
several real patterns had been quietly reinvented per screen instead of
centralized — the same mistake a component catalog exists to catch.
`Avatar` used to be three independent, slightly-diverged
implementations (Home's `InitialsAvatar` plus inline copies in two
onboarding screens). `FlowLayout` and `QuickActionButton` lived buried in
whichever feature file happened to need them first rather than in the
shared catalog. `CompactButtonStyle` was a `private` one-off inside a
single onboarding screen. All four are now one definition, used
everywhere that pattern appears.

## 6. Motion

Four named roles, replacing what used to be a different duration picked
per call site (0.2, 0.22, 0.25, 0.3, 0.35, 0.5 all existed for
functionally the same four kinds of transition):

```swift
Tokens.Motion.quick             // 0.2s easeOut  — toggles, disclosures
Tokens.Motion.standard          // 0.3s easeOut  — the default: reveals, step transitions
Tokens.Motion.standardSymmetric // 0.3s easeInOut — symmetric cross-fades (forward ≈ back)
Tokens.Motion.relaxed           // 0.5s easeOut  — a bigger surface's full dismiss
```

`Tokens.Motion.Duration` exposes the raw `Double`s for APIs (like
`StaggerAppear`) that need a duration rather than a ready `Animation`.

**Deliberately not covered** — the same way the type scale keeps named
exceptions rather than forcing everything onto the grid: `VoiceOrb`'s
physics-style smoothing, the landing screen's choreographed draw-on
sequence, `AtmosphereBackground`'s slow ambient drift, `ConfettiView`'s
fall physics, and `SearchingView`'s decorative repeating pulse. Each has
its own tuned timing for a specific reason, not "a transition that
happens to need a duration."

`StaggerAppear` (`.staggerAppear(index:)`) is the one shared entrance
convention — a one-shot fade + slight upward settle, staggered by
index, driven by a state flag that flips exactly once rather than a
continuously-updating value (which is what caused the jittery,
stuck-looking motion `VoiceOrb` had to work around separately). Applied
so far to the landing screen (paired with its own hero draw-on), Home,
the chat stream, and onboarding's Welcome screen as a worked example —
the rest of onboarding still has its own ad hoc reveal timing from
before this convention existed, and hasn't been converted over.

---

## Where this still has edges

Honest, not exhaustive:

- **Dynamic Type** works at the token level but hasn't been
  stress-tested against every fixed-size container in the app (see §4).
- **`accentText`'s contrast** was computed by hand, not verified with a
  contrast-checking tool — treat it as "clearly better, likely AA," not
  a certified pass.
- **`RemainingAppointmentsCard`'s status colors** (`#81C398`/`#AFAFAF`
  for booked/open hours) are fixed, not appearance-adaptive — a gap in
  the same category §3 just fixed everywhere else, just not yet caught
  there.
- **Most of onboarding's screen-specific reveal timing** (Found's
  sequential fact rows, Searching's step-through, MigrateExtract's
  row-by-row reveal) predates `StaggerAppear` and hasn't been migrated
  onto it.
