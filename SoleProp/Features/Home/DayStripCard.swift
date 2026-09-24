import SwiftUI

/// The Home screen's condensed day overview — a strip of booked/open slot
/// segments with an arrow through to the (not-yet-designed) full scheduler.
/// Figma's mock content repeats a client name here; using "Today" instead
/// since that reads correctly as a day-level summary rather than a
/// per-client one — flagging in case the real design intends otherwise.
struct DayStripCard: View {
    var slots: [Bool] // true = booked
    var onViewFullSchedule: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Today")
                    .font(BUITokens.Typography.cardTitle)
                    .foregroundStyle(BUITokens.Color.textPrimary)

                HStack(spacing: 5) {
                    ForEach(Array(slots.enumerated()), id: \.offset) { _, booked in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(booked ? BUITokens.Color.bluegreen : BUITokens.Color.disabled)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onViewFullSchedule) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(BUITokens.Color.textPrimary)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(BUITokens.Color.background)
        .clipShape(RoundedRectangle(cornerRadius: BUITokens.Radius.card))
        .shadow(color: BUITokens.Shadow.medium, radius: BUITokens.Shadow.mediumRadius, x: 0, y: BUITokens.Shadow.mediumY)
    }
}
