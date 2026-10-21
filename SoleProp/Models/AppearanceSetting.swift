import SwiftUI

/// The app's one real display setting — light, dark, or follow the
/// system. Stored as a plain string in `@AppStorage` so it survives
/// relaunch; `colorScheme` is what `RootView` feeds to
/// `.preferredColorScheme(_:)`, with `nil` meaning "don't override,
/// follow the system."
enum AppearanceSetting: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: "Auto"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
