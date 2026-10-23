import SwiftUI

/// A ranked breakdown rendered as literal progress bars — a fixed `silt`
/// track per row with an `accentSoft` fill sized to that row's own share
/// of the list's max value. Each row keeps the same label across a data
/// refresh (see `RankedMetric`'s stable, label-derived `id`), so when the
/// underlying values change the fill widens or narrows in place, the way
/// a progress bar actually behaves — not a bar that disappears and a new
/// one growing from zero in its spot.
struct RankedBarList: View {
    var data: [RankedMetric]

    private var maxValue: Int { data.map(\.value).max() ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            ForEach(data) { item in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(item.label)
                            .font(Tokens.Typography.body)
                            .foregroundStyle(Tokens.Color.textPrimary)
                        Spacer()
                        Text("\(item.value)")
                            .font(Tokens.Typography.body)
                            .foregroundStyle(Tokens.Color.textSecondary)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Tokens.Color.silt)
                            Capsule()
                                .fill(Tokens.Color.accentSoft)
                                .frame(width: fillWidth(item, in: geo.size.width))
                        }
                    }
                    .frame(height: 10)
                }
            }
        }
    }

    private func fillWidth(_ item: RankedMetric, in totalWidth: CGFloat) -> CGFloat {
        guard maxValue > 0 else { return 0 }
        let ratio = Double(item.value) / Double(maxValue)
        return max(CGFloat(ratio) * totalWidth, 8)
    }
}
