import Foundation

/// How a client paid — the grouping key for the Transactions tab, the way
/// Venmo/Zelle group recent activity by its own kind of payment method.
enum PaymentType: String, CaseIterable, Hashable {
    case creditCard = "Credit card"
    case debitCard = "Debit card"
    case giftCard = "Gift card"
    case cash = "Cash"

    var icon: String {
        switch self {
        case .creditCard: "creditcard"
        case .debitCard: "creditcard.fill"
        case .giftCard: "gift"
        case .cash: "banknote"
        }
    }
}

/// One client payment — distinct from `Payout` (what lands in the bank):
/// this is money coming in from a client, `Payout` is this app's own
/// money moving out to Jazz. Placeholder shape only; see
/// `HomeMockData+Transactions.swift` for seed content.
struct Transaction: Identifiable, Hashable {
    let id = UUID()
    var clientName: String
    var service: String
    var amount: Decimal
    var date: Date
    var paymentType: PaymentType
}
