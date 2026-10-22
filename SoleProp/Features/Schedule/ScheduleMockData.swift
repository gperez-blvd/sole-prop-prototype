import Foundation

/// A deterministic week's worth of appointments for the Schedule view —
/// today uses the real `HomeMockData.todaysAppointments` (so Home and
/// Schedule agree), and the other six days in whatever week is being
/// looked at are filled from the same client/service pool `HomeMockData`
/// already seeds Home with, not a separate cast of characters. This
/// stays a small, self-contained generator rather than a second data
/// model — the real schedule data model is still `Appointment`.
enum ScheduleMockData {
    private struct Slot {
        let dayOffset: Int // from the week's Monday
        let clientName: String
        let service: String
        let hour: Int
        let minute: Int
        let durationMinutes: Int
        let price: Decimal
    }

    private static let slots: [Slot] = [
        Slot(dayOffset: 0, clientName: "Priya S.", service: "Lip filler", hour: 10, minute: 0, durationMinutes: 45, price: 650),
        Slot(dayOffset: 0, clientName: "Dani R.", service: "Neurotoxin", hour: 14, minute: 0, durationMinutes: 30, price: 325),
        Slot(dayOffset: 1, clientName: "Tasha W.", service: "HydraFacial", hour: 9, minute: 30, durationMinutes: 50, price: 199),
        Slot(dayOffset: 1, clientName: "Reese O.", service: "Lip filler", hour: 13, minute: 0, durationMinutes: 45, price: 725),
        Slot(dayOffset: 2, clientName: "Maya N.", service: "Neurotoxin", hour: 11, minute: 0, durationMinutes: 30, price: 325),
        Slot(dayOffset: 3, clientName: "Corey L.", service: "HydraFacial", hour: 10, minute: 30, durationMinutes: 50, price: 199),
        Slot(dayOffset: 3, clientName: "Dani R.", service: "Neurotoxin", hour: 15, minute: 30, durationMinutes: 30, price: 325),
        Slot(dayOffset: 4, clientName: "Priya S.", service: "Lip filler", hour: 9, minute: 0, durationMinutes: 45, price: 650),
        Slot(dayOffset: 4, clientName: "Tasha W.", service: "HydraFacial", hour: 12, minute: 30, durationMinutes: 50, price: 199),
        Slot(dayOffset: 4, clientName: "Maya N.", service: "Neurotoxin", hour: 16, minute: 0, durationMinutes: 30, price: 325),
        Slot(dayOffset: 5, clientName: "Reese O.", service: "Lip filler", hour: 11, minute: 30, durationMinutes: 45, price: 725),
    ]

    /// Everything booked on the calendar day containing `date` — today's
    /// real appointments if `date` falls on today, otherwise this
    /// generator's own seed for that weekday.
    static func appointments(on date: Date) -> [Appointment] {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return HomeMockData.todaysAppointments
        }

        let monday = startOfWeek(containing: date)
        guard let dayOffset = calendar.dateComponents([.day], from: monday, to: calendar.startOfDay(for: date)).day else {
            return []
        }

        return slots
            .filter { $0.dayOffset == dayOffset }
            .compactMap { slot in
                guard let startTime = calendar.date(bySettingHour: slot.hour, minute: slot.minute, second: 0, of: date) else { return nil }
                return Appointment(
                    clientName: slot.clientName,
                    service: slot.service,
                    startTime: startTime,
                    durationMinutes: slot.durationMinutes,
                    isFirstTime: false,
                    note: nil,
                    price: slot.price
                )
            }
    }

    /// Monday of the week containing `date` — weeks are drawn Monday
    /// through Sunday regardless of the device's own first-weekday
    /// setting, so the layout is predictable.
    static func startOfWeek(containing date: Date) -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return calendar.startOfDay(for: start)
    }
}
