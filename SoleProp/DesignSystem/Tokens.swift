import SwiftUI

// The app's design system — see CLAUDE.md's "Where truth lives". This
// replaces the earlier onyx/ochre/fog/mono-label system (sourced from the
// original DETAIL onboarding artifact) with the modern system from the
// shared Figma reference: white surfaces, soft elevation instead of
// hairline borders, one plain sentence-case type family (no uppercase
// tracked mono labels), and a friendly bluegreen accent. Token *names* are
// mostly unchanged from the old system on purpose — every screen already
// reads colors/type through these names, so updating the values here is
// what actually re-skins the whole app, rather than hand-editing each
// screen. `BUITokens` is fully dead now (nothing references it) and should
// be deleted outright, not migrated from.
enum Tokens {
    enum Color {
        /// A light/dark pair that resolves per the active appearance.
        /// Backed by a named color in `Colors.xcassets` (light + dark
        /// appearance variants), NOT a `UIColor { traitCollection in }`
        /// closure — that approach looked right in code but, in
        /// practice, didn't reliably repaint when `RootView` applied
        /// `.preferredColorScheme(_:)` (see `AppearanceSetting`): text
        /// kept resolving to its light-mode value, reading as washed-out
        /// gray instead of the intended near-white. Asset-catalog colors
        /// are the one mechanism `.preferredColorScheme` is documented
        /// to drive correctly. `name` is the colorset's name in that
        /// catalog. Used only for the handful of roles below that are
        /// genuinely supposed to flip with appearance (surfaces and
        /// text); structural brand colors (`onyx`, `ochre`, `alert`)
        /// stay fixed in both modes.
        private static func adaptive(_ name: String) -> SwiftUI.Color {
            SwiftUI.Color(name, bundle: .main)
        }

        /// Pure black — card-filled buttons, the orb's deepest shade.
        static let onyx = SwiftUI.Color(hex: "#000000")
        /// Primary text/icon color on light surfaces.
        static let ink = SwiftUI.Color(hex: "#0A0A0A")
        /// Secondary text — section labels, metadata.
        static let ink2 = SwiftUI.Color(hex: "#6B6B6B")
        /// Tertiary text/icons — chevrons, disabled state, placeholders.
        static let ink3 = SwiftUI.Color(hex: "#9B9B9B")
        /// The one accent color — friendly bluegreen/teal, used for the
        /// orb's own body, glows, fills and borders. Replaces the old
        /// system's gold accent outright. Fixed in both appearances on
        /// purpose, the same way Airbnb's single accent (Rausch) stays
        /// one exact hue everywhere it's used *decoratively* — the
        /// orb, a tinted fill, a selected border.
        ///
        /// Do NOT use this for text or icon *foreground* color — at
        /// ~2.5:1 against a white surface it fails even the lenient
        /// 3:1 non-text contrast minimum, let alone 4.5:1 for text (it
        /// only clears that bar against our dark surface, ~7:1). Use
        /// `accentText` for anything conveying meaning through its own
        /// color — a checkmark, a "Connected" label, a highlighted
        /// value — and reserve this raw hue for fills/borders/glows.
        static let ochre = SwiftUI.Color(hex: "#14B8A6")
        /// The accent, adjusted per-appearance so text/icons actually
        /// meet contrast — darkened on light surfaces, identical to
        /// `ochre` on dark ones (where the raw hue already passes).
        /// This is the one Airbnb pulls off by *never* putting Rausch
        /// directly on small text either — same pattern, applied to our
        /// own palette instead of adopting theirs.
        static let accentText = adaptive("AccentText")
        /// A quiet wash of the accent — selected-state fills, tinted
        /// input backgrounds. One fixed opacity, not a different
        /// magic number picked per screen.
        static let accentTint = SwiftUI.Color(hex: "#14B8A6").opacity(0.12)
        /// The accent as a visible but secondary outline — unselected
        /// rows, inactive borders that still want to read as "on brand."
        static let accentBorder = SwiftUI.Color(hex: "#14B8A6").opacity(0.5)
        /// The accent as an emphasized outline — a selected/active
        /// state's border, one step stronger than `accentBorder`.
        static let accentBorderStrong = SwiftUI.Color(hex: "#14B8A6").opacity(0.7)
        /// Page/card surface — pure white, not an off-white.
        static let fog = SwiftUI.Color(hex: "#FFFFFF")
        static let paper = fog
        static let white = SwiftUI.Color(hex: "#FFFFFF")
        /// Notification/alert red — matches the reference's badge color.
        static let alert = SwiftUI.Color(hex: "#E53E3E")

