import SwiftUI

/// The morning Brief — full-screen (not a sheet), shown once when Home
/// first appears each launch. Home's own content stays invisible
/// underneath until "Okay" is tapped, then this fades out while Home
/// animates in.
///
/// The orb here is a companion, not a control — it moves while Cue reads
/// the brief aloud (same `isSpeaking` motion as anywhere else Cue talks),
/// but isn't tappable. The point is to make this read as Cue actually
/// talking to her, not as the voice button sitting there idle.
struct DailyBriefView: View {
    @Environment(VoiceConversationViewModel.self) private var voiceAssistant

    var brief: DailyBrief
    var onContinue: () -> Void

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            Text("Start of day · \(Self.dateFormatter.string(from: Date()))")
                .font(Tokens.Typography.labelSmall)
                .foregroundStyle(Tokens.Color.textTertiary)
                .padding(.top, 8)

            HStack(alignment: .center, spacing: 12) {
                Text(brief.greeting)
                    .font(.dmSans(30, weight: .semibold))
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: 12)
                VoiceOrb(size: 44, level: voiceAssistant.orbLevel, isActive: voiceAssistant.orbIsActive)
            }

            HStack(spacing: 8) {
                Image(systemName: "car.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Tokens.Color.textTertiary)
                Text("Playing in \(brief.route)")
                    .font(Tokens.Typography.caption)
                    .foregroundStyle(Tokens.Color.textTertiary)
            }

            VStack(alignment: .leading, spacing: 22) {
                ForEach(brief.rows) { row in
                    briefRow(row)
                }
            }
            .padding(.top, 4)

            Spacer(minLength: 0)

            Button(action: onContinue) {
                Text("Okay")
                    .font(.dmSans(15, weight: .semibold))
                    .foregroundStyle(Tokens.Color.onPrimaryFill)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .background(RoundedRectangle(cornerRadius: Tokens.Radius.button).fill(Tokens.Color.primaryFill))
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Tokens.Color.background.ignoresSafeArea())
    }

    /// One consistent row shape regardless of what the item is — an icon
    /// to scan for, a label, a value — so the list stays legible as more
    /// (or more detailed) rows are added, rather than needing dividers to
    /// keep rows from running together.
    private func briefRow(_ row: DailyBriefRow) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: row.icon)
                .font(.system(size: 15))
                .foregroundStyle(row.isHighlighted ? Tokens.Color.ochre : Tokens.Color.textSecondary)
                .frame(width: 20, alignment: .center)
                .padding(.top, 1)

            Text(row.label)
                .font(Tokens.Typography.body)
                .foregroundStyle(Tokens.Color.textPrimary)

            Spacer(minLength: 8)

            Text(row.value)
                .font(Tokens.Typography.bodyRegular)
                .foregroundStyle(row.isHighlighted ? Tokens.Color.ochre : Tokens.Color.textSecondary)
        }
    }
}

#Preview {
    DailyBriefView(brief: HomeMockData.dailyBrief, onContinue: {})
        .environment(VoiceConversationViewModel())
}
