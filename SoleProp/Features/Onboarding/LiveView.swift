import SwiftUI

private struct Stat: Identifiable {
    let id = UUID()
    let value: String
    let label: String
}

struct LiveView: View {
    var state: OnboardingState
    var onContinue: () -> Void

    @State private var confettiTrigger = false

    private var services: [(String, String)] {
        var rows = [
            ("Neurotoxin", "30 min · from $13/unit"),
            ("Lip filler", "45 min · $650"),
            ("HydraFacial", "50 min · $199"),
        ]
        if state.microneedling == .yes {
            rows.append(("Microneedling", "45 min · $300"))
        }
        return rows
    }

    private let stats = [
        Stat(value: "3", label: "Asked"),
        Stat(value: "47", label: "Found"),
        Stat(value: "6", label: "Taps"),
        Stat(value: "4 min", label: "To live"),
    ]

    var body: some View {
        ZStack {
            OnboardingScreen(section: "Live") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Secret Service is set up.")
                        .font(.system(size: 15))
                        .foregroundStyle(Tokens.Color.textSecondary)
                    Text("And we're live!")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(Tokens.Color.textPrimary)
                }

                businessCard

                statsRow

                Text("Payouts connect when your first card runs. Bookings don't wait.")
                    .font(.system(size: 12))
                    .foregroundStyle(Tokens.Color.textTertiary)

                VStack(spacing: 10) {
                    PillButton(
                        title: state.bookingLinkShared ? "Booking Link Shared" : "Share Your Booking Link",
                        isDisabled: state.bookingLinkShared
                    ) {
                        state.bookingLinkShared = true
                    }
                    PillButton(title: "Continue", style: .ghost, action: onContinue)
                }
                .padding(.top, Tokens.Spacing.sm)
            }

            ConfettiView(trigger: confettiTrigger)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                confettiTrigger = true
            }
        }
    }

    private var businessCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Tokens.Color.ink)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(initials)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Tokens.Color.fog)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(state.firstName) Aesthetics")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Tokens.Color.textPrimary)
                    Text("book.blvd.co/jazz")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Tokens.Color.textSecondary)
                }
            }

            VStack(spacing: 0) {
                ForEach(services, id: \.0) { service in
                    HStack {
                        Text(service.0)
                            .font(.system(size: 13))
                            .foregroundStyle(Tokens.Color.textPrimary)
                        Spacer()
                        Text(service.1)
                            .font(.system(size: 11.5, design: .monospaced))
                            .foregroundStyle(Tokens.Color.textSecondary)
                    }
                    .padding(.vertical, 10)
                    .overlay(alignment: .top) {
                        Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
                    }
                }
            }
        }
        .padding(14)
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Tokens.Color.hairline, lineWidth: 1))
    }

    private var statsRow: some View {
        HStack(spacing: 8) {
            ForEach(stats) { stat in
                VStack(alignment: .leading, spacing: 5) {
                    Text(stat.value)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Tokens.Color.textPrimary)
                    TrackedLabel(text: stat.label, font: Tokens.Typography.labelSmall)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.top, 10)
        .overlay(alignment: .top) {
            Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
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
    LiveView(state: OnboardingState(), onContinue: {})
}
