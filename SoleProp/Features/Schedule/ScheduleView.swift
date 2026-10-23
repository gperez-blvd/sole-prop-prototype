import SwiftUI

/// The real Schedule — a day and a week view of the same appointments
/// Home already surfaces a glimpse of, using the same design system
/// (tokens, `AppointmentDetailSheet`, `.backIconButton`) as every other
/// screen. Scoped deliberately narrow for now: look at a day or a week,
/// swipe or tap the arrows to move between them, tap a block to see its
/// details. Nothing else — no editing, no creating, no drag-to-reschedule.
struct ScheduleView: View {
    @Environment(Router.self) private var router

    private enum Mode: String, CaseIterable {
        case day = "Day"
        case week = "Week"
    }

    @State private var mode: Mode = .day
    @State private var anchorDate = Calendar.current.startOfDay(for: Date())
    @State private var selectedAppointment: Appointment?

    /// 8am through 7pm — covers every seed appointment with a little
    /// room on either side, without scrolling through the dead of night.
    private let hours = Array(8...19)
    private let hourHeight: CGFloat = 64

    var body: some View {
        VStack(spacing: 0) {
            header

            Group {
                if mode == .day {
                    DayTimelineView(date: anchorDate, hours: hours, hourHeight: hourHeight, onSelect: { selectedAppointment = $0 })
                } else {
                    WeekTimelineView(weekStart: ScheduleMockData.startOfWeek(containing: anchorDate), onSelect: { selectedAppointment = $0 })
                }
            }
            // Horizontal-dominant drags cycle the date; anything more
            // vertical than horizontal passes through to the timeline's
            // own scrolling untouched (same guard used on Home's
            // swipe-to-dismiss cards, for the same reason).
            .simultaneousGesture(
                DragGesture(minimumDistance: 24)
                    .onEnded { value in
                        guard abs(value.translation.width) > abs(value.translation.height) else { return }
                        shift(value.translation.width < 0 ? 1 : -1)
                    }
            )
        }
        .background(Tokens.Color.background)
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .backIconButton { router.pop() }
        .sheet(item: $selectedAppointment) { appointment in
            AppointmentDetailSheet(appointment: appointment) {
                selectedAppointment = nil
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                navButton("chevron.left") { shift(-1) }
                Spacer()
                Text(dateRangeLabel)
                    .font(Tokens.Typography.title)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .contentTransition(.opacity)
                Spacer()
                navButton("chevron.right") { shift(1) }
            }

            SegmentedToggle(options: Mode.allCases, selection: $mode)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }

    private func navButton(_ systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Tokens.Color.textPrimary)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
    }

    private var dateRangeLabel: String {
        switch mode {
        case .day:
            return anchorDate.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
        case .week:
            let start = ScheduleMockData.startOfWeek(containing: anchorDate)
            let end = Calendar.current.date(byAdding: .day, value: 6, to: start) ?? start
            return "\(start.formatted(.dateTime.month(.abbreviated).day())) – \(end.formatted(.dateTime.month(.abbreviated).day()))"
        }
    }

    private func shift(_ direction: Int) {
        let amount = mode == .day ? direction : direction * 7
        guard let newDate = Calendar.current.date(byAdding: .day, value: amount, to: anchorDate) else { return }
        withAnimation(Tokens.Motion.standard) { anchorDate = newDate }
    }
}

// MARK: - Day

/// A single day's hour-by-hour timeline — the standard calendar-app
/// shape: a time gutter on the left, a line per hour, appointment blocks
/// positioned and sized by their real start time and duration.
private struct DayTimelineView: View {
    var date: Date
    var hours: [Int]
    var hourHeight: CGFloat
    var onSelect: (Appointment) -> Void

    private let gutterWidth: CGFloat = 52

    private var appointments: [Appointment] { ScheduleMockData.appointments(on: date) }

