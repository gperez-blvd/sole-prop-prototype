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

    /// The CUE that kicks off this moment — DETAIL noticed a client message
    /// and flagged it, plus the ACTION it already took in response. Shown
    /// first; the threshold proposal below follows from it.
    static let pendingCue: Cue? = Cue(
        spokenText: "Priya S. is running 10 minutes late.",
        action: DetailAction(description: "Let her know you're running a few minutes behind too.")
    )

    /// A threshold-tuning proposal DETAIL is still learning toward — surfaced
    /// right after the cue above, gone once she answers it once.
    static let pendingThresholdProposal: Proposal? = Proposal(
        context: "Priya S. — running late",
        spokenFraming: "Since I flagged that — want me to tell you next time someone's 10 minutes late, or wait until 20?",
        finding: "This is the first time this has come up, so I don't know yet how much notice you want.",
        options: [
            ThresholdOption(boundaryValue: 10, label: "10 min"),
            ThresholdOption(boundaryValue: 20, label: "20 min"),
        ],
        threshold: Threshold(
            ruleStatement: "Flag it when an appointment is running late.",
            boundaryValue: 15,
            unit: "minutes",
            confidence: .low,
            evidenceCount: 1
        )
    )

    /// The "how have we been doing the last 3 months" demo scenario — Cue's
    /// quarterly recap plus three growth ideas pulled from the DETAIL/CUE
    /// prototype's own "We grow you" act. Cue never acts on these itself;
    /// tapping one just has it elaborate.
    static let quarterlyBrief = QuarterlyBrief(
        revenue: 123_500,
        clientsSeen: 273,
        newClients: 68,
        ideas: [
            GrowthIdea(
                title: "Rebooking cadence",
                teaser: "Tox clients are rebooking 18 days later than 6 months ago — roughly $40,000 a year at the old cadence.",
                elaboration: "Your tox clients are rebooking 18 days later than they were six months ago. If we bring them back to your old cadence, that's roughly $40,000 a year. Want me to build a re-engagement plan?"
            ),
            GrowthIdea(
                title: "Thursday demand",
                teaser: "14 Thursday requests turned away this quarter — enough demand for one more half day a month.",
                elaboration: "You're full every Thursday afternoon, and you turned away 14 Thursday requests this quarter. There's enough demand for one more half day a month. Want to see what that could generate?"
            ),
            GrowthIdea(
                title: "Lip filler pricing",
                teaser: "Comparable practices charge $725–$800 for lip filler versus your $650, with weaker reviews.",
                elaboration: "Your lip filler is $650. The three closest comparable practices charge $725 to $800, and your reviews are stronger. Want to try $700 for new clients and see what happens to bookings?"
            ),
        ]
    )
}
