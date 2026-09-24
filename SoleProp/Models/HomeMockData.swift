import Foundation

/// Static mock data backing the Home screen and the voice assistant's answers
/// until this is wired to real Boulevard data.
///
/// Everything below `currentStage` is read from `Dataset`, one per
/// `LifecycleStage`. The switch in the PROTOTYPE section of `MenuSheet`
/// changes `currentStage`; nothing here or upstream branches on it —
/// `dataset(for:)` is the one place that maps stage to seed data.
enum HomeMockData {
    static let ownerFirstName = "Jazz"
    static let businessName = "Jazz Aesthetics"

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
    static var dayStripSlots: [Bool] { dataset(for: currentStage).dayStripSlots }
    static var unreadNotificationCount: Int { dataset(for: currentStage).unreadNotificationCount }
    static var unreadMessageCount: Int { dataset(for: currentStage).unreadMessageCount }

    static var nextAppointment: Appointment? {
        let now = Date()
        let appointments = todaysAppointments
        return appointments.first { $0.startTime >= now } ?? appointments.first
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
        let dayStripSlots: [Bool]
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
    /// cohort priors rather than observed history.
    private static let activatingDataset = Dataset(
        appointments: [
            Appointment(clientName: "Maya N.", service: "Neurotoxin", startTime: time(11), durationMinutes: 30, isFirstTime: true, note: "Referred by Dani. Nervous about bruising.", price: 325),
            Appointment(clientName: "Priya S.", service: "Lip filler", startTime: time(13), durationMinutes: 45, isFirstTime: true, note: nil, price: 650),
            Appointment(clientName: "Dani R.", service: "Neurotoxin", startTime: time(15), durationMinutes: 30, isFirstTime: false, note: nil, price: 325),
        ],
        pendingCue: Cue(
            spokenText: "That's your 20th booked appointment this month.",
            action: DetailAction(description: "Noted the milestone — nothing you need to do.")
        ),
        pendingThresholdProposal: Proposal(
            context: "New client — Maya N.",
            spokenFraming: "I haven't seen how you handle first-timers yet — want me to flag every new client the way I just did, or only ones referred by someone?",
            finding: "Most solo injectors flag every new client at first and loosen it later, but you're the one this needs to fit — this is the first new client since I started watching.",
            options: [
                ThresholdOption(boundaryValue: 1, label: "Every new client"),
                ThresholdOption(boundaryValue: 0, label: "Referrals only"),
            ],
            threshold: Threshold(
                ruleStatement: "Flag new clients before their first appointment.",
                boundaryValue: 1,
                unit: "referral",
                confidence: .low,
                evidenceCount: 1
            )
        ),
        dayStripSlots: [false, true, false, false, false, true, false, false, false, true],
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
        dayStripSlots: [false, true, true, true, false, true, false, true, false, true],
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
        dayStripSlots: [true, true, true, true, false, true, true, true, false, true],
        unreadNotificationCount: 4,
        unreadMessageCount: 2
    )
}
