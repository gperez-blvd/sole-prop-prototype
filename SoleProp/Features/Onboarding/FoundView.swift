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
        FoundFact(text: "273 posts · 2,000 followers · 5 highlights", source: "Instagram", isHighlighted: false),
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

            brandCard

            VStack(spacing: 0) {
                ForEach(Array(facts.enumerated()), id: \.element.id) { index, fact in
                    factRow(fact)
                        .opacity(index < visibleCount ? 1 : 0)
                        .offset(y: index < visibleCount ? 0 : 6)
                }
            }

            Text("Anything to change? Tap a line. Otherwise you're set.")
                .font(.system(size: 12.5))
                .foregroundStyle(Tokens.Color.textTertiary)

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

    private var brandCard: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Tokens.Color.ink)
                .frame(width: 52, height: 52)
                .overlay(
                    Text(initials)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Tokens.Color.fog)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text("\(state.firstName) Aesthetics")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Tokens.Color.textPrimary)
                Text("Medical Spa · Aesthetic Injector · Music City, Nashville")
                    .font(.system(size: 11.5))
                    .foregroundStyle(Tokens.Color.textSecondary)
                HStack(spacing: 6) {
                    ForEach(["#142D1D", "#F5F0E8", "#0A0A0A"], id: \.self) { hex in
                        Circle()
                            .fill(Color(hex: hex))
                            .overlay(Circle().stroke(Color.black.opacity(0.15), lineWidth: 1))
                            .frame(width: 12, height: 12)
                    }
                    TrackedLabel(text: "from \(state.instagram)", font: Tokens.Typography.labelSmall)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Tokens.Color.hairline, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
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
}

#Preview {
    FoundView(state: OnboardingState(), onContinue: {})
}
