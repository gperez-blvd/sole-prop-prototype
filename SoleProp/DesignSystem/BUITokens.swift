import SwiftUI

/// Legacy tokens pulled from the actual Figma (Boulevard's BUI design
/// system) — white background, black text, DM Sans, rounded shadowed
/// cards. `Tokens` (the onyx/ochre onboarding artifact's style) is now the
/// app's design system; screens still on `BUITokens` haven't been migrated
/// yet. Don't build new screens against this. Using system fonts as a
/// stand-in for DM Sans until it's bundled.
enum BUITokens {
    enum Color {
        static let background = SwiftUI.Color.white
        static let textPrimary = SwiftUI.Color.black
        static let textStrong = SwiftUI.Color(hex: "#545454") // text-and-icon/strong
        static let disabled = SwiftUI.Color(hex: "#AFAFAF") // background/contrast/disabled
        static let bluegreen = SwiftUI.Color(hex: "#81C398")
        static let contrastPrimary = SwiftUI.Color.black // background/contrast/primary
    }

    enum Shadow {
        static let medium = SwiftUI.Color.black.opacity(0.17)
        static let mediumRadius: CGFloat = 36
        static let mediumY: CGFloat = 8
    }

    enum Radius {
        static let card: CGFloat = 24
    }

    enum Typography {
        static let greeting = Font.system(size: 24, weight: .regular)
        static let sectionLabel = Font.system(size: 14, weight: .regular)
        static let cardTitle = Font.system(size: 16, weight: .regular)
        static let headerTitle = Font.system(size: 14, weight: .medium)
        static let tooltip = Font.system(size: 14, weight: .regular)
    }
}
