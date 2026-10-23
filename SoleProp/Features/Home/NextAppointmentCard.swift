import SwiftUI

struct NextAppointmentCard: View {
    var appointment: Appointment
    var onTap: () -> Void
    var onEdit: () -> Void
    var onClientInfo: () -> Void
    var onMessage: () -> Void
    var onCheckout: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Avatar(name: appointment.clientName, size: 24, photoURL: PersonPhoto.url(for: appointment.clientName))
                        Text(appointment.clientName)
                            .font(Tokens.Typography.body)
                            .foregroundStyle(Tokens.Color.textPrimary)
                    }
                    HStack(spacing: 8) {
                        Image(systemName: appointment.serviceIcon)
                            .font(.system(size: 15))
                            .foregroundStyle(Tokens.Color.textPrimary)
                            .frame(width: 24, height: 24)
                        Text("\(appointment.service) - \(appointment.startTime.formatted(date: .omitted, time: .shortened))")
                            .font(Tokens.Typography.body)
                            .foregroundStyle(Tokens.Color.textPrimary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Menu {
                Button("Edit", action: onEdit)
                Button("Client info", action: onClientInfo)
                Button("Message", action: onMessage)
                Button("Checkout", action: onCheckout)
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .frame(width: 36, height: 36)
            }
        }
        .cardStyle()
    }
}
