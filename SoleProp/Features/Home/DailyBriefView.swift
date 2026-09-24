import SwiftUI

/// The morning car-mode Brief — full-screen (not a sheet), shown once when
/// Home first appears each launch. Home's own content stays invisible
/// underneath until "Okay" is tapped, then this fades out while Home
/// animates in. Styled dark (onyx), matching the DETAIL/CUE prototype's own
/// CarPlay Brief screen.
struct DailyBriefView: View {
    var brief: DailyBrief
    var onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Boulevard")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Tokens.Color.paper)
                Spacer()
                TrackedLabel(text: "Brief", color: Tokens.Color.ink3)
            }
            .padding(.top, 8)

            HStack(spacing: 8) {
                Rectangle().fill(Tokens.Color.ochre).frame(width: 16, height: 1)
                TrackedLabel(text: brief.route, color: Tokens.Color.ochre)
            }

            Text(brief.greeting)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Tokens.Color.paper)

            TrackedLabel(text: "Playing in car · 0:28", color: Tokens.Color.ochre)
                .padding(.top, -8)

            VStack(spacing: 0) {
                ForEach(brief.rows) { row in
                    HStack(alignment: .top) {
                        Text(row.label)
                            .font(.system(size: 14.5))
                            .foregroundStyle(Tokens.Color.paper)
                        Spacer(minLength: 12)
                        Text(row.value)
                            .font(.system(size: 14.5, design: .monospaced))
                            .foregroundStyle(row.isHighlighted ? Tokens.Color.ochre : Tokens.Color.ink3)
                    }
                    .padding(.vertical, 12)
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(Tokens.Color.paper.opacity(0.13)).frame(height: 1)
                    }
                }
            }

            Spacer(minLength: 0)

            Button(action: onContinue) {
                Text("Okay")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Tokens.Color.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .background(Capsule().fill(Tokens.Color.paper))
        }
        .padding(24)
        .padding(.top, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Tokens.Color.onyx.ignoresSafeArea())
    }
}

#Preview {
    DailyBriefView(brief: HomeMockData.dailyBrief, onContinue: {})
}
