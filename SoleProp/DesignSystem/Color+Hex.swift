import SwiftUI

extension Color {
    /// A `Color` from a hex string — `"#RRGGBB"`, `"RRGGBB"`, or `"#RRGGBBAA"` for
    /// an explicit alpha.
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString.removeAll { $0 == "#" }

        var value: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&value)

        let r, g, b, a: UInt64
        switch hexString.count {
        case 8:
            (r, g, b, a) = ((value >> 24) & 0xFF, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF)
        default:
            (r, g, b, a) = ((value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
