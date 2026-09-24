import SwiftUI

private struct MenuItem: Identifiable {
    let route: Route
    let title: String
    let icon: String

    var id: Route { route }

    init(_ route: Route, _ title: String, _ icon: String) {
        self.route = route
        self.title = title
        self.icon = icon
    }
}

/// The top-left menu — a sheet listing the six top-level destinations, none of
/// which have real designs yet (see `PlaceholderScreen`). Selecting one
/// dismisses the sheet and pushes onto the root `NavigationStack`.
///
/// Also carries the PROTOTYPE section at the bottom — the lifecycle-stage
/// switch. That section is deliberately out of character with everything
/// above it; see `PrototypeLifecycleSection`.
struct MenuSheet: View {
    var onSelect: (Route) -> Void

    private let items: [MenuItem] = [
        MenuItem(.profile, "Profile / Settings", "person.circle"),
        MenuItem(.clients, "Clients", "person.2"),
        MenuItem(.schedule, "Schedule", "calendar"),
        MenuItem(.wallet, "Wallet", "wallet.pass"),
        MenuItem(.logs, "Logs", "list.bullet.rectangle"),
        MenuItem(.help, "Help", "questionmark.circle"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(items) { item in
                    Button {
                        onSelect(item.route)
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: item.icon)
                                .font(.system(size: 17))
                                .frame(width: 24)
                            Text(item.title)
                                .font(.system(size: 15, weight: .medium))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Tokens.Color.textTertiary)
                        }
                        .foregroundStyle(Tokens.Color.textPrimary)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                    }
                    .buttonStyle(.plain)

                    if item.route != items.last?.route {
                        Divider().padding(.leading, 24)
                    }
                }

                PrototypeLifecycleSection()
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .padding(.top, 24)
        .background(Tokens.Color.background)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

/// A demo-only control, deliberately out of character with the rest of the
/// app — see CLAUDE.md's note on this being the one surface exempt from its
/// "never show object names or counts" rule. Its audience is whoever is
/// running the demo, not Jazz, so it says so plainly: monospace, bordered,
/// no editorial warmth. Switching stages swaps `HomeMockData`'s seed data —
/// it never branches any layout — and pops back to Home, since `RootView`
/// keys the whole Home stack on the current stage.
private struct PrototypeLifecycleSection: View {
    @AppStorage("prototype.lifecycleStage") private var stageRawValue = LifecycleStage.steady.rawValue

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
        }
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(Tokens.Color.textTertiary, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
        )
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
