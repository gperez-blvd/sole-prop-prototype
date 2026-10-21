import SwiftUI

/// DM Sans — the app's one typeface, replacing the system font everywhere.
/// Shipped as a single variable font (`DMSans.ttf`, registered via
/// `UIAppFonts` in project.yml), so every weight below is the same file
/// with SwiftUI's `.fontWeight()` driving its `wght` axis rather than
/// separate font files per weight.
///
/// Deliberately restrained: the heaviest weight used anywhere in
/// `Tokens.Typography` is `.semibold`, reserved for the few titles that
/// need to lead a screen. Everything else sits on `.regular`/`.medium` so
/// the type hierarchy comes from *size*, not from reaching for bold —
/// bold is available here but intentionally unused by the design system.
extension Font {
    static func dmSans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("DM Sans", size: size).weight(weight)
    }
}