        /// Page background. Dark is a neutral charcoal — deliberately NOT
        /// tinted green/teal the way the auth screen's atmosphere is.
        /// Earlier passes leaned the whole dark palette toward that same
        /// teal, which read as overwhelmingly green once it covered
        /// every surface at once rather than sitting behind one hero
        /// gradient; the accent color alone (`ochre`) now carries the
        /// brand color in dark mode, and the neutral base gives it
        /// something to contrast against.
        static let background = adaptive("AppBackground")
        /// Card/surface fill — one step lighter than `background` in
        /// dark mode so elevation still reads without a hairline border.
        static let surface = adaptive("AppSurface")
        /// Subtle fill for pills/segmented backgrounds — neutral, not warm.
        static let silt = adaptive("AppSilt")
        /// Title/body text. Pure white in dark mode, not a soft gray —
        /// a gray that reads fine on a white background goes washed-out
        /// and low-contrast on a dark one, so this isn't the same ramp
        /// shifted down, it's a different endpoint on purpose.
        static let textPrimary = adaptive("TextPrimary")
        static let textSecondary = adaptive("TextSecondary")
        /// A solid-fill button's own fill/label pair — what `PillButton`'s
        /// `.primary` style actually paints with. Deliberately NOT just
        /// `ink`/`fog`: a fixed near-black fill on a dark-mode background
        /// that's *also* near-black (see `background` above) nearly
        /// vanishes, the same bug fixed one-off on the auth landing
        /// screen with `.primaryLight`. This makes every ordinary
        /// `.primary` button invert automatically instead.
        static let primaryFill = adaptive("PrimaryFill")
        static let onPrimaryFill = adaptive("OnPrimaryFill")
        static let textTertiary = adaptive("TextTertiary")
        /// Kept faint/available for the few places still using a border
        /// instead of elevation — new cards should prefer `Tokens.Shadow`.
        static let hairline = adaptive("AppHairline")
    }

    /// Named motion, the same discipline as `Color`/`Typography` above —
    /// before this, nearly every `withAnimation`/`.animation(value:)`
    /// call in the app picked its own duration (0.2, 0.22, 0.25, 0.3,
    /// 0.35, 0.5 all appeared for what was functionally the same kind
    /// of transition). Four named roles instead, covering ordinary UI
    /// state changes.
    ///
    /// This deliberately does NOT cover the handful of bespoke,
    /// carefully-tuned animations elsewhere (`VoiceOrb`'s physics-style
    /// smoothing, the landing screen's choreographed draw-on sequence,
    /// `AtmosphereBackground`'s slow ambient drift, `ConfettiView`'s
    /// fall physics) — those aren't "a transition with a duration," they
    /// have their own documented timing for a specific reason, the same
    /// way the type scale still has named one-off exceptions (the 72pt
    /// wordmark, the 10pt badge).
    enum Motion {
        enum Duration {
            /// A toggle, a disclosure expanding/collapsing, anything
            /// that should feel immediate rather than "animated."
            static let quick: Double = 0.2
            /// The default for most reveal/dismiss/step transitions —
            /// a screen stepping to the next one, a value appearing.
            static let standard: Double = 0.3
            /// `StaggerAppear`'s own settle duration — surfaced here so
            /// it's documented alongside the rest of the scale, not just
            /// a default parameter value living only in that file.
            static let moderate: Double = 0.42
            /// A larger surface's own full dismiss/entrance — the Daily
            /// Brief fading out, not a small in-place state change.
            static let relaxed: Double = 0.5
        }

        /// Toggles and disclosures.
        static let quick = Animation.easeOut(duration: Duration.quick)
        /// The default — reach for this first.
        static let standard = Animation.easeOut(duration: Duration.standard)
        /// Symmetric cross-fades, where the in-transition and the out
        /// -transition should feel the same either way (a step forward
        /// and a step back, an orb dimming the screen and un-dimming
        /// it) — `.easeInOut` rather than `.easeOut`.
        static let standardSymmetric = Animation.easeInOut(duration: Duration.standard)
        /// A bigger surface's own dismiss/entrance.
        static let relaxed = Animation.easeOut(duration: Duration.relaxed)
    }

    /// Soft drop shadows, replacing hairline-bordered cards — apply with
    /// `.shadow(color:radius:x:y:)` using one of these.
    enum Shadow {
        static let low = (color: SwiftUI.Color.black.opacity(0.10), radius: 18.0, y: 4.0)
        static let medium = (color: SwiftUI.Color.black.opacity(0.17), radius: 18.0, y: 8.0)
        static let high = (color: SwiftUI.Color.black.opacity(0.22), radius: 24.0, y: 16.0)
    }

