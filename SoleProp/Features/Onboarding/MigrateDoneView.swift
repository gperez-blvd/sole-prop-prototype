import SwiftUI

/// What came over, and what needs a human. Counts first, so it feels like
/// hers. Then only the records that need a decision, each with a suggested
/// default — this is the payoff for not asking about microneedling up front:
/// Boulevard learned it from her data instead of a form.
struct MigrateDoneView: View {
    var state: OnboardingState
    var onBack: () -> Void

    private var providerName: String { state.migrationProvider ?? "your old system" }
    private let cards: [(String, String, String)] = [
        ("1,284", "Clients", "412 new to your list"),
        ("131", "Upcoming appointments", "next 6 weeks, on your book"),
        ("3,912", "Past appointments", "three years of history"),
        ("13", "Services", "11 matched, 2 new"),
        ("$1,150", "Gift card balances", "9 open cards"),
        ("6", "Active packages", "14 sessions remaining"),
        ("3,640", "Chart notes", "1,284 signed consents"),
        ("2,210", "Photos", "before and after"),
    ]

    var body: some View {
        OnboardingScreen(primaryCTA: .init("Back to home", action: {
            state.migrationDone = true
            onBack()
        })) {
            Text("Your history is in Cue.")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.textPrimary)

            Text("Everything from \(providerName) came over. It should already feel like yours.")
                .font(Tokens.Typography.bodyRegular)
                .foregroundStyle(Tokens.Color.textSecondary)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(cards, id: \.1) { card in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.0)
                            .font(.dmSans(20, weight: .semibold))
                            .foregroundStyle(Tokens.Color.textPrimary)
                        TrackedLabel(text: card.1, font: Tokens.Typography.labelSmall)
                        Text(card.2)
                            .font(.dmSans(12.5, weight: .regular))
                            .foregroundStyle(Tokens.Color.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle(padding: 12)
                }
            }

            (Text("Imported, not client-facing. ").fontWeight(.semibold) + Text("Nobody was texted. \(providerName) still sends its own reminders until you switch them off."))
                .font(.dmSans(13.5, weight: .regular))
                .foregroundStyle(Tokens.Color.textSecondary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Tokens.Color.silt)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            TrackedLabel(text: "Needs your review · \(openCount) of \(state.migrationReviewItems.count) open")
                .padding(.top, Tokens.Spacing.sm)

            VStack(spacing: 8) {
                ForEach(state.migrationReviewItems) { item in
                    reviewCard(item)
                }
            }
        }
        .onAppear { state.migrationDone = true }
    }

    private var openCount: Int {
        state.migrationReviewItems.filter { !state.acceptedReviewIDs.contains($0.id) }.count
    }

    private func reviewCard(_ item: MigrationReviewItem) -> some View {
        let isDone = state.acceptedReviewIDs.contains(item.id)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                TrackedLabel(text: item.category, font: Tokens.Typography.labelSmall, color: isDone ? Tokens.Color.textPrimary : Tokens.Color.ochre)
                Spacer()
                TrackedLabel(text: isDone ? "Done" : "Needs review", font: Tokens.Typography.labelSmall, color: isDone ? Tokens.Color.textPrimary : Tokens.Color.ochre)
            }
            Text(item.title)
                .font(.dmSans(13.5, weight: .semibold))
                .foregroundStyle(Tokens.Color.textPrimary)
            Text(item.detail)
                .font(.dmSans(13.5, weight: .regular))
                .foregroundStyle(Tokens.Color.textSecondary)
            Text("Suggested: \(item.suggestion)")
                .font(.dmSans(13.5, weight: .regular))
                .foregroundStyle(Tokens.Color.textSecondary)

            if !isDone {
                HStack(spacing: 8) {
                    Button("Accept") {
                        state.acceptedReviewIDs.insert(item.id)
                    }
                    .buttonStyle(MiniButtonStyle(filled: true))
                    Button("Later") {}
                        .buttonStyle(MiniButtonStyle(filled: false))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(padding: 12)
    }
}

private struct MiniButtonStyle: ButtonStyle {
    var filled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.dmSans(13.5, weight: .semibold))
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .foregroundStyle(filled ? Tokens.Color.onPrimaryFill : Tokens.Color.textPrimary)
            .background(RoundedRectangle(cornerRadius: Tokens.Radius.button).fill(filled ? Tokens.Color.primaryFill : Color.clear))
            .overlay(RoundedRectangle(cornerRadius: Tokens.Radius.button).strokeBorder(filled ? .clear : Tokens.Color.textPrimary, lineWidth: 1))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

#Preview {
    let state = OnboardingState()
    state.migrationProvider = "Vagaro"
    return MigrateDoneView(state: state, onBack: {})
}
