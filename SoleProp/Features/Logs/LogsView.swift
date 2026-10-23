import SwiftUI

/// Placeholder architecture for Logs — a small, fixed set of the
/// business facts that actually matter, each on its own card with one
/// simple chart: revenue over time, the service mix, product usage.
/// Deliberately not a dashboard in the "Insights tab" sense CLAUDE.md's
/// smells list warns about — three cards, one chart each, nothing
/// cross-filterable, nothing that invites adding a fourth metric just
/// because the data exists.
///
/// One shared Week/Month/Year toggle drives all three — not just
/// revenue's own chart — since a time window that only reshapes one of
/// three cards reads as "the other two are broken," not as a deliberate
/// scope choice. `RevenueRange` and every `HomeMockData` lookup keyed on
/// it cap at a year, the same ceiling most light business-reporting
/// views settle on, so the toggle can't imply more history than this
/// screen actually has. Export surfaces the same "not designed yet"
/// placeholder the rest of the app uses for unbuilt detail.
struct LogsView: View {
    @Environment(Router.self) private var router
    @State private var range: RevenueRange = .month
    @State private var placeholderMessage: String?

    private var revenueData: [RevenuePoint] { HomeMockData.revenueSeries(for: range) }
    private var revenueTotal: Decimal { revenueData.reduce(0) { $0 + $1.amount } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
                SegmentedToggle(options: RevenueRange.allCases, selection: $range)

                revenueCard
                metricCard(title: "Services booked", data: HomeMockData.serviceMix(for: range))
                metricCard(title: "Product usage", data: HomeMockData.productUsage(for: range))
            }
            .padding(.horizontal, Tokens.Spacing.lg)
            .padding(.top, Tokens.Spacing.lg)
            .padding(.bottom, Tokens.Spacing.xl)
        }
        .background(Tokens.Color.background)
        .navigationTitle("Logs")
        .navigationBarTitleDisplayMode(.inline)
        .backIconButton { router.pop() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    placeholderMessage = "Exporting this data — not designed yet."
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Tokens.Color.textPrimary)
                }
            }
        }
        .alert("Not designed yet", isPresented: .constant(placeholderMessage != nil), presenting: placeholderMessage) { _ in
            Button("OK") { placeholderMessage = nil }
        } message: { message in
            Text(message)
        }
    }

    private var revenueCard: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Revenue")
                    .font(Tokens.Typography.label)
                    .foregroundStyle(Tokens.Color.textTertiary)
                Text(currency(revenueTotal))
                    .font(Tokens.Typography.largeTitle)
                    .foregroundStyle(Tokens.Color.textPrimary)
            }

            AnimatedBarChart(points: revenueData, height: 190)
                .padding(.top, 6)
        }
        .cardStyle(padding: Tokens.Spacing.lg)
    }

    /// The ranked-bar treatment shared by Services booked and Product
    /// usage — literal progress bars, see `RankedBarList`.
    private func metricCard(title: String, data: [RankedMetric]) -> some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            Text(title)
                .font(Tokens.Typography.label)
                .foregroundStyle(Tokens.Color.textTertiary)

            RankedBarList(data: data)
        }
        .cardStyle(padding: Tokens.Spacing.lg)
    }

    private func currency(_ amount: Decimal) -> String {
        amount.formatted(.currency(code: "USD").precision(.fractionLength(0)))
    }
}

#Preview {
    NavigationStack {
        LogsView()
    }
    .environment(Router())
}
