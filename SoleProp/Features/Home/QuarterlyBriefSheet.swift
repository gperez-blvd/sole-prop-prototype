import SwiftUI

/// The quarterly recap popup — a slide-up sheet (not a full-screen push)
/// with an X close button, opened when Cue answers a "how have we been
/// doing the last 3 months?" request. Styled dark (onyx), matching the
/// DETAIL/CUE prototype's own Debrief/Week-in-review screens rather than
/// Home's light cards — this is a distinct "spoken report" moment.
struct QuarterlyBriefSheet: View {
    var brief: QuarterlyBrief
    var onSelectIdea: (GrowthIdea) -> Void
    var onClose: () -> Void

    @State private var selectedIdea: GrowthIdea?

    private var revenueText: String {
        brief.revenue.formatted(.currency(code: "USD").precision(.fractionLength(0)))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("You had a great 3 months.")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(Tokens.Color.paper)
                        Text("Here's a recap.")
                            .font(.system(size: 15))
                            .foregroundStyle(Tokens.Color.ink3)
                    }

                    HStack(spacing: 14) {
                        stat(value: revenueText, label: "Earned")
                        stat(value: "\(brief.clientsSeen)", label: "Clients seen")
                    }

                    VStack(spacing: 0) {
                        row(label: "New clients", value: "\(brief.newClients)", highlighted: true)
                        row(label: "New client ratio", value: brief.newClientFraction)
                    }

                    Text("Based on your ratings and reviews from those customers, I think we can safely say they're about to be your regulars!")
                        .font(.system(size: 13.5))
                        .foregroundStyle(Tokens.Color.ink3)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("I have a few ideas for next quarter. Which one would you like to hear more about?")
                            .font(.system(size: 13.5, weight: .medium))
                            .foregroundStyle(Tokens.Color.paper)

                        ForEach(brief.ideas) { idea in
                            ideaCard(idea)
                        }
                    }
                    .padding(.top, 6)
                }
                .padding(24)
            }
            .background(Tokens.Color.onyx)
            .navigationTitle("Quarterly Brief")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Tokens.Color.paper)
                    }
                }
            }
            .toolbarBackground(Tokens.Color.onyx, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private func stat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Tokens.Color.paper)
            Text(label.uppercased())
                .font(Tokens.Typography.labelSmall)
                .foregroundStyle(Tokens.Color.ink3)
                .kerning(1.2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func row(label: String, value: String, highlighted: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Tokens.Color.paper)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(highlighted ? Tokens.Color.ochre : Tokens.Color.paper)
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Tokens.Color.paper.opacity(0.13)).frame(height: 1)
        }
    }

    private func ideaCard(_ idea: GrowthIdea) -> some View {
        let isSelected = selectedIdea?.id == idea.id
        return Button {
            selectedIdea = idea
            onSelectIdea(idea)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(idea.title.uppercased())
                    .font(Tokens.Typography.labelSmall)
                    .foregroundStyle(Tokens.Color.ochre)
                    .kerning(1.2)
                Text(idea.teaser)
                    .font(.system(size: 13.5))
                    .foregroundStyle(Tokens.Color.paper)
                    .multilineTextAlignment(.leading)
                if isSelected {
                    Text(idea.elaboration)
                        .font(.system(size: 12.5))
                        .foregroundStyle(Tokens.Color.ink3)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
        }
        .buttonStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isSelected ? Tokens.Color.ochre.opacity(0.6) : Tokens.Color.paper.opacity(0.13), lineWidth: 1)
        )
    }
}

#Preview {
    QuarterlyBriefSheet(brief: HomeMockData.quarterlyBrief, onSelectIdea: { _ in }, onClose: {})
}
