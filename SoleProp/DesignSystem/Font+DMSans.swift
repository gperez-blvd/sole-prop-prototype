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
///
/// Scales with the user's own text-size setting (Dynamic Type) via
/// `relativeTo:` — every call site used to render at a fixed point size
/// regardless of that setting, which is the one real accessibility gap
/// in this whole system. `relativeTo` doesn't change the base size (that
/// stays exactly `size` at the default content size category); it picks
/// *how aggressively* this text grows or shrinks as the category moves,
/// by borrowing that curve from one of UIKit's own text styles. Pass the
/// style whose scaling behavior should apply — `.caption2` for a small
/// label that shouldn't balloon past body text at accessibility sizes,
/// `.largeTitle` for a hero title that should lead the scaling. Defaults
/// to `.body` for any call site that hasn't been given a more specific
/// one.
extension Font {
    static func dmSans(_ size: CGFloat, weight: Font.Weight = .regular, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom("DM Sans", size: size, relativeTo: style).weight(weight)
    }
}