    /// An 8px base grid, same spirit as Airbnb's most consistently
    /// reported spacing scale — `xxl`/`xxxl` added for screen-level gaps
    /// that previously had no token and fell back to a magic number.
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }

    /// Tightened toward Airbnb's own corner language — their most
    /// consistently reported value, across every source, is an 8px
    /// button radius: crisp, not the soft/bubbly 16px this used to be.
    /// Every other step below is scaled down from the old values in the
    /// same proportion, not picked independently.
    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 10
        /// Cards sit a step above buttons, same relative gap as before
        /// (card used to be 2pt over button's 14; now 6pt over 8).
        static let card: CGFloat = 14
        static let lg: CGFloat = 20
        static let pill: CGFloat = 999
        /// Every tappable button's corner radius — crisp, Airbnb-style,
        /// rather than the softer/rounder shape this used to be. One
        /// value, used everywhere a button appears, so they all read as
        /// the same control.
        static let button: CGFloat = 8
    }

    /// DM Sans throughout — see `Font+DMSans.swift`. Hierarchy comes from
    /// *size*, deliberately not weight: `.semibold` (used once, for
    /// `largeTitle` only) is the heaviest weight anywhere in this list.
    /// Everything else sits on `.regular`/`.medium` so no screen reaches
    /// for bold to stand out.
    ///
    /// A discrete modular scale — `12 · 14 · 16 · 18 · 22 · 28 · 32` —
    /// in the same spirit as Airbnb's own type scale: a tight ~1.1–1.2×
    /// step through the body-text range, then a wider jump for display
    /// sizes, rather than the continuous per-screen numbers (11.5, 13,
    /// 13.5, 17, 20, 24, 30...) this had drifted into. Every text size
    /// anywhere in the app should land on one of these seven numbers —
    /// if a screen needs something in between, that's a sign it should
    /// reuse an existing step, not invent a new one.
    ///
    /// Hierarchy comes from *size and step*, deliberately not weight:
    /// `.semibold` (used only for `largeTitle`) is the heaviest weight
    /// anywhere in this list. Everything else sits on `.regular`/
    /// `.medium`, including two different weights sharing the *same*
    /// step (`body`/`bodyRegular` both sit on 16) — that's a legitimate
    /// use of one step, not a missing size.
    enum Typography {
        /// Step 7 (32). Hero screen titles only — "Welcome to Cue,"
        /// Home's "Good morning." One per screen, at most.
        static let largeTitle = Font.dmSans(32, weight: .semibold, relativeTo: .largeTitle)
        /// Step 5 (22). Section/screen titles below hero weight —
        /// "We found you, Jazz.", a sheet's own title.
        static let title = Font.dmSans(22, weight: .medium, relativeTo: .title2)
        /// Step 4 (18). A standalone emphasized value or small headline
        /// inside a card — a price, a count, a card's own title line.
        static let value = Font.dmSans(18, weight: .medium, relativeTo: .headline)
        /// Step 3 (16). The primary reading size — this is "the" body
        /// text weight; `bodyRegular` is the same step, lighter weight,
        /// for longer/secondary paragraphs rather than emphasized lines.
        static let body = Font.dmSans(16, weight: .medium)
        static let bodyRegular = Font.dmSans(16, weight: .regular)
        /// Step 3 (16). Button labels share body's own step — a button
        /// is primary-reading-weight content, not a smaller control.
        static let button = Font.dmSans(16, weight: .medium)
        /// Step 2 (14). Captions, metadata, secondary field labels —
        /// same plain sentence-case treatment as everything else, no
        /// uppercase/tracking/monospacing (that was the old IBM-Plex
        /// -Mono tracked-caps system this replaced).
        static let caption = Font.dmSans(14, weight: .regular, relativeTo: .footnote)
        static let label = Font.dmSans(14, weight: .regular, relativeTo: .footnote)
        /// Step 1 (12). The floor — the smallest size any real content
        /// (not a bare icon glyph or a notification-count badge) should
        /// ever go. Tags, inline badges, the tightest metadata. Scales
        /// on `.caption2`'s own curve — the gentlest of the bunch — so
        /// it doesn't balloon past body text at accessibility sizes.
        static let labelSmall = Font.dmSans(12, weight: .regular, relativeTo: .caption2)
    }
}

extension View {
    /// The one card treatment used app-wide: white surface, soft shadow,
    /// no border — applies `Tokens.Radius.card`/`Tokens.Shadow.medium`
    /// consistently instead of each screen hand-rolling its own
    /// background/clip/border chain (which is how hairline borders crept
    /// back in after the move away from them).
    func cardStyle(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(Tokens.Color.surface, in: RoundedRectangle(cornerRadius: Tokens.Radius.card))
            .shadow(color: Tokens.Shadow.medium.color, radius: Tokens.Shadow.medium.radius, x: 0, y: Tokens.Shadow.medium.y)
    }
}
