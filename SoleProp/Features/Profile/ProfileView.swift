import SwiftUI

/// Placeholder architecture for Profile / Settings — a header (who she
/// is, what shows on her booking page) over grouped static rows. No
/// functionality on the static rows: each one surfaces the same "not
/// designed yet" placeholder the rest of the app uses for unbuilt detail.
/// Appearance and the PROTOTYPE lifecycle switch are the two genuinely
/// working controls here — both moved from `MenuSheet`, which now stays
/// just its six real rows.
///
/// The "Wallet" section is where every wallet-related setting lives —
/// on purpose, not spread across the app. `WalletView` itself only ever
/// surfaces the things she'd touch often (balance, add/transfer funds,
/// activity); anything about *how* the wallet is configured (which bank
/// account, how fast transfers land, what a client can pay with) comes
/// to this settings screen instead, the same "settings comes to the
/// object, not the reverse" rule CLAUDE.md states for thresholds.
struct ProfileView: View {
    @Environment(Router.self) private var router
    @Environment(VoiceConversationViewModel.self) private var voiceAssistant
    @State private var placeholderMessage: String?

    private let sections: [(title: String, rows: [(icon: String, label: String)])] = [
        ("Business", [
            ("building.2", "Business profile"),
            ("scissors", "Services & pricing"),
        ]),
        // The baseline a wallet needs to actually operate — a bank
        // account to land payouts in, how quickly they land, and what a
        // client can pay with — kept to just those three rather than
        // Venmo's full settings surface (no split payments, no privacy
        // -per-transaction, no linked cards beyond what's needed to
        // accept payment). One section, not scattered across the app —
        // everything about the wallet lives here, next to the wallet.
        ("Wallet", [
            ("building.columns", "Bank account"),
            ("bolt", "Auto-transfer speed"),
            ("creditcard", "Accepted payment methods"),
        ]),
        ("Account", [
            ("bell", "Notification preferences"),
            ("lock", "Privacy & security"),
            ("questionmark.circle", "Help"),
        ]),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
                header

                AppearanceSection()

                ForEach(sections, id: \.title) { section in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(section.title)
                            .font(Tokens.Typography.label)
                            .foregroundStyle(Tokens.Color.textTertiary)
                            .padding(.bottom, 8)

                        ForEach(section.rows, id: \.label) { row in
                            settingsRow(row.icon, row.label)
                        }
                    }
                }

                signOutRow

