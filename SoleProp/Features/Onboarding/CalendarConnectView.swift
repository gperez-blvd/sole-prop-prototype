import SwiftUI

/// Read-only by design. Her personal calendar shapes the book; nothing
/// Boulevard does ever appears on it.
struct CalendarConnectView: View {
    var state: OnboardingState
    var onBack: () -> Void

    var body: some View {
        OnboardingScreen(primaryCTA: .init("Back to home", action: onBack)) {
            Text("Connect your calendar.")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.textPrimary)

            Text("Personal events block your book automatically. Cue reads busy or free, and never posts to it.")
                .font(Tokens.Typography.bodyRegular)
                .foregroundStyle(Tokens.Color.textSecondary)

            VStack(spacing: 10) {
                providerRow(name: "Google Calendar", subtitle: "jazz.bennett@gmail.com", isConnected: state.googleCalendarConnected) {
                    state.googleCalendarConnected = true
                }
                providerRow(name: "iCalendar", subtitle: "Apple Calendar, Outlook, or any .ics feed", isConnected: state.iCalConnected) {
                    state.iCalConnected = true
                }
            }

            Text("Connected calendars stay private. Cue only ever sees that a time is taken.")
                .font(.dmSans(13.5, weight: .regular))
                .foregroundStyle(Tokens.Color.textTertiary)
        }
    }

    private func providerRow(name: String, subtitle: String, isConnected: Bool, connect: @escaping () -> Void) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.dmSans(14, weight: .semibold))
                    .foregroundStyle(Tokens.Color.textPrimary)
                Text(subtitle)
                    .font(.dmSans(13.5, weight: .regular))
                    .foregroundStyle(Tokens.Color.textSecondary)
            }
            Spacer(minLength: 12)
            Button(action: connect) {
                Text(isConnected ? "Connected" : "Connect")
                    .font(.dmSans(13.5, weight: .semibold))
                    .padding(.horizontal, 13)
                    .padding(.vertical, 8)
            }
            .foregroundStyle(isConnected ? Tokens.Color.ochre : Tokens.Color.onPrimaryFill)
            .background(RoundedRectangle(cornerRadius: Tokens.Radius.button).fill(isConnected ? Color.clear : Tokens.Color.primaryFill))
            .overlay(RoundedRectangle(cornerRadius: Tokens.Radius.button).strokeBorder(isConnected ? Tokens.Color.ochre.opacity(0.5) : .clear, lineWidth: 1))
            .disabled(isConnected)
        }
        .cardStyle(padding: 12)
    }
}

#Preview {
    CalendarConnectView(state: OnboardingState(), onBack: {})
}
