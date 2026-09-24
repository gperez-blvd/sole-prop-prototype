import SwiftUI

// Palette and type pulled from the "Boulevard Secret Service" (DETAIL) prototype
// artifact — onyx/ochre/fog/silt palette, Instrument Sans body + IBM Plex Mono
// for uppercase/tracked labels. Using system fonts as a stand-in for those two
// (not bundled yet) — swap in the real font files once we're locking visuals.
enum Tokens {
    enum Color {
        static let onyx = SwiftUI.Color(hex: "#000000")
        static let ink = SwiftUI.Color(hex: "#0A0A0A")
        static let ink2 = SwiftUI.Color(hex: "#5F5B53")
        static let ink3 = SwiftUI.Color(hex: "#8A867C")
        static let ochre = SwiftUI.Color(hex: "#C8AB7C")
        static let fog = SwiftUI.Color(hex: "#F5F4F1")
        static let silt = SwiftUI.Color(hex: "#E4E4DE")
        static let paper = SwiftUI.Color(hex: "#F5F4F1")
        static let white = SwiftUI.Color(hex: "#FFFFFF")

        static let background = fog
        static let textPrimary = ink
        static let textSecondary = ink2
        static let textTertiary = ink3
        static let hairline = SwiftUI.Color.black.opacity(0.13)
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 12
        static let card: CGFloat = 14
        static let lg: CGFloat = 20
        static let pill: CGFloat = 999
    }

    enum Typography {
        static let largeTitle = Font.system(size: 26, weight: .semibold)
        static let title = Font.system(size: 22, weight: .semibold)
        static let body = Font.system(size: 15, weight: .medium)
        static let bodyRegular = Font.system(size: 13.5, weight: .regular)
        static let value = Font.system(size: 16, weight: .medium)
        static let button = Font.system(size: 14.5, weight: .semibold)
        static let caption = Font.system(size: 13, weight: .regular)

        // "IBM Plex Mono"-style uppercase tracked labels used throughout the
        // reference (section headers, field labels, source tags).
        static let label = Font.system(size: 10, weight: .medium, design: .monospaced)
        static let labelSmall = Font.system(size: 9.5, weight: .medium, design: .monospaced)
    }
}
