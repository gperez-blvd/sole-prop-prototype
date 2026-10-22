import Foundation

/// Placeholder content for `WalletView` — enough to show the summary
/// card and payout history's shape, not a real ledger.
extension HomeMockData {
    static var nextPayoutAmount: Decimal { 1240 }
    static var nextPayoutDate: Date {
        Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
    }

    static var payoutHistory: [Payout] {
        let now = Date()
        let calendar = Calendar.current
        return [
            Payout(amount: nextPayoutAmount, date: nextPayoutDate, isUpcoming: true),
            Payout(amount: 980, date: calendar.date(byAdding: .day, value: -5, to: now) ?? now),
            Payout(amount: 1_105, date: calendar.date(byAdding: .day, value: -12, to: now) ?? now),
            Payout(amount: 860, date: calendar.date(byAdding: .day, value: -19, to: now) ?? now),
        ]
    }
}
