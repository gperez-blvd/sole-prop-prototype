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
            Appointment(clientName: "Maya N.", service: "Neurotoxin", startTime: time(11), durationMinutes: 30, isFirstTime: true, note: "Referred by Dani. Nervous about bruising.", price: 325),
            Appointment(clientName: "Priya S.", service: "Lip filler", startTime: time(12), durationMinutes: 45, isFirstTime: false, note: nil, price: 650),
            Appointment(clientName: "Tasha W.", service: "HydraFacial", startTime: time(14), durationMinutes: 50, isFirstTime: false, note: nil, price: 199),
            Appointment(clientName: "Dani R.", service: "Neurotoxin", startTime: time(16, 15), durationMinutes: 30, isFirstTime: false, note: "Running behind — rain expected.", price: 325),
        ]
    }()

    static var nextAppointment: Appointment? {
        let now = Date()
        return todaysAppointments.first { $0.startTime >= now } ?? todaysAppointments.first
    }

    /// Finds the appointment whose client is named in `text` (e.g. "check out
    /// Tasha"); falls back to `nextAppointment` when no name is mentioned —
    /// used by Cue for checkout and similar by-name requests.
    static func appointment(matching text: String) -> Appointment? {
        let lower = text.lowercased()
        let named = todaysAppointments.first { appointment in
            let firstName = appointment.clientName.split(separator: " ").first.map(String.init) ?? appointment.clientName
            return lower.contains(firstName.lowercased())
        }
        return named ?? nextAppointment
    }

    /// The "Checkout Tasha" demo scenario: Cue proactively adds a product
    /// it says the client mentioned wanting, flagged for review rather than
    /// silently included. Single source of truth for both the checkout
    /// trigger and Cue's spoken reply, so they never drift apart.
    static func checkoutRecommendation(for appointment: Appointment) -> RecommendedItem? {
        guard appointment.clientName.contains("Tasha") else { return nil }
        return RecommendedItem(name: "Vitamin C Serum", price: 68, reason: "Tasha mentioned wanting serum")
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
