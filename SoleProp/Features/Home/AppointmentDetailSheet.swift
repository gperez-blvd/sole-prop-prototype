import SwiftUI

/// The appointment card's popup — a slide-up sheet (not a full-screen push)
/// with a close button and a "..." menu for edit/client-info/message. None of
/// those actions have designs yet, so they're placeholders for now.
struct AppointmentDetailSheet: View {
    var appointment: Appointment
    var onClose: () -> Void

    @State private var placeholderMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appointment.clientName)
                            .font(Tokens.Typography.largeTitle)
                            .foregroundStyle(Tokens.Color.textPrimary)
                        if appointment.isFirstTime {
                            Text("First time")
                                .font(Tokens.Typography.labelSmall)
                                .foregroundStyle(Tokens.Color.ochre)
                                .textCase(.uppercase)
                                .kerning(1.2)
                        }
                    }

                    detailRow(label: "Service", value: appointment.service)
                    detailRow(
                        label: "Time",
                        value: "\(appointment.startTime.formatted(date: .omitted, time: .shortened)) – \(appointment.endTime.formatted(date: .omitted, time: .shortened))"
                    )
                    if let note = appointment.note {
                        detailRow(label: "Note", value: note)
                    }

                    if let placeholderMessage {
                        Text(placeholderMessage)
                            .font(Tokens.Typography.caption)
                            .foregroundStyle(Tokens.Color.textTertiary)
                    }
                }
                .padding(24)
            }
            .background(Tokens.Color.background)
            .navigationTitle("Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Tokens.Color.textPrimary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Edit") { placeholderMessage = "Edit — not designed yet." }
                        Button("Client info") { placeholderMessage = "Client info — not designed yet." }
                        Button("Message") { placeholderMessage = "Message — not designed yet." }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(Tokens.Typography.labelSmall)
                .foregroundStyle(Tokens.Color.textTertiary)
                .textCase(.uppercase)
                .kerning(1.2)
            Text(value)
                .font(Tokens.Typography.body)
                .foregroundStyle(Tokens.Color.textPrimary)
        }
    }
}

#Preview {
    AppointmentDetailSheet(appointment: HomeMockData.todaysAppointments[0], onClose: {})
}
