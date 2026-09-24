import SwiftUI

/// A glanceable strip of the day's booked/open hours — not a list of
/// names, just enough to recognise the shape of the day at a glance
/// (per CLAUDE.md's "glanceable" level: a card, not a study). Matches the
/// Figma availability-strip design: one block per business hour, filled
/// when something's booked, dim when it's open. "See full day" hands off
/// to the real Schedule for anything more than that.
struct RemainingAppointmentsCard: View {
    /// Today's full schedule (not just what's left) — the strip shows the
    /// whole day's shape, not only what hasn't happened yet.
    var appointments: [Appointment]
    var onViewFullDay: () -> Void

    private static let businessHours = 9..<18 // 9am–6pm
    private static let bookedColor = SwiftUI.Color(hex: "#81C398")
    private static let openColor = SwiftUI.Color(hex: "#AFAFAF")

    private var bookedHours: Set<Int> {
        let calendar = Calendar.current
        return Set(appointments.map { calendar.component(.hour, from: $0.startTime) })
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(Self.businessHours), id: \.self) { hour in
                RoundedRectangle(cornerRadius: 2)
                    .fill(bookedHours.contains(hour) ? Self.bookedColor : Self.openColor)
                    .frame(width: 20, height: 20)
            }

            Spacer(minLength: 8)

            Button(action: onViewFullDay) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Tokens.Color.textTertiary)
            }
            .buttonStyle(.plain)
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
    RemainingAppointmentsCard(appointments: HomeMockData.todaysAppointments, onViewFullDay: {})
        .padding(28)
        .background(Tokens.Color.background)
}
