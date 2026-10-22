import SwiftUI

/// A filled initials circle — the one avatar treatment used everywhere a
/// person is represented without a photo (clients, the business owner,
/// onboarding's brand card). This used to be three separate, nearly
/// identical implementations (Home's `InitialsAvatar`, and inline copies
/// in `FoundView`/`LiveView`) that had quietly drifted — one took a
/// single initial, the other two took up to two — the kind of component
/// sprawl a real catalog is meant to catch. One shared component now,
/// the same way Airbnb has exactly one Avatar component (sized via a
/// token, not reimplemented per screen) rather than one per surface.
struct Avatar: View {
    var name: String
    var size: CGFloat

    private var initials: String {
        name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
            .uppercased()
    }

    var body: some View {
        Circle()
            .fill(Tokens.Color.primaryFill)
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.dmSans(size * 0.36, weight: .semibold))
                    .foregroundStyle(Tokens.Color.onPrimaryFill)
            )
    }
}
