import SwiftUI

/// Placeholder architecture for Wallet — a summary card (what's coming,
/// in her words) over a plain history list, reusing the same row
/// skeleton as Notifications/Messages. No functionality: tapping a row
/// surfaces the same "not designed yet" placeholder the rest of the app
/// uses for unbuilt detail.
struct WalletView: View {
    @Environment(Router.self) private var router
    @State private var placeholderMessage: String?

    private var payouts: [Payout] { HomeMockData.payoutHistory }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
                summaryCard

                VStack(alignment: .leading, spacing: 0) {
                    Text("History")
                        .font(Tokens.Typography.label)
                        .foregroundStyle(Tokens.Color.textTertiary)
                        .padding(.bottom, 8)

                    ForEach(payouts) { payout in
                        row(payout)
                    }
                }
            }
            .padding(.horizontal, Tokens.Spacing.lg)
            .padding(.top, Tokens.Spacing.lg)
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

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your money")
                .font(Tokens.Typography.label)
                .foregroundStyle(Tokens.Color.textTertiary)
            Text(currency(HomeMockData.nextPayoutAmount))
                .font(Tokens.Typography.largeTitle)
                .foregroundStyle(Tokens.Color.textPrimary)
            Text("Lands \(HomeMockData.nextPayoutDate.formatted(.dateTime.weekday(.wide)))")
                .font(Tokens.Typography.caption)
                .foregroundStyle(Tokens.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func row(_ payout: Payout) -> some View {
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
