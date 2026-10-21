import SwiftUI
import CoreText

/// The actual glyph outlines of `text` set in `font` — a real vector
/// path, the same way an SVG `<text>` converted to `<path>` would be —
/// normalized to fill this shape's own rect. Pairs with `.trim(from:to:)`
/// to "draw" the letterforms on, the same trick an animated SVG
/// stroke-dasharray reveal uses, except traced along DM Sans's own
/// outlines instead of a hand-built path.
///
/// Multiple letters become multiple subpaths (and "e" has an inner
/// counter, a second subpath of its own) all concatenated into one
/// `CGPath` — `.trim` parameterizes across the whole thing in order, so
/// the reveal still reads as one continuous left-to-right draw rather
/// than each letter popping in independently.
struct GlyphPathShape: Shape {
    var text: String
    var font: UIFont

    func path(in rect: CGRect) -> Path {
        let attributed = NSAttributedString(string: text, attributes: [.font: font])
        let line = CTLineCreateWithAttributedString(attributed)
        guard let runs = CTLineGetGlyphRuns(line) as? [CTRun] else { return Path() }

        let combined = CGMutablePath()
        for run in runs {
            // Glyph indices are only meaningful relative to the exact
            // font instance that shaped this run — reconstructing "an
            // equivalent" font from the run's attributes (what this did
            // before) can resolve to a slightly different font, where
            // those same indices point at unrelated glyphs. That's
            // exactly the "shows some symbols" bug: pulling the real
            // `CTFont` straight out of the run's own attributes is the
            // only way the glyph IDs are guaranteed to mean anything.
            let attributes = CTRunGetAttributes(run) as NSDictionary
            guard let runFont = attributes[kCTFontAttributeName as String] else { continue }
            let ctFont = runFont as! CTFont

            let count = CTRunGetGlyphCount(run)
            guard count > 0 else { continue }
            var glyphs = [CGGlyph](repeating: 0, count: count)
            var positions = [CGPoint](repeating: .zero, count: count)
            CTRunGetGlyphs(run, CFRange(location: 0, length: count), &glyphs)
            CTRunGetPositions(run, CFRange(location: 0, length: count), &positions)
            for i in 0..<count {
                guard let glyphPath = CTFontCreatePathForGlyph(ctFont, glyphs[i], nil) else { continue }
                var transform = CGAffineTransform(translationX: positions[i].x, y: positions[i].y)
                if let transformed = glyphPath.copy(using: &transform) {
                    combined.addPath(transformed)
                }
            }
        }

        let bounds = combined.boundingBoxOfPath
        guard bounds.width > 0, bounds.height > 0 else { return Path() }

        // CoreText's glyph space is Y-up with the origin at the line's
        // baseline — flip it into SwiftUI/UIKit's Y-down space and scale
        // + center it into whatever rect this shape is actually given,
        // rather than assuming a fixed font size matches the frame.
        let scale = min(rect.width / bounds.width, rect.height / bounds.height)
        var transform = CGAffineTransform.identity
            .translatedBy(x: rect.midX, y: rect.midY)
            .scaledBy(x: scale, y: -scale)
            .translatedBy(x: -bounds.midX, y: -bounds.midY)

        guard let final = combined.copy(using: &transform) else { return Path() }
        return Path(final)
    }
}
