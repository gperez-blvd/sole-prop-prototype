import SwiftUI

/// A row of floating blocks, one per appointment today, in chronological
/// order — tap one to browse it in the card below without opening its
/// full detail sheet (that's still a tap on the card itself). Replaces
/// the earlier flat hour-status strip: that showed the day's shape but
/// did nothing when touched, where this is the same glanceable row made
/// genuinely interactive — which block is lifted is which appointment is
/// surfaced below, and the two always agree.
struct AppointmentBlocksRow: View {
    var appointments: [Appointment]
    var selected: Appointment?
    var onSelect: (Appointment) -> Void
    var onViewFullDay: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Appointments")
                .font(Tokens.Typography.label)
                .foregroundStyle(Tokens.Color.textTertiary)

            HStack(spacing: 0) {
                // Pills are as wide as "1:30 pm" needs, not a fixed
                // square, so a full day of appointments can run past
                // the screen's edge — a horizontal scroll lets them,
                // rather than squeezing every pill back down to fit.
                // Vertical padding here, not clipped flush to the
                // pills' own height, so the selected pill's 1.08x scale
                // has room to lift without its top/bottom getting cut.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(appointments) { appointment in
                            block(for: appointment)
                        }
                    }
                    .padding(.vertical, 6)
                }
                // A soft fade over the last stretch rather than a hard
                // edge — the row is visibly still a row of pills behind
                // "All", not a pill sliced off mid-shape.
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0),
                            .init(color: .black, location: 0.86),
                            .init(color: .clear, location: 1),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

                // Fixed at the end of the row rather than up in the
                // header — it's a continuation of the same scan (these
                // times, then the rest of them), not a separate action
                // competing for attention above it, and it stays put
                // while the pills themselves scroll.
                Button(action: onViewFullDay) {
                    HStack(spacing: 3) {
                        Text("All")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .font(Tokens.Typography.caption)
                    .foregroundStyle(Tokens.Color.textTertiary)
                }
                .buttonStyle(.plain)
                .fixedSize()
                .padding(.leading, 12)
                .zIndex(1)
            }
        }
    }

    private func block(for appointment: Appointment) -> some View {
        let isSelected = appointment.id == selected?.id

        return Button {
            onSelect(appointment)
        } label: {
            // A pill rather than a fixed-width square — "1:30 pm" needs
            // room the old hour-only square never had to make for, and
            // lowercase am/pm reads calmer than the system default's
            // caps here, same spirit as the rest of this screen's
            // sentence-case type.
            Text(timeLabel(for: appointment.startTime))
                .font(.dmSans(13, weight: .semibold))
                .foregroundStyle(isSelected ? Tokens.Color.onPrimaryFill : Tokens.Color.textSecondary)
                .fixedSize()
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(
                    isSelected ? Tokens.Color.primaryFill : Tokens.Color.accentTint,
                    in: Capsule()
                )
                // A real shadow under each block, not the flat, one
                // -card-wrapped look the old strip had — these should
                // read as individually liftable pieces to tap through,
                // and the selected one lifts a touch further than the
                // rest.
                .shadow(
                    color: Tokens.Shadow.low.color,
                    radius: isSelected ? Tokens.Shadow.medium.radius : Tokens.Shadow.low.radius,
                    y: isSelected ? Tokens.Shadow.medium.y : Tokens.Shadow.low.y
                )
                .scaleEffect(isSelected ? 1.08 : 1)
        }
        .buttonStyle(.plain)
        .animation(Tokens.Motion.quick, value: isSelected)
    }

    private func timeLabel(for date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened).lowercased()
    }
}

#Preview {
    @Previewable @State var selected = HomeMockData.todaysAppointments.first
    return AppointmentBlocksRow(
        appointments: HomeMockData.todaysAppointments,
        selected: selected,
        onSelect: { selected = $0 },
        onViewFullDay: {}
    )
    .padding(28)
    .background(Tokens.Color.background)
}
