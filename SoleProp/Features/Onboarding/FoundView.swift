import SwiftUI

private struct FoundFact: Identifiable {
    let id = UUID()
    let text: String
    let source: String
    let isHighlighted: Bool
}

struct FoundView: View {
    var state: OnboardingState
    var onContinue: () -> Void

    @State private var visibleCount = 0

    private let facts = [
        FoundFact(text: "Jazz Aesthetics · Medical aesthetics", source: "Instagram", isHighlighted: false),
        FoundFact(text: "Logo, palette, brand voice", source: "Instagram", isHighlighted: false),
        FoundFact(text: "Suite 204 · Nashville, TN", source: "Google", isHighlighted: false),
        FoundFact(text: "Tue to Sat · 9 to 6", source: "Google", isHighlighted: false),
        FoundFact(text: "11 services with prices and durations", source: "Linktree", isHighlighted: false),
        FoundFact(text: "4.9 stars · 38 reviews", source: "Google", isHighlighted: false),
        FoundFact(text: "Tox, filler, laser: processing times and consent forms pre-built", source: "Boulevard", isHighlighted: true),
    ]

    var body: some View {
        OnboardingScreen(section: "Confirm") {
            Text("We found you, \(state.firstName).")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.textPrimary)

            VStack(spacing: 0) {
                ForEach(Array(facts.enumerated()), id: \.element.id) { index, fact in
                    factRow(fact)
                        .opacity(index < visibleCount ? 1 : 0)
                        .offset(y: index < visibleCount ? 0 : 6)
                }
            }

            microneedlingPrompt

            PillButton(title: "Looks right", action: onContinue)
                .padding(.top, Tokens.Spacing.md)
        }
        .task {
            for index in facts.indices {
                withAnimation(.easeOut(duration: 0.3)) {
                    visibleCount = index + 1
                }
                try? await Task.sleep(for: .milliseconds(110))
            }
        }
    }

    private func factRow(_ fact: FoundFact) -> some View {
        HStack(alignment: .top) {
            Text(fact.text)
                .font(.system(size: 13))
                .foregroundStyle(Tokens.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 12)
            TrackedLabel(text: fact.source, color: fact.isHighlighted ? Tokens.Color.ochre : Tokens.Color.textTertiary)
        }
        .padding(.vertical, 9)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
        }
    }

    private var microneedlingPrompt: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("One thing we couldn't find. Do you offer microneedling?")
                .font(.system(size: 13.5, weight: .medium))
                .foregroundStyle(Tokens.Color.textPrimary)
            HStack(spacing: 8) {
                ChoiceChip(title: "Yes", isSelected: state.microneedling == .yes) { state.microneedling = .yes }
                ChoiceChip(title: "No", isSelected: state.microneedling == .no) { state.microneedling = .no }
            }
        }
        .padding(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Tokens.Color.hairline, lineWidth: 1)
        )
    }
}

#Preview {
    FoundView(state: OnboardingState(), onContinue: {})
}
