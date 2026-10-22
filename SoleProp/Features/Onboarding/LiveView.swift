import SwiftUI

/// Home. A short list of things worth doing, not a dashboard — book someone
/// from the list Boulevard already built, connect a calendar, bring history
/// from the last system. Each row is a door; nothing here suggests she ought
/// to open it.
struct LiveView: View {
    var state: OnboardingState
    var onOpen: (OnboardingStep) -> Void
    var onContinue: () -> Void

    @State private var confettiTrigger = false
    @State private var showShareToast = false

    var body: some View {
        ZStack {
            OnboardingScreen(
                primaryCTA: .init(
                    state.bookingLinkShared ? "Booking link shared" : "Share your booking link",
                    isDisabled: state.bookingLinkShared,
                    action: shareBookingLink
                ),
                secondaryCTA: .init("Continue", style: .ghost, action: onContinue)
            ) {
                Avatar(name: state.name, size: 44)

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your secret service is set up.")
                            .font(.dmSans(16, weight: .regular))
                            .foregroundStyle(Tokens.Color.textSecondary)
                        Text("And we're live!")
                            .font(Tokens.Typography.largeTitle)
                            .foregroundStyle(Tokens.Color.textPrimary)
                    }
                    Spacer(minLength: 12)
                    // Same spot as the Daily Brief's "Morning, Jazz."
                    // row — next to the title, right-aligned — so the
                    // orb's placement reads as one consistent pattern
                    // rather than screen-specific.
                    VoiceOrb(size: 44)
                }

                Text("bookjazz.blvd.com")
                    .font(.dmSans(14, weight: .regular))
                    .foregroundStyle(Tokens.Color.textSecondary)

                VStack(spacing: 10) {
                    actionRow(
                        title: "Book an appointment",
                        subtitle: bookSubtitle,
                        done: !state.bookedAppointments.isEmpty
                    ) { onOpen(.book) }
                    actionRow(
                        title: "Connect your calendar",
                        subtitle: calSubtitle,
                        done: state.googleCalendarConnected || state.iCalConnected
                    ) { onOpen(.cal) }
                    actionRow(
                        title: "Bring data from somewhere else",
                        subtitle: migrateSubtitle,
                        done: state.migrationDone
                    ) { onOpen(state.migrationDone ? .migrateDone : .migrate) }
                }
            }

            ConfettiView(trigger: confettiTrigger)

            if showShareToast {
                VStack {
                    Spacer()
                    Text("Booking link texted to your imported clients.")
                        .font(.dmSans(14, weight: .regular))
                        .foregroundStyle(Tokens.Color.onPrimaryFill)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Tokens.Color.primaryFill)
                        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.card))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(Tokens.Motion.quick, value: showShareToast)
        .onAppear {
            guard !state.helloSpoken else { return }
            state.helloSpoken = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                confettiTrigger = true
            }
        }
    }

    private var bookSubtitle: String {
        if let last = state.bookedAppointments.last {
            return "\(state.bookedAppointments.count) booked today · \(last)"
        }
        return "For any of the \(state.clientCount.formatted()) clients already in your list."
    }

    private var calSubtitle: String {
        switch (state.googleCalendarConnected, state.iCalConnected) {
        case (true, true): return "Google Calendar and iCalendar connected"
        case (true, false): return "Google Calendar connected · add iCalendar"
        case (false, true): return "iCalendar connected · add Google Calendar"
        case (false, false): return "Google Calendar or iCalendar. Personal events block your book."
        }
    }

    private var migrateSubtitle: String {
        if state.migrationDone {
            return "\(state.migrationProvider ?? "Your old system") · clients, appointments and history imported"
        } else if state.migrationProvider != nil {
            return "Import in progress"
        }
        return "Clients, appointments and history from your last system."
    }

    private func shareBookingLink() {
        state.bookingLinkShared = true
        showShareToast = true
        Task {
            try? await Task.sleep(for: .seconds(2.2))
            showShareToast = false
        }
    }

    private func actionRow(title: String, subtitle: String, done: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.dmSans(14, weight: .semibold))
                        .foregroundStyle(Tokens.Color.textPrimary)
                    Text(subtitle)
                        .font(.dmSans(14, weight: .regular))
                        .foregroundStyle(Tokens.Color.textSecondary)
                }
                Spacer(minLength: 12)
                Text(done ? "✓" : "→")
                    .font(.dmSans(14, weight: .semibold))
                    .foregroundStyle(done ? Tokens.Color.accentText : Tokens.Color.textTertiary)
            }
        }
        .buttonStyle(.plain)
        .cardStyle(padding: 12)
    }

}

#Preview {
    LiveView(state: OnboardingState(), onOpen: { _ in }, onContinue: {})
}
