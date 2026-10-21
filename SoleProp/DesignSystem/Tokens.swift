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
        /// orb, badges, highlighted values and anywhere the old system
        /// used `ochre`. Replaces that gold accent outright. Fixed in
        /// both appearances — it's the one color meant to read the same
        /// regardless of light/dark.
        static let ochre = SwiftUI.Color(hex: "#14B8A6")
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

    /// Soft drop shadows, replacing hairline-bordered cards — apply with
    /// `.shadow(color:radius:x:y:)` using one of these.
    enum Shadow {
        static let low = (color: SwiftUI.Color.black.opacity(0.10), radius: 18.0, y: 4.0)
        static let medium = (color: SwiftUI.Color.black.opacity(0.17), radius: 18.0, y: 8.0)
        static let high = (color: SwiftUI.Color.black.opacity(0.22), radius: 24.0, y: 16.0)
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 14
        /// Every card/container's corner radius — same value as buttons,
        /// so cards and the buttons inside them read as one consistent
        /// shape language rather than two different roundnesses.
        static let card: CGFloat = 16
        static let lg: CGFloat = 24
        static let pill: CGFloat = 999
        /// Every tappable button's corner radius — friendly, not a hard
        /// square, but deliberately short of the full stadium/capsule
        /// shape buttons used before. One value, used everywhere a button
        /// appears, so they all read as the same control.
        static let button: CGFloat = 16
    }

    /// DM Sans throughout — see `Font+DMSans.swift`. Hierarchy comes from
    /// *size*, deliberately not weight: `.semibold` (used once, for
    /// `largeTitle` only) is the heaviest weight anywhere in this list.
    /// Everything else sits on `.regular`/`.medium` so no screen reaches
    /// for bold to stand out.
    enum Typography {
        static let largeTitle = Font.dmSans(28, weight: .semibold)
        static let title = Font.dmSans(20, weight: .medium)
        static let body = Font.dmSans(15, weight: .medium)
        static let bodyRegular = Font.dmSans(13.5, weight: .regular)
        static let value = Font.dmSans(16, weight: .medium)
        static let button = Font.dmSans(15, weight: .medium)
        static let caption = Font.dmSans(13, weight: .regular)

        // Plain sentence-case labels — same family as everything else, no
        // uppercase/tracking/monospacing. Replaces the old IBM-Plex-Mono
        // -style tracked caps used for section headers throughout.
        static let label = Font.dmSans(13, weight: .regular)
        static let labelSmall = Font.dmSans(12, weight: .regular)
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
