import Foundation

/// Placeholder content for the Transactions tab of `WalletView` — enough
/// to show a believable, varied activity feed grouped by payment type,
/// not a real ledger.
extension HomeMockData {
    static var clientTransactions: [Transaction] {
        let now = Date()
        let calendar = Calendar.current
        func daysAgo(_ days: Int) -> Date { calendar.date(byAdding: .day, value: -days, to: now) ?? now }

        return [
            Transaction(clientName: "Tasha W.", service: "HydraFacial", amount: 185, date: daysAgo(0), paymentType: .creditCard),
            Transaction(clientName: "Dani R.", service: "Neurotoxin", amount: 420, date: daysAgo(0), paymentType: .debitCard),
            Transaction(clientName: "Priya S.", service: "Lip filler", amount: 650, date: daysAgo(1), paymentType: .creditCard),
            Transaction(clientName: "Maya K.", service: "Neurotoxin", amount: 380, date: daysAgo(1), paymentType: .giftCard),
            Transaction(clientName: "Corey L.", service: "HydraFacial", amount: 165, date: daysAgo(2), paymentType: .cash),
            Transaction(clientName: "Lena K.", service: "HydraFacial", amount: 165, date: daysAgo(3), paymentType: .creditCard),
            Transaction(clientName: "Renee C.", service: "Lip filler", amount: 625, date: daysAgo(4), paymentType: .debitCard),
            Transaction(clientName: "Ava J.", service: "Chemical peel", amount: 210, date: daysAgo(5), paymentType: .cash),
            Transaction(clientName: "Sofia D.", service: "Neurotoxin", amount: 400, date: daysAgo(6), paymentType: .giftCard),
            Transaction(clientName: "Jess T.", service: "Chemical peel", amount: 225, date: daysAgo(7), paymentType: .creditCard),
        ]
    }
}
