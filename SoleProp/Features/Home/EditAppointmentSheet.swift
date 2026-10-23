import SwiftUI

/// A minimal appointment edit sheet — change the time (date *and* time, so
/// moving an appointment to a different day on the calendar works the same
/// gesture as nudging its hour) or change the service. Deliberately not a
/// full rebooking flow: no new-client creation, no multi-appointment drag
/// -to-reschedule on the calendar grid itself — editing lives here, in the
/// one place an appointment's own detail is already being looked at, which
/// is also where cancelling it lives (see `AppointmentDetailSheet`'s own
/// menu, not this sheet — cancel and edit are siblings, not nested).
struct EditAppointmentSheet: View {
    var appointment: Appointment
    var onSave: (Appointment) -> Void
    var onDismiss: () -> Void

    @State private var draftDate: Date
    @State private var draftService: String

    /// The same five services `Logs`-turned-`Performance`'s service mix
    /// already tracks — one fixed list app-wide, not a free-text field
    /// that could drift from what the rest of the app can even chart.
    private static let services = ["Neurotoxin", "HydraFacial", "Lip filler", "Chemical peel", "Laser resurfacing"]

    init(appointment: Appointment, onSave: @escaping (Appointment) -> Void, onDismiss: @escaping () -> Void) {
        self.appointment = appointment
        self.onSave = onSave
        self.onDismiss = onDismiss
        _draftDate = State(initialValue: appointment.startTime)
        _draftService = State(initialValue: appointment.service)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
                    VStack(alignment: .leading, spacing: 8) {
                        TrackedLabel(text: "Time")
                        DatePicker("", selection: $draftDate, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Tokens.Color.accentTint, in: RoundedRectangle(cornerRadius: Tokens.Radius.md))

                    VStack(alignment: .leading, spacing: 10) {
                        TrackedLabel(text: "Service")
                        FlowLayout(spacing: 8) {
                            ForEach(Self.services, id: \.self) { service in
                                ChoiceChip(title: service, isSelected: service == draftService) {
                                    draftService = service
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .background(Tokens.Color.background)
            .navigationTitle("Edit appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Tokens.Color.textPrimary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        var updated = appointment
                        updated.startTime = draftDate
                        updated.service = draftService
                        onSave(updated)
                    }
                    .font(Tokens.Typography.button)
                }
            }
        }
    }
}

#Preview {
    EditAppointmentSheet(appointment: HomeMockData.todaysAppointments[0], onSave: { _ in }, onDismiss: {})
}
