import Foundation

/// Static mock data backing the Home screen and the voice assistant's answers
/// until this is wired to real Boulevard data.
enum HomeMockData {
    static let ownerFirstName = "Jazz"
    static let businessName = "Jazz Aesthetics"

    static var todaysAppointments: [Appointment] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        func time(_ hour: Int, _ minute: Int = 0) -> Date {
            calendar.date(bySettingHour: hour, minute: minute, second: 0, of: today) ?? today
        }

        return [
            Appointment(clientName: "Maya N.", service: "Neurotoxin", startTime: time(11), durationMinutes: 30, isFirstTime: true, note: "Referred by Dani. Nervous about bruising."),
            Appointment(clientName: "Priya S.", service: "Lip filler", startTime: time(12), durationMinutes: 45, isFirstTime: false, note: nil),
            Appointment(clientName: "Tasha W.", service: "HydraFacial", startTime: time(14), durationMinutes: 50, isFirstTime: false, note: nil),
            Appointment(clientName: "Dani R.", service: "Neurotoxin", startTime: time(16, 15), durationMinutes: 30, isFirstTime: false, note: "Running behind — rain expected."),
        ]
    }()

    static var nextAppointment: Appointment? {
        let now = Date()
        return todaysAppointments.first { $0.startTime >= now } ?? todaysAppointments.first
    }

    static let unreadNotificationCount = 2
    static let unreadMessageCount = 3

    /// Coarse booked/open slots across the day, for the Home screen's day strip.
    static let dayStripSlots = [false, true, true, true, false, true, false, true, false, true]

    /// A threshold-tuning proposal DETAIL is still learning toward — surfaced
    /// on Home while confidence stays low, gone once she answers it once.
    static let pendingThresholdProposal: Proposal? = Proposal(
        spokenFraming: "Want me to flag it when someone's running 10 minutes late, or wait until 20?",
        finding: "You've had a few late arrivals this month and I haven't said anything — I'm not sure yet how much notice you want.",
        options: [
            ThresholdOption(boundaryValue: 10, label: "10 min"),
            ThresholdOption(boundaryValue: 20, label: "20 min"),
        ],
        threshold: Threshold(
            ruleStatement: "Flag it when an appointment is running late.",
            boundaryValue: 15,
            unit: "minutes",
            confidence: .low,
            evidenceCount: 3
        )
    )
}
