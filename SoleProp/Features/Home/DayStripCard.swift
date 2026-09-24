import SwiftUI

/// The Home screen's condensed day overview — a strip of booked/open slot
/// segments. The whole card is tappable through to the (not-yet-designed)
/// full scheduler. Figma's mock content repeats a client name here; using
/// "Today" instead since that reads correctly as a day-level summary rather
/// than a per-client one — flagging in case the real design intends
/// otherwise.
struct DayStripCard: View {
    var slots: [Bool] // true = booked
    var onViewFullSchedule: () -> Void

    var body: some View {
        Button(action: onViewFullSchedule) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today")
                        .font(Tokens.Typography.body)
                        .foregroundStyle(Tokens.Color.textPrimary)

                    HStack(spacing: 5) {
                        ForEach(Array(slots.enumerated()), id: \.offset) { _, booked in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(booked ? Tokens.Color.ochre : Tokens.Color.silt)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .frame(width: 28, height: 28)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
        .background(Tokens.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.card)
                .strokeBorder(Tokens.Color.hairline)
        )
    }
}
