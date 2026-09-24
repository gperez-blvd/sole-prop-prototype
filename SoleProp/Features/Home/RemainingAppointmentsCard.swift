import SwiftUI

/// Today's other appointments (everything but whichever one is shown as
/// Next Appointment) — a plain list, not a second schedule screen. "See
/// full day" hands off to the real Schedule for anything more than that.
struct RemainingAppointmentsCard: View {
    var appointments: [Appointment]
    var onViewFullDay: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(appointments) { appointment in
                HStack(spacing: 10) {
                    InitialsAvatar(name: appointment.clientName, size: 22)
                    Text(appointment.clientName)
                        .font(Tokens.Typography.bodyRegular)
                        .foregroundStyle(Tokens.Color.textPrimary)
                    Spacer()
                    Text(appointment.startTime.formatted(date: .omitted, time: .shortened))
                        .font(Tokens.Typography.caption)
                        .foregroundStyle(Tokens.Color.textTertiary)
                }
                .padding(.vertical, 8)

                if appointment.id != appointments.last?.id {
                    Divider()
                }
            }

            Button(action: onViewFullDay) {
                HStack {
                    Text("See full day")
                        .font(Tokens.Typography.caption)
                        .foregroundStyle(Tokens.Color.textSecondary)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Tokens.Color.textTertiary)
                }
                .padding(.top, appointments.isEmpty ? 0 : 10)
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
    RemainingAppointmentsCard(appointments: HomeMockData.remainingAppointments, onViewFullDay: {})
        .padding(28)
        .background(Tokens.Color.background)
}
