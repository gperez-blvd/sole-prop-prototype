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
                        InitialsAvatar(name: appointment.clientName, size: 24)
                        Text(appointment.clientName)
                            .font(BUITokens.Typography.cardTitle)
                            .foregroundStyle(BUITokens.Color.textPrimary)
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 15))
                            .foregroundStyle(BUITokens.Color.textPrimary)
                            .frame(width: 24, height: 24)
                        Text("\(appointment.service) - \(appointment.startTime.formatted(date: .omitted, time: .shortened))")
                            .font(BUITokens.Typography.cardTitle)
                            .foregroundStyle(BUITokens.Color.textPrimary)
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
                    .foregroundStyle(BUITokens.Color.textPrimary)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(16)
        .background(BUITokens.Color.background)
        .clipShape(RoundedRectangle(cornerRadius: BUITokens.Radius.card))
        .shadow(color: BUITokens.Shadow.medium, radius: BUITokens.Shadow.mediumRadius, x: 0, y: BUITokens.Shadow.mediumY)
    }
}

/// Text-initials placeholder avatar — the BUI `Avatar` component's `Text`
/// variant, used until real client photos are wired up.
struct InitialsAvatar: View {
    var name: String
    var size: CGFloat

    private var initial: String {
        String(name.first ?? "?")
    }

    var body: some View {
        Circle()
            .fill(BUITokens.Color.disabled.opacity(0.4))
            .frame(width: size, height: size)
            .overlay(
                Text(initial)
                    .font(.system(size: size * 0.5, weight: .semibold))
                    .foregroundStyle(BUITokens.Color.textPrimary)
            )
    }
}
