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
        /// used `ochre`. Replaces that gold accent outright.
        static let ochre = SwiftUI.Color(hex: "#14B8A6")
        /// Page/card surface — pure white, not an off-white.
        static let fog = SwiftUI.Color(hex: "#FFFFFF")
        /// Subtle fill for pills/segmented backgrounds — neutral, not warm.
        static let silt = SwiftUI.Color(hex: "#F0F0F0")
        static let paper = fog
        static let white = SwiftUI.Color(hex: "#FFFFFF")
        /// Notification/alert red — matches the reference's badge color.
        static let alert = SwiftUI.Color(hex: "#E53E3E")

        static let background = fog
        static let textPrimary = ink
        static let textSecondary = ink2
        static let textTertiary = ink3
        /// Kept faint/available for the few places still using a border
        /// instead of elevation — new cards should prefer `Tokens.Shadow`.
        static let hairline = SwiftUI.Color.black.opacity(0.08)
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
        static let card: CGFloat = 24
        static let lg: CGFloat = 24
        static let pill: CGFloat = 999
    }

    enum Typography {
        static let largeTitle = Font.system(size: 26, weight: .regular)
        static let title = Font.system(size: 22, weight: .medium)
        static let body = Font.system(size: 15, weight: .medium)
        static let bodyRegular = Font.system(size: 13.5, weight: .regular)
        static let value = Font.system(size: 16, weight: .medium)
        static let button = Font.system(size: 14.5, weight: .semibold)
        static let caption = Font.system(size: 13, weight: .regular)

        // Plain sentence-case labels — same family as everything else, no
        // uppercase/tracking/monospacing. Replaces the old IBM-Plex-Mono
        // -style tracked caps used for section headers throughout.
        static let label = Font.system(size: 13, weight: .regular)
        static let labelSmall = Font.system(size: 12, weight: .regular)
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
            .background(Tokens.Color.white, in: RoundedRectangle(cornerRadius: Tokens.Radius.card))
            .shadow(color: Tokens.Shadow.medium.color, radius: Tokens.Shadow.medium.radius, x: 0, y: Tokens.Shadow.medium.y)
    }
}
