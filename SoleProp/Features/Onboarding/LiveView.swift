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
            OnboardingScreen(section: "Home") {
                Circle()
                    .fill(Tokens.Color.ink)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(initials)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Tokens.Color.fog)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Secret Service is set up.")
                        .font(.system(size: 15))
                        .foregroundStyle(Tokens.Color.textSecondary)
                    Text("And we're live!")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(Tokens.Color.textPrimary)
                }

                Text("bookjazz.blvd.com")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Tokens.Color.textSecondary)

                VStack(spacing: 0) {
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
                .overlay(alignment: .bottom) {
                    Rectangle().fill(Color.black.opacity(0.13)).frame(height: 1)
                }

                VStack(spacing: 10) {
                    PillButton(
                        title: state.bookingLinkShared ? "Booking Link Shared" : "Share Your Booking Link",
                        isDisabled: state.bookingLinkShared
                    ) {
                        state.bookingLinkShared = true
                        showShareToast = true
                        Task {
                            try? await Task.sleep(for: .seconds(2.2))
                            showShareToast = false
                        }
                    }
                    PillButton(title: "Continue", style: .ghost, action: onContinue)
                }
                .padding(.top, Tokens.Spacing.sm)
            }

            ConfettiView(trigger: confettiTrigger)

            if showShareToast {
                VStack {
                    Spacer()
                    Text("Booking link texted to your imported clients.")
                        .font(.system(size: 13))
                        .foregroundStyle(Tokens.Color.fog)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Tokens.Color.ink)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.25), value: showShareToast)
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

    private func actionRow(title: String, subtitle: String, done: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Tokens.Color.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 11.5))
                        .foregroundStyle(Tokens.Color.textSecondary)
                }
                Spacer(minLength: 12)
                Text(done ? "✓" : "→")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(done ? Color(hex: "#8A6F3F") : Tokens.Color.textTertiary)
            }
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.black.opacity(0.13)).frame(height: 1)
        }
    }

    private var initials: String {
        state.name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
            .uppercased()
    }
}

#Preview {
    LiveView(state: OnboardingState(), onOpen: { _ in }, onContinue: {})
}
