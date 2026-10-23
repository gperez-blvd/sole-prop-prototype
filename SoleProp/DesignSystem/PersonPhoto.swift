import Foundation

/// Deterministically decides whether a given person has a profile photo on
/// file, and if so, which one — a realistic mix (some people have set a
/// photo, most haven't), not a uniform wall of initials or a uniform wall
/// of photos. Deterministic on the person's name, not random per launch,
/// so the same client always shows the same face (or the same initials)
/// across screens and across app restarts.
///
/// Photos come from `i.pravatar.cc`, a stable placeholder-photo service
/// that serves the same numbered photo for the same `img` index on every
/// request — no API key, no bundled binaries, no risk of hotlinking a real
/// private individual's photo. If the network is unavailable, `Avatar`
/// falls back to the initials circle, so this never blocks the demo.
enum PersonPhoto {
    /// Roughly 2 in 5 people get a photo — close to what a real client
    /// list looks like (plenty of regulars never bother setting one).
    private static let photoOdds = 5

    static func url(for name: String) -> URL? {
        let bucket = abs(name.hashValue) % photoOdds
        guard bucket < 2 else { return nil }
        let photoIndex = (abs(name.hashValue) % 70) + 1
        return URL(string: "https://i.pravatar.cc/150?img=\(photoIndex)")
    }
}
