import SwiftUI

/// The appointment card's popup — a slide-up sheet (not a full-screen push)
/// with a close button and a "..." menu for edit/client-info/message. The
/// client is nested here with the one line DETAIL knows about her; tapping
/// her name (or "Client info") opens her page. Edit and Message have no
/// designs yet, so they're placeholders for now.
struct AppointmentDetailSheet: View {
    var appointment: Appointment
    var onClose: () -> Void

    @State private var placeholderMessage: String?
    @State private var showClient = false

    private var clientMemory: ClientMemory? { HomeMockData.clientMemory(for: appointment) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Button {
                            showClient = true
                        } label: {
                            HStack(spacing: 6) {
                                Text(appointment.clientName)
                                    .font(Tokens.Typography.largeTitle)
                                    .foregroundStyle(Tokens.Color.textPrimary)
                                if clientMemory != nil {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(Tokens.Color.textTertiary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(clientMemory == nil)
                        if let sentence = clientMemory?.sentence {
                            Text(sentence)
                                .font(Tokens.Typography.caption)
                                .foregroundStyle(Tokens.Color.textSecondary)
                        }
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
            }
            .background(Tokens.Color.background)
            .navigationDestination(isPresented: $showClient) {
                if let clientMemory {
                    ClientDetailView(memory: clientMemory)
                }
            }
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
                        Button("Client info") {
                            if clientMemory != nil { showClient = true } else { placeholderMessage = "Client info — not designed yet." }
                        }
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
