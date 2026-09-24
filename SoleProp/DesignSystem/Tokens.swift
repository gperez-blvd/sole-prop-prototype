import SwiftUI

// Placeholder values — replace with real tokens pulled from Figma/BUI once references land.
enum Tokens {
    enum Color {
        static let primary = SwiftUI.Color.blue
        static let background = SwiftUI.Color(.systemBackground)
        static let textPrimary = SwiftUI.Color(.label)
        static let textSecondary = SwiftUI.Color(.secondaryLabel)
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
        static let lg: CGFloat = 20
    }

    enum Typography {
        static let title = Font.system(.title2, weight: .semibold)
        static let body = Font.system(.body)
        static let caption = Font.system(.caption)
    }
}
