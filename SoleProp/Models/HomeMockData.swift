import Foundation

/// Static mock data backing the Home screen and the voice assistant's answers
/// until this is wired to real Boulevard data.
///
/// Everything below `currentStage` is read from `Dataset`, one per
/// `LifecycleStage`. The switch in the PROTOTYPE section of `MenuSheet`
/// changes `currentStage`; nothing here or upstream branches on it —
/// `dataset(for:)` is the one place that maps stage to seed data. `HomeView`
/// in turn never reads `currentStage` at all — it ranks whatever these
/// fields contain by density, so the day's shape comes from what exists,
/// not from which stage produced it.
enum HomeMockData {
    static let ownerFirstName = "Jazz"
    static let businessName = "Jazz Aesthetics"
    static let bookingLink = "bookjazz.blvd.com"

    private static let stageStorageKey = "prototype.lifecycleStage"

    static var currentStage: LifecycleStage {
        get {
            UserDefaults.standard.string(forKey: stageStorageKey)
                .flatMap(LifecycleStage.init(rawValue:)) ?? .steady
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: stageStorageKey) }
    }

    static var todaysAppointments: [Appointment] { dataset(for: currentStage).appointments }
    static var pendingCue: Cue? { dataset(for: currentStage).pendingCue }
    static var pendingThresholdProposal: Proposal? { dataset(for: currentStage).pendingThresholdProposal }
    static var openings: [Opening] { dataset(for: currentStage).openings }
    static var capabilityLimitationNote: String? { dataset(for: currentStage).capabilityLimitationNote }
    static var handledCount: Int { dataset(for: currentStage).handledCount }
    static var handledExamples: [String] { dataset(for: currentStage).handledExamples }
    static var unreadNotificationCount: Int { dataset(for: currentStage).unreadNotificationCount }
    static var unreadMessageCount: Int { dataset(for: currentStage).unreadMessageCount }

    static var nextAppointment: Appointment? {
        let now = Date()
        let appointments = todaysAppointments
        return appointments.first { $0.startTime >= now } ?? appointments.first
    }

    /// Whatever's still ahead today after `nextAppointment` — never an
    /// already-passed one, even when `nextAppointment` itself had to fall
    /// back to the day's first appointment because every real slot is
    /// behind "now".
    static var remainingAppointments: [Appointment] {
        guard let next = nextAppointment else { return [] }
        return todaysAppointments
            .filter { $0.id != next.id && $0.startTime > next.startTime }
            .sorted { $0.startTime < $1.startTime }
    }

    /// Finds the appointment whose client is named in `text` (e.g. "check out
    /// Tasha"); falls back to `nextAppointment` when no name is mentioned —
    /// used by Cue for checkout and similar by-name requests.
    static func appointment(matching text: String) -> Appointment? {
        let lower = text.lowercased()
        let appointments = todaysAppointments
        let named = appointments.first { appointment in
            let firstName = appointment.clientName.split(separator: " ").first.map(String.init) ?? appointment.clientName
            return lower.contains(firstName.lowercased())
        }
        return named ?? appointments.first
    }

    /// The "Checkout Tasha" demo scenario: Cue proactively adds a product
    /// it says the client mentioned wanting, flagged for review rather than
    /// silently included. Single source of truth for both the checkout
    /// trigger and Cue's spoken reply, so they never drift apart.
    static func checkoutRecommendation(for appointment: Appointment) -> RecommendedItem? {
        guard appointment.clientName.contains("Tasha") else { return nil }
        return RecommendedItem(name: "Vitamin C Serum", price: 68, reason: "Tasha mentioned wanting serum")
    }

    // MARK: - Datasets

    private struct Dataset {
        let appointments: [Appointment]
        let pendingCue: Cue?
        let pendingThresholdProposal: Proposal?
        let openings: [Opening]
        /// Set only while a real capability is still unconnected — stated
        /// honestly as DETAIL's limitation, never as homework for her. Empty
        /// once the capability activates, which is itself real evidence a
        /// dataset uses to decide whether to set this.
        let capabilityLimitationNote: String?
        let handledCount: Int
        let handledExamples: [String]
        let unreadNotificationCount: Int
        let unreadMessageCount: Int
    }

    private static func dataset(for stage: LifecycleStage) -> Dataset {
        switch stage {
        case .activating: activatingDataset
        case .steady: steadyDataset
        case .established: establishedDataset
        }
    }

    private static let calendar = Calendar.current
    private static var today: Date { calendar.startOfDay(for: Date()) }
    private static func time(_ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: today) ?? today
    }

    /// Week 2–month 1. A near-empty day — DETAIL hasn't seen enough of this
    /// business yet to have much to flag, so what little it says leans on
    /// cohort priors rather than observed history. No openings and nothing
    /// handled yet, because there isn't enough history for either.
    private static let activatingDataset = Dataset(
        appointments: [
            Appointment(clientName: "Maya N.", service: "Neurotoxin", startTime: time(11), durationMinutes: 30, isFirstTime: true, note: "Referred by Dani. Nervous about bruising.", price: 325),
            Appointment(clientName: "Priya S.", service: "Lip filler", startTime: time(13), durationMinutes: 45, isFirstTime: true, note: nil, price: 650),
            Appointment(clientName: "Dani R.", service: "Neurotoxin", startTime: time(15), durationMinutes: 30, isFirstTime: false, note: nil, price: 325),
        ],
        pendingCue: Cue(
            spokenText: "That's your 20th booked appointment this month.",
            action: DetailAction(description: "Noted the milestone — nothing you need to do."),
            isMilestone: true
        ),
        pendingThresholdProposal: Proposal(
            context: "Priya S. — running late",
            spokenFraming: "I can text clients when you're running behind, but I don't have permission to send messages yet — want me to set that up?",
            finding: "Texting unlocks same-day delay notices — most solo injectors turn this on in their first month.",
            options: [
                ThresholdOption(boundaryValue: 1, label: "Set it up"),
                ThresholdOption(boundaryValue: 0, label: "Not yet"),
            ],
            threshold: Threshold(
                ruleStatement: "Text clients when an appointment is running late.",
                boundaryValue: 1,
                unit: "capability",
                confidence: .low,
                evidenceCount: 1
            )
        ),
        openings: [],
        capabilityLimitationNote: "I can't collect payment on my own yet — you'll still need to run cards yourself until that's connected.",
        handledCount: 0,
        handledExamples: [],
        unreadNotificationCount: 1,
        unreadMessageCount: 1
    )

    /// Year 1. The canonical Tuesday from HANDOFF.md — kept as the baseline.
    private static let steadyDataset = Dataset(
        appointments: [
            Appointment(clientName: "Maya N.", service: "Neurotoxin", startTime: time(11), durationMinutes: 30, isFirstTime: true, note: "Referred by Dani. Nervous about bruising.", price: 325),
            Appointment(clientName: "Priya S.", service: "Lip filler", startTime: time(12), durationMinutes: 45, isFirstTime: false, note: nil, price: 650),
            Appointment(clientName: "Tasha W.", service: "HydraFacial", startTime: time(14), durationMinutes: 50, isFirstTime: false, note: nil, price: 199),
            Appointment(clientName: "Dani R.", service: "Neurotoxin", startTime: time(16, 15), durationMinutes: 30, isFirstTime: false, note: "Running behind — rain expected.", price: 325),
        ],
        pendingCue: Cue(
            spokenText: "Priya S. is running 10 minutes late.",
            action: DetailAction(description: "Let her know you're running a few minutes behind too.")
        ),
        pendingThresholdProposal: Proposal(
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
        ),
        openings: [
            Opening(slotLabel: "Today 5:15 PM", durationMinutes: 45, estimatedValue: 199),
        ],
        capabilityLimitationNote: nil,
        handledCount: 12,
        handledExamples: [
            "Moved Priya's cleanup window so Tasha's checkout wasn't rushed",
            "Sent Dani's delay notice as soon as the rain forecast came in",
        ],
        unreadNotificationCount: 2,
        unreadMessageCount: 3
    )

    /// Year 2+. A full day, high-confidence thresholds, and a growth
    /// proposal that cites an observed pattern with a real value attached
    /// rather than asking a first-time question.
    private static let establishedDataset = Dataset(
        appointments: [
            Appointment(clientName: "Maya N.", service: "Neurotoxin", startTime: time(9), durationMinutes: 30, isFirstTime: false, note: nil, price: 325),
            Appointment(clientName: "Priya S.", service: "Lip filler", startTime: time(10, 30), durationMinutes: 45, isFirstTime: false, note: nil, price: 725),
            Appointment(clientName: "Tasha W.", service: "HydraFacial", startTime: time(12), durationMinutes: 50, isFirstTime: false, note: nil, price: 199),
            Appointment(clientName: "Dani R.", service: "Neurotoxin", startTime: time(14), durationMinutes: 30, isFirstTime: false, note: "Running behind — rain expected.", price: 325),
            Appointment(clientName: "Reese O.", service: "Lip filler", startTime: time(15, 30), durationMinutes: 45, isFirstTime: false, note: nil, price: 725),
            Appointment(clientName: "Corey L.", service: "HydraFacial", startTime: time(17), durationMinutes: 50, isFirstTime: false, note: nil, price: 199),
        ],
        pendingCue: Cue(
            spokenText: "Priya S. is running 10 minutes late.",
            action: DetailAction(description: "Let her know you're running a few minutes behind too.")
        ),
        pendingThresholdProposal: Proposal(
            context: "This month — rebooking",
            spokenFraming: "Clients are drifting past your usual rebooking window — want me to text the ones who are due?",
            finding: "About $41K a year is sitting in that gap if the pattern holds — I've seen it for three months running.",
            options: [
                ThresholdOption(boundaryValue: 1, label: "Text them"),
                ThresholdOption(boundaryValue: 0, label: "Not yet"),
            ],
            threshold: Threshold(
                ruleStatement: "Flag clients who've drifted past their usual rebooking window.",
                boundaryValue: 45,
                unit: "days",
                confidence: .high,
                evidenceCount: 34
            )
        ),
        openings: [
            Opening(slotLabel: "Today 1:00 PM", durationMinutes: 30, estimatedValue: 325),
            Opening(slotLabel: "Today 4:30 PM", durationMinutes: 50, estimatedValue: 199),
        ],
        capabilityLimitationNote: nil,
        handledCount: 27,
        handledExamples: [
            "Rebooked Corey automatically off her usual six-week cadence",
            "Applied Maya's loyalty pricing without being asked",
            "Sent Dani's delay notice as soon as the rain forecast came in",
        ],
        unreadNotificationCount: 4,
        unreadMessageCount: 2
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

    /// The morning car-mode Brief Cue opens Home with — shown once per app
    /// launch, read aloud, then dismissed into the normal ranked Home
    /// sections. Rows and spoken line both come from the DETAIL/CUE
    /// prototype's own `d742` morning-drive screen.
    static let dailyBrief = DailyBrief(
        route: "CarPlay · I-65 South",
        greeting: "Morning, \(ownerFirstName).",
        rows: [
            DailyBriefRow(label: "Appointments today", value: "7"),
            DailyBriefRow(label: "Maya · first-time tox · referred by Dani", value: "11:00"),
            DailyBriefRow(label: "Open for 90 minutes", value: "2:30"),
            DailyBriefRow(label: "Rain after 3 · 4:15 may run late", value: "Watch"),
            DailyBriefRow(label: "Yesterday's consult", value: "Follow-up sent", isHighlighted: true),
        ],
        spokenText: "Morning. Seven today. Your 11:00 is Maya, first-time tox, referred by Dani. Intake's done, nothing flagged. You've got 90 minutes open at 2:30. Rain after 3, so your 4:15 may run late. That's it."
    )
}
