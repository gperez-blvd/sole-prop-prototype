import Foundation

struct Appointment: Identifiable, Hashable {
    let id = UUID()
    let clientName: String
    let service: String
    let startTime: Date
    let durationMinutes: Int
    let isFirstTime: Bool
    let note: String?

    var endTime: Date {
        startTime.addingTimeInterval(TimeInterval(durationMinutes * 60))
    }
}