                PrototypeLifecycleSection()
                    .padding(.top, Tokens.Spacing.md)
            }
            .padding(.horizontal, Tokens.Spacing.lg)
            .padding(.top, Tokens.Spacing.lg)
            .padding(.bottom, Tokens.Spacing.xl)
        }
        .background(Tokens.Color.background)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .backIconButton { router.pop() }
        .alert("Not designed yet", isPresented: .constant(placeholderMessage != nil), presenting: placeholderMessage) { _ in
            Button("OK") { placeholderMessage = nil }
        } message: { message in
            Text(message)
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Avatar(name: HomeMockData.ownerFirstName, size: 48)
            VStack(alignment: .leading, spacing: 2) {
                Text(HomeMockData.businessName)
                    .font(Tokens.Typography.title)
                    .foregroundStyle(Tokens.Color.textPrimary)
                Text(HomeMockData.bookingLink)
                    .font(Tokens.Typography.caption)
                    .foregroundStyle(Tokens.Color.textSecondary)
            }
            Spacer()
        }
    }

    private func settingsRow(_ icon: String, _ label: String) -> some View {
        Button {
            placeholderMessage = "\(label) — not designed yet."
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .frame(width: 24)
                Text(label)
                    .font(Tokens.Typography.body)
                    .foregroundStyle(Tokens.Color.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Tokens.Color.textTertiary)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .overlay(alignment: .bottom) {
                Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var signOutRow: some View {
        Button {
            placeholderMessage = "Signing out — not designed yet."
        } label: {
            Text("Log out")
                .font(Tokens.Typography.body)
                .foregroundStyle(Tokens.Color.alert)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .padding(.top, Tokens.Spacing.md)
    }
}

/// The one real (non-prototype) setting on this screen's upper half —
/// moved here from `MenuSheet`, which no longer carries it, since it's
/// genuinely a setting and belongs where settings live.
private struct AppearanceSection: View {
    @AppStorage("settings.appearance") private var appearanceRawValue = AppearanceSetting.dark.rawValue

    private var appearance: AppearanceSetting {
        AppearanceSetting(rawValue: appearanceRawValue) ?? .system
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Appearance")
                .font(Tokens.Typography.label)
                .foregroundStyle(Tokens.Color.textTertiary)

            Picker("Appearance", selection: $appearanceRawValue) {
                ForEach(AppearanceSetting.allCases) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

/// A demo-only control, deliberately out of character with the rest of the
/// app — see CLAUDE.md's note on this being the one surface exempt from its
/// "never show object names or counts" rule. Its audience is whoever is
/// running the demo, not Jazz, so it says so plainly: monospace, bordered,
/// no editorial warmth. Moved here from `MenuSheet` so that menu could stay
/// just its six real rows — this is genuinely a setting, so it belongs on
/// the settings screen, not surfaced every time the hamburger menu opens.
/// Switching stages swaps `HomeMockData`'s seed data — it never branches
/// any layout — and pops back to Home, since `RootView` keys the whole
/// Home stack on the current stage.
private struct PrototypeLifecycleSection: View {
    @Environment(VoiceConversationViewModel.self) private var voiceAssistant
    @Environment(AppointmentStore.self) private var appointmentStore
    @AppStorage("prototype.lifecycleStage") private var stageRawValue = LifecycleStage.steady.rawValue
    // Same key RootView keys the Home stack's `.id()` on — bumping this
    // forces a full reseed/rebuild even when `stageRawValue` itself isn't
    // changing (e.g. resetting while already on "Steady").
    @AppStorage("prototype.resetToken") private var resetToken = 0
    // Clearing this makes Home's morning brief replay on the next
    // launch, the same as a genuinely fresh install would — a demo
    // reset should look like "starting fresh," not like "still today."
    @AppStorage("dailyBrief.lastShownDate") private var lastDailyBriefDate = ""

    private var stage: LifecycleStage {
        LifecycleStage(rawValue: stageRawValue) ?? .steady
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PROTOTYPE")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(Tokens.Color.textSecondary)
                .kerning(1.2)

            Picker("Lifecycle stage", selection: $stageRawValue) {
                ForEach(LifecycleStage.allCases) { option in
                    Text(option.stageName).tag(option.rawValue)
                }
            }
            .pickerStyle(.segmented)

            Text("\"\(stage.deckPhrase)\"")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(Tokens.Color.textSecondary)

            VStack(alignment: .leading, spacing: 6) {
                readoutRow("SIGNALS/DAY", \.signalsPerDay)
                readoutRow("CUES SPOKEN", \.cuesSpoken)
                readoutRow("THRESHOLDS", \.thresholdCount)
                readoutRow("KNOWLEDGE", \.knowledgeLevel)
            }
            .padding(.top, 4)

            Button(action: resetData) {
                Text("Reset demo data")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Tokens.Color.alert)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.sm)
                    .strokeBorder(Tokens.Color.alert.opacity(0.5))
            )
            .padding(.top, 8)
        }
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(Tokens.Color.textTertiary, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
        )
    }

    /// Back to "Steady" and a fresh seed, every time — not a toggle, so
    /// it reliably undoes whatever state got into during a run-through
    /// (dismissed cues, booked appointments, a stale Cue transcript)
    /// regardless of which stage it's currently on.
    private func resetData() {
        voiceAssistant.resetConversation()
        appointmentStore.reset()
        stageRawValue = LifecycleStage.steady.rawValue
        lastDailyBriefDate = ""
        resetToken += 1
    }

    @ViewBuilder
    private func readoutRow(_ label: String, _ value: KeyPath<LifecycleStage, Int>) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(Tokens.Color.textTertiary)
                .frame(width: 90, alignment: .leading)

            HStack(spacing: 4) {
                ForEach(Array(LifecycleStage.allCases.enumerated()), id: \.offset) { index, option in
                    if index > 0 {
                        Text("→")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(Tokens.Color.textTertiary)
                    }
                    Text("\(option[keyPath: value])")
                        .font(.system(size: 11, weight: option == stage ? .bold : .regular, design: .monospaced))
                        .foregroundStyle(option == stage ? Tokens.Color.textPrimary : Tokens.Color.textTertiary)
                        .underline(option == stage)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environment(Router())
    .environment(VoiceConversationViewModel())
    .environment(AppointmentStore())
}
