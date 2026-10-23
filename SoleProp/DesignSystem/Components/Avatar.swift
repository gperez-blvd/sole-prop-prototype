import SwiftUI

/// The one avatar treatment used everywhere a person is represented —
/// clients, the business owner, onboarding's brand card. This used to be
/// three separate, nearly identical implementations (Home's
/// `InitialsAvatar`, and inline copies in `FoundView`/`LiveView`) that had
/// quietly drifted — one took a single initial, the other two took up to
/// two — the kind of component sprawl a real catalog is meant to catch.
/// One shared component now, the same way Airbnb has exactly one Avatar
/// component (sized via a token, not reimplemented per screen) rather
/// than one per surface.
///
/// `photoURL` is optional on purpose: a real client base is a mix of
/// people who have a profile photo on file and people who don't, the way
/// Venmo's/Zelle's own contact lists look — not a uniform wall of either
/// initials or photos. Pass `PersonPhoto.url(for:)` at call sites that
/// represent a real person (see that type for which ones deterministically
/// get a photo); a failed/slow load always falls back to the initials
/// circle rather than a broken-image glyph.
struct Avatar: View {
    var name: String
    var size: CGFloat
    var photoURL: URL?

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
        Group {
            if let photoURL {
                AsyncImage(url: photoURL) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        initialsFill
                    }
                }
            } else {
                initialsFill
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var initialsFill: some View {
        Circle()
            .fill(Tokens.Color.primaryFill)
            .overlay(
                Text(initials)
                    .font(.dmSans(size * 0.36, weight: .semibold))
                    .foregroundStyle(Tokens.Color.onPrimaryFill)
            )
    }
}
