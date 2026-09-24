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
}
