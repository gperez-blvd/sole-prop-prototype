import Foundation

/// One line in the Wallet screen's payout history. Placeholder shape
/// only — see `HomeMockData+Wallet.swift` for seed content.
struct Payout: Identifiable, Hashable {
    let id = UUID()
    var amount: Decimal
    var date: Date
    var isUpcoming: Bool = false
}
