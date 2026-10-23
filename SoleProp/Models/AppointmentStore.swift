import SwiftUI

/// The one place an appointment edit actually lives this session —
/// `HomeMockData`/`ScheduleMockData` stay pure, stateless seed data (every
/// other read site in the app still works unmodified); this store holds
/// just the cancellations and edits layered on top, keyed by the
/// appointment's own `id` so it survives being re-fetched fresh from
/// either data source. `HomeView`/`ScheduleView` call `resolve(_:)` on
/// whatever list they just fetched before rendering it, which is what
/// makes an edit made from one screen show up on the other — there's one
/// store, injected once at the app root, not two independent copies.
@Observable
final class AppointmentStore {
    private var overrides: [UUID: Appointment] = [:]
    private var cancelledIDs: Set<UUID> = []

    func update(_ appointment: Appointment) {
        overrides[appointment.id] = appointment
    }

    func cancel(_ appointment: Appointment) {
        cancelledIDs.insert(appointment.id)
        overrides.removeValue(forKey: appointment.id)
    }

    /// Cancelled appointments drop out entirely; edited ones are swapped
    /// in by `id`, keeping the caller's own ordering.
    func resolve(_ appointments: [Appointment]) -> [Appointment] {
        appointments
            .filter { !cancelledIDs.contains($0.id) }
            .map { overrides[$0.id] ?? $0 }
    }

    /// Called by the PROTOTYPE "Reset demo data" button — a demo reset
    /// should behave like starting fresh, not like "today, but with
    /// yesterday's edits still applied."
    func reset() {
        overrides.removeAll()
        cancelledIDs.removeAll()
    }
}