    var body: some View {
        ScrollView {
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    HourGrid(hours: hours, hourHeight: hourHeight, gutterWidth: gutterWidth)

                    ForEach(appointments) { appointment in
                        AppointmentBlock(appointment: appointment) { onSelect(appointment) }
                            .frame(width: max(geo.size.width - gutterWidth - 16, 40), height: blockHeight(appointment), alignment: .topLeading)
                            .offset(x: gutterWidth, y: topOffset(appointment))
                    }
                }
            }
            .frame(height: CGFloat(hours.count) * hourHeight)
            .padding(.vertical, 8)
        }
    }

    private func topOffset(_ appointment: Appointment) -> CGFloat {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: appointment.startTime)
        let minute = calendar.component(.minute, from: appointment.startTime)
        guard let first = hours.first else { return 0 }
        return CGFloat(hour - first) * hourHeight + CGFloat(minute) / 60 * hourHeight
    }

    private func blockHeight(_ appointment: Appointment) -> CGFloat {
        max(hourHeight * 0.42, CGFloat(appointment.durationMinutes) / 60 * hourHeight - 2)
    }
}

/// The hour-line backdrop a day's appointment blocks sit on top of.
private struct HourGrid: View {
    var hours: [Int]
    var hourHeight: CGFloat
    var gutterWidth: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            ForEach(hours, id: \.self) { hour in
                HStack(alignment: .top, spacing: 8) {
                    Text(label(for: hour))
                        .font(Tokens.Typography.labelSmall)
                        .foregroundStyle(Tokens.Color.textTertiary)
                        .frame(width: gutterWidth - 8, alignment: .trailing)
                        .offset(y: -6)
                    Rectangle()
                        .fill(Tokens.Color.hairline)
                        .frame(height: 1)
                }
                .frame(height: hourHeight, alignment: .top)
            }
        }
    }

    private func label(for hour: Int) -> String {
        let twelveHour = hour % 12 == 0 ? 12 : hour % 12
        return "\(twelveHour) \(hour < 12 ? "AM" : "PM")"
    }
}

/// A tappable appointment card, sized to its own time slot — the one
/// shared block both the day and week views tap to open the same
/// `AppointmentDetailSheet`.
private struct AppointmentBlock: View {
    var appointment: Appointment
    /// Week's columns are too narrow for client/service text — just the
    /// colored block reads there; day has the room to say who and what.
    var showsDetails: Bool = true
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 1) {
                if showsDetails {
                    Text(appointment.clientName)
                        .font(Tokens.Typography.caption)
                        .foregroundStyle(Tokens.Color.textPrimary)
                        .lineLimit(1)
                    Text(appointment.service)
                        .font(Tokens.Typography.labelSmall)
                        .foregroundStyle(Tokens.Color.textSecondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.vertical, showsDetails ? 6 : 0)
            .padding(.leading, showsDetails ? 10 : 0)
        }
        .buttonStyle(.plain)
        .background(Tokens.Color.accentTint)
        .overlay(alignment: .leading) {
            Rectangle().fill(Tokens.Color.ochre).frame(width: 3)
        }
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.sm))
    }
}

// MARK: - Week

/// Seven day-columns sharing one scroll — each column is a simple,
/// time-ordered stack of blocks rather than the day view's precise
/// hour-grid positioning. At week width there isn't room to show time
/// -of-day geometrically anyway; a glanceable "here's roughly how full
/// each day is" is the right amount of detail for this level, same as
/// `AppointmentBlocksRow`'s own blocks on Home.
private struct WeekTimelineView: View {
    var weekStart: Date
    var onSelect: (Appointment) -> Void

    private var days: [Date] {
        (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: weekStart) }
    }

    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 8) {
                ForEach(days, id: \.self) { day in
                    dayColumn(day)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }

    private func dayColumn(_ day: Date) -> some View {
        let isToday = Calendar.current.isDateInToday(day)
        let appointments = ScheduleMockData.appointments(on: day).sorted { $0.startTime < $1.startTime }

        return VStack(spacing: 8) {
            VStack(spacing: 2) {
                Text(day.formatted(.dateTime.weekday(.narrow)))
                    .font(Tokens.Typography.labelSmall)
                    .foregroundStyle(Tokens.Color.textTertiary)
                Text(day.formatted(.dateTime.day()))
                    .font(Tokens.Typography.body)
                    .foregroundStyle(isToday ? Tokens.Color.onPrimaryFill : Tokens.Color.textPrimary)
                    .frame(width: 26, height: 26)
                    .background(isToday ? Tokens.Color.primaryFill : Color.clear, in: Circle())
            }

            VStack(spacing: 4) {
                ForEach(appointments) { appointment in
                    AppointmentBlock(appointment: appointment, showsDetails: false) {
                        onSelect(appointment)
                    }
                    .frame(height: 22)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        ScheduleView()
    }
    .environment(Router())
}
