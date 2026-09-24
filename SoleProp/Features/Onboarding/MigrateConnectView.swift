import SwiftUI

/// Credentials, once. The connection is read-only and the password is
/// discarded the moment the session opens.
struct MigrateConnectView: View {
    var state: OnboardingState
    var onConnected: () -> Void

    @State private var password: String = ""
    @State private var isConnecting = false

    private var providerName: String { state.migrationProvider ?? "your old system" }
    private let whatComesOver = ["Clients and visit history", "Services and pricing", "Gift cards and packages", "Upcoming appointments"]

    var body: some View {
        OnboardingScreen(section: "Connect") {
            Text("Connect your \(providerName) account.")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.textPrimary)

            Text("Sign in the way you always do. Boulevard opens a secure, read-only connection. Nothing in your \(providerName) account changes.")
                .font(Tokens.Typography.bodyRegular)
                .foregroundStyle(Tokens.Color.textSecondary)

            VStack(spacing: 0) {
                OnboardingField(label: "Email", text: .constant("jazz@jazzaesthetics.com"), keyboardType: .emailAddress)
                OnboardingField(label: "Password", text: $password, textContentType: .password)
            }

            Text("We never store your password. It's used once to open the connection, then discarded.")
                .font(.system(size: 12))
                .foregroundStyle(Tokens.Color.textSecondary)

            TrackedLabel(text: "What comes over")
                .padding(.top, Tokens.Spacing.sm)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(whatComesOver, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("✓")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(Tokens.Color.textPrimary)
                        Text(item)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Tokens.Color.textPrimary)
                    }
                }
            }
            .padding(.top, 6)

            PillButton(
                title: isConnecting ? "Connecting…" : "Connect securely",
                isDisabled: password.isEmpty || isConnecting
            ) {
                connect()
            }
            .padding(.top, Tokens.Spacing.md)
        }
    }

    private func connect() {
        guard !password.isEmpty, !isConnecting else { return }
        isConnecting = true
        Task {
            try? await Task.sleep(for: .milliseconds(900))
            state.migrationConnected = true
            onConnected()
        }
    }
}

#Preview {
    let state = OnboardingState()
    state.migrationProvider = "Vagaro"
    return MigrateConnectView(state: state, onConnected: {})
}
