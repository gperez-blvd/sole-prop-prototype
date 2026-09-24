import SwiftUI

/// Read-only by design. Her personal calendar shapes the book; nothing
/// Boulevard does ever appears on it.
struct CalendarConnectView: View {
    var state: OnboardingState
    var onBack: () -> Void

    var body: some View {
        OnboardingScreen(section: "Calendar") {
            Text("Connect your calendar.")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.textPrimary)

            Text("Personal events block your book automatically. Boulevard reads busy or free, and never posts to it.")
                .font(Tokens.Typography.bodyRegular)
                .foregroundStyle(Tokens.Color.textSecondary)

            VStack(spacing: 0) {
                providerRow(name: "Google Calendar", subtitle: "jazz.bennett@gmail.com", isConnected: state.googleCalendarConnected) {
                    state.googleCalendarConnected = true
                }
                providerRow(name: "iCalendar", subtitle: "Apple Calendar, Outlook, or any .ics feed", isConnected: state.iCalConnected) {
                    state.iCalConnected = true
                }
            }

            Text("Connected calendars stay private. CUE only ever sees that a time is taken.")
                .font(.system(size: 12.5))
                .foregroundStyle(Tokens.Color.textTertiary)

            PillButton(title: "Back to home", action: onBack)
                .padding(.top, Tokens.Spacing.md)
        }
    }

    private func providerRow(name: String, subtitle: String, isConnected: Bool, connect: @escaping () -> Void) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Tokens.Color.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Tokens.Color.textSecondary)
            }
            Spacer(minLength: 12)
            Button(action: connect) {
                Text(isConnected ? "Connected" : "Connect")
                    .font(.system(size: 12.5, weight: .semibold))
                    .padding(.horizontal, 13)
                    .padding(.vertical, 8)
            }
            .foregroundStyle(isConnected ? Tokens.Color.ink : Tokens.Color.fog)
            .background(Capsule().fill(isConnected ? Color.clear : Tokens.Color.ink))
            .overlay(Capsule().strokeBorder(isConnected ? Tokens.Color.ink : .clear, lineWidth: 1))
            .disabled(isConnected)
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
        }
    }
}

#Preview {
    CalendarConnectView(state: OnboardingState(), onBack: {})
}
