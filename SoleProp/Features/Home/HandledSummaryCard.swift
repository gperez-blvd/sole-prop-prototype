import SwiftUI

/// The day's ACTION/SIGNAL audit, collapsed to one line — a proof point she
/// can open, never a number pushed at her. Expands in place; no separate
/// screen, no inbox.
struct HandledSummaryCard: View {
    var count: Int
    var examples: [String]

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: isExpanded ? 10 : 0) {
            Button {
                withAnimation { isExpanded.toggle() }
            } label: {
                HStack {
                    Text("\(count) things handled without you today")
                        .font(Tokens.Typography.caption)
                        .foregroundStyle(Tokens.Color.textSecondary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Tokens.Color.textTertiary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(examples, id: \.self) { example in
                        Text("· \(example)")
                            .font(Tokens.Typography.caption)
                            .foregroundStyle(Tokens.Color.textTertiary)
                    }
                }
                .transition(.opacity)
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
    HandledSummaryCard(
        count: 12,
        examples: [
            "Moved Priya's cleanup window so Tasha's checkout wasn't rushed",
            "Sent Dani's delay notice as soon as the rain forecast came in",
        ]
    )
    .padding(28)
    .background(Tokens.Color.background)
}
