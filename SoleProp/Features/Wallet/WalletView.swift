import SwiftUI

/// Placeholder architecture for Wallet — styled and worded after Venmo/
/// Zelle's own balance-first pattern: a big balance up top, two prominent
/// actions right under it, then an activity feed below. A segmented
/// control switches between this app's own money (the Wallet tab —
/// balance, actions, payout history) and money coming in from clients
/// (the Transactions tab — grouped by how they paid, the way a Venmo/
/// Zelle activity feed groups by payment method). No functionality:
/// every action surfaces the same "not designed yet" placeholder the rest
/// of the app uses for unbuilt detail.
struct WalletView: View {
    @Environment(Router.self) private var router
    @State private var placeholderMessage: String?
    @State private var mode: Mode = .wallet

    private enum Mode: String, CaseIterable {
        case wallet = "Wallet"
        case transactions = "Transactions"
    }

    private var payouts: [Payout] { HomeMockData.payoutHistory }
    private var transactions: [Transaction] { HomeMockData.clientTransactions }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
                SegmentedToggle(options: Mode.allCases, selection: $mode)

                switch mode {
                case .wallet: walletTab
                case .transactions: transactionsTab
                }
            }
            .padding(.horizontal, Tokens.Spacing.lg)
            .padding(.top, Tokens.Spacing.lg)
            .padding(.bottom, Tokens.Spacing.xl)
            .animation(Tokens.Motion.quick, value: mode)
        }
        .background(Tokens.Color.background)
        .navigationTitle("Wallet")
        .navigationBarTitleDisplayMode(.inline)
        .backIconButton { router.pop() }
        .alert("Not designed yet", isPresented: .constant(placeholderMessage != nil), presenting: placeholderMessage) { _ in
            Button("OK") { placeholderMessage = nil }
        } message: { message in
            Text(message)
        }
    }

    // MARK: - Wallet tab

    private var walletTab: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            balanceCard

            VStack(alignment: .leading, spacing: 0) {
                Text("Payouts")
                    .font(Tokens.Typography.label)
                    .foregroundStyle(Tokens.Color.textTertiary)
                    .padding(.bottom, 8)

                ForEach(payouts) { payout in
                    payoutRow(payout)
                }
            }
        }
    }

    /// Balance-first, the way Venmo/Zelle open their own wallet screen:
    /// a label, one large number, then the two things she'd actually do
    /// with it right underneath — not a card she has to tap into first.
    private var balanceCard: some View {
        VStack(spacing: 18) {
            VStack(spacing: 4) {
                Text("Available balance")
                    .font(Tokens.Typography.label)
                    .foregroundStyle(Tokens.Color.textTertiary)
                Text(currency(HomeMockData.nextPayoutAmount))
                    .font(.dmSans(40, weight: .semibold))
                    .foregroundStyle(Tokens.Color.textPrimary)
                Text("Lands \(HomeMockData.nextPayoutDate.formatted(.dateTime.weekday(.wide)))")
                    .font(Tokens.Typography.caption)
                    .foregroundStyle(Tokens.Color.textSecondary)
            }

            HStack(spacing: 10) {
                balanceAction(title: "Add funds", icon: "plus", filled: true)
                balanceAction(title: "Transfer", icon: "arrow.left.arrow.right", filled: false)
            }
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    private func balanceAction(title: String, icon: String, filled: Bool) -> some View {
        Button {
            placeholderMessage = "\(title) — not designed yet."
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(title)
                    .font(Tokens.Typography.button)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(filled ? Tokens.Color.onPrimaryFill : Tokens.Color.textPrimary)
            .background(
                RoundedRectangle(cornerRadius: Tokens.Radius.button)
                    .fill(filled ? Tokens.Color.primaryFill : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.button)
                    .strokeBorder(filled ? .clear : Tokens.Color.textPrimary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func payoutRow(_ payout: Payout) -> some View {
        Button {
            placeholderMessage = "A payout's own detail — not designed yet."
        } label: {
            HStack(spacing: 12) {
                Image(systemName: payout.isUpcoming ? "clock" : "checkmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Tokens.Color.accentSoft)
                    .frame(width: 30, height: 30)
                    .background(Tokens.Color.accentSoftTint, in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(currency(payout.amount))
                        .font(Tokens.Typography.body)
                        .foregroundStyle(Tokens.Color.textPrimary)
                    Text(payout.isUpcoming ? "On its way" : payout.date.formatted(date: .abbreviated, time: .omitted))
                        .font(Tokens.Typography.caption)
                        .foregroundStyle(Tokens.Color.textSecondary)
                }

                Spacer()
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .overlay(alignment: .bottom) {
                Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Transactions tab

    /// Grouped by how the client paid — a Venmo/Zelle activity feed reads
    /// as one flat list, but "sort by payment type" was asked for
    /// explicitly, so each type gets its own section rather than an inline
    /// badge per row.
    private var groupedTransactions: [(type: PaymentType, items: [Transaction])] {
        let byType = Dictionary(grouping: transactions, by: \.paymentType)
        return PaymentType.allCases.compactMap { type in
            guard let items = byType[type], !items.isEmpty else { return nil }
            return (type, items.sorted { $0.date > $1.date })
        }
    }

    private var transactionsTab: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            ForEach(groupedTransactions, id: \.type) { group in
                VStack(alignment: .leading, spacing: 0) {
                    Text(group.type.rawValue)
                        .font(Tokens.Typography.label)
                        .foregroundStyle(Tokens.Color.textTertiary)
                        .padding(.bottom, 8)

                    ForEach(group.items) { transaction in
                        transactionRow(transaction)
                    }
                }
            }
        }
    }

    private func transactionRow(_ transaction: Transaction) -> some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.paymentType.icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Tokens.Color.accentSoft)
                .frame(width: 30, height: 30)
                .background(Tokens.Color.accentSoftTint, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.clientName)
                    .font(Tokens.Typography.body)
                    .foregroundStyle(Tokens.Color.textPrimary)
                Text(transaction.service)
                    .font(Tokens.Typography.caption)
                    .foregroundStyle(Tokens.Color.textSecondary)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(currency(transaction.amount))")
                    .font(Tokens.Typography.body)
                    .foregroundStyle(Tokens.Color.accentText)
                Text(RelativeTime.label(for: transaction.date))
                    .font(Tokens.Typography.labelSmall)
                    .foregroundStyle(Tokens.Color.textTertiary)
            }
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
        }
    }

    private func currency(_ amount: Decimal) -> String {
        amount.formatted(.currency(code: "USD").precision(.fractionLength(0)))
    }
}

#Preview {
    NavigationStack {
        WalletView()
    }
    .environment(Router())
}
