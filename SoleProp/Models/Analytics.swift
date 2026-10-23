import Foundation

/// How far back `LogsView`'s revenue chart can be scoped — the same
/// Week/Month/Year shape most light business-reporting views settle on
/// (Venmo/Cash App statements, most POS apps' free tier). There's
/// deliberately no "All time"/multi-year option: a year is already the
/// ceiling `HomeMockData.revenueSeries(for:)` will ever return, so the
/// toggle can't imply more history exists than actually does.
enum RevenueRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

/// One bar in the revenue chart — a day, a week, or a month, depending
/// on `RevenueRange`.
///
/// **A stable `id` matters here, not just as hygiene.** `id` used to be
/// `let id = UUID()` — a fresh identity every single time
/// `HomeMockData.revenueSeries(for:)` ran, which is every time `LogsView`
/// re-renders, not just when the range actually changes. SwiftUI's
/// `ForEach`/animation diffing treats a changed `id` as "a different
/// item," never "the same item with a new value" — so every bar looked
/// like it was being torn down and a brand new one inserted in its place,
/// which is exactly why the chart appeared to "just appear and grow"
/// instead of smoothly resizing. Deriving `id` from `label` instead makes
/// a bar's identity survive across re-renders (and, for the ranked lists
/// below, across a value actually changing), which is what lets SwiftUI
/// animate the existing bar's height/width rather than swap it out.
struct RevenuePoint: Identifiable, Hashable {
    var label: String
    var amount: Decimal

    var id: String { label }
}

/// One row in a ranked breakdown (services booked, product usage) —
/// deliberately just a label and a count, not a richer record. The
/// point of this screen is "what matters most, at a glance," not a
/// full reporting suite. See `RevenuePoint`'s note on why `id` is
/// derived from `label` rather than a freshly-generated `UUID()`.
struct RankedMetric: Identifiable, Hashable {
    var label: String
    var value: Int

    var id: String { label }
}
