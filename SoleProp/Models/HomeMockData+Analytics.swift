import Foundation

/// Placeholder content for `LogsView`'s three metrics — revenue over
/// time, the service mix, and product usage. Curated numbers rather
/// than derived from `clientTransactions`/`clientDirectory`'s own thin
/// seed data, the same way `payoutHistory` is its own curated set
/// rather than reverse-engineered from appointments: this is about
/// showing the chart's shape believably, not modeling a real ledger.
extension HomeMockData {
    static func revenueSeries(for range: RevenueRange) -> [RevenuePoint] {
        switch range {
        case .week:
            // Day-to-day volatility — a solo provider's week is lumpy,
            // not a smooth trend: a slow Wednesday, a packed Saturday.
            let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            let amounts: [Decimal] = [320, 540, 290, 610, 980, 1240, 410]
            return zip(days, amounts).map { RevenuePoint(label: $0, amount: $1) }
        case .month:
            // A steady ramp — the shape a single good month actually
            // has, distinct from a week's spikiness or a year's seasonal
            // curve, not just a different total.
            let weeks = ["Wk 1", "Wk 2", "Wk 3", "Wk 4"]
            let amounts: [Decimal] = [2800, 3400, 3900, 4600]
            return zip(weeks, amounts).map { RevenuePoint(label: $0, amount: $1) }
        case .year:
            // A rising year with a real summer dip (Jul–Aug) before the
            // fall rebound — through the current month only, since a bar
            // for a month that hasn't happened yet would read as "$0
            // revenue," which isn't true, it's just the future.
            let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            let amounts: [Decimal] = [7200, 6800, 8900, 9600, 11200, 11800, 10400, 9800, 11600, 13400]
            let currentMonth = Calendar.current.component(.month, from: Date())
            return zip(months.prefix(currentMonth), amounts.prefix(currentMonth))
                .map { RevenuePoint(label: $0, amount: $1) }
        }
    }

    /// Same five services, same order, every range — only the counts
    /// change. Keeping the category set fixed is what lets the bars
    /// animate as a clean resize instead of the list reshuffling.
    static func serviceMix(for range: RevenueRange) -> [RankedMetric] {
        switch range {
        case .week:
            return [
                RankedMetric(label: "Neurotoxin", value: 6),
                RankedMetric(label: "HydraFacial", value: 5),
                RankedMetric(label: "Lip filler", value: 3),
                RankedMetric(label: "Chemical peel", value: 2),
                RankedMetric(label: "Laser resurfacing", value: 1),
            ]
        case .month:
            return [
                RankedMetric(label: "Neurotoxin", value: 18),
                RankedMetric(label: "HydraFacial", value: 15),
                RankedMetric(label: "Lip filler", value: 8),
                RankedMetric(label: "Chemical peel", value: 6),
                RankedMetric(label: "Laser resurfacing", value: 3),
            ]
        case .year:
            return [
                RankedMetric(label: "Neurotoxin", value: 182),
                RankedMetric(label: "HydraFacial", value: 150),
                RankedMetric(label: "Lip filler", value: 78),
                RankedMetric(label: "Chemical peel", value: 61),
                RankedMetric(label: "Laser resurfacing", value: 29),
            ]
        }
    }

    /// Same five products, same order, every range — see `serviceMix(for:)`.
    static func productUsage(for range: RevenueRange) -> [RankedMetric] {
        switch range {
        case .week:
            return [
                RankedMetric(label: "Vitamin C serum", value: 9),
                RankedMetric(label: "SPF 50 moisturizer", value: 6),
                RankedMetric(label: "Retinol night cream", value: 4),
                RankedMetric(label: "Gentle cleanser", value: 3),
                RankedMetric(label: "Lip repair balm", value: 2),
            ]
        case .month:
            return [
                RankedMetric(label: "Vitamin C serum", value: 31),
                RankedMetric(label: "SPF 50 moisturizer", value: 22),
                RankedMetric(label: "Retinol night cream", value: 14),
                RankedMetric(label: "Gentle cleanser", value: 11),
                RankedMetric(label: "Lip repair balm", value: 6),
            ]
        case .year:
            return [
                RankedMetric(label: "Vitamin C serum", value: 312),
                RankedMetric(label: "SPF 50 moisturizer", value: 219),
                RankedMetric(label: "Retinol night cream", value: 148),
                RankedMetric(label: "Gentle cleanser", value: 103),
                RankedMetric(label: "Lip repair balm", value: 57),
            ]
        }
    }
}
