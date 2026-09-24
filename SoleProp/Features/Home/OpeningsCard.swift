import SwiftUI

/// Bookable time still open today, priced — revenue at risk made concrete
/// so filling it is a decision she makes, not something she has to notice
/// on her own.
struct OpeningsCard: View {
    var openings: [Opening]
    var onTap: (Opening) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Still open today")
                .font(Tokens.Typography.label)
                .foregroundStyle(Tokens.Color.textTertiary)
                .textCase(.uppercase)
                .kerning(1.4)

            VStack(spacing: 0) {
                ForEach(openings) { opening in
                    Button {
                        onTap(opening)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(opening.slotLabel)
                                    .font(Tokens.Typography.body)
                                    .foregroundStyle(Tokens.Color.textPrimary)
                                Text("\(opening.durationMinutes) min")
                                    .font(Tokens.Typography.caption)
                                    .foregroundStyle(Tokens.Color.textTertiary)
                            }
                            Spacer()
                            Text(opening.estimatedValue, format: .currency(code: "USD").precision(.fractionLength(0)))
                                .font(Tokens.Typography.value)
                                .foregroundStyle(Tokens.Color.textPrimary)
                        }
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)

                    if opening.id != openings.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(16)
        .background(Tokens.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.card)
                .strokeBorder(Tokens.Color.hairline)
        )
    }
}

#Preview {
    OpeningsCard(
        openings: [Opening(slotLabel: "Today 5:15 PM", durationMinutes: 45, estimatedValue: 199)],
        onTap: { _ in }
    )
    .padding(28)
    .background(Tokens.Color.background)
}
