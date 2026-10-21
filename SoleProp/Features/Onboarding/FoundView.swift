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
    /// True only while Cue would plausibly be narrating this page aloud
    /// (here: while the facts are still revealing one by one) — the orb
    /// next to the title is meant to appear only when the AI is actually
    /// speaking on a screen, not sit there permanently as decoration.
    @State private var isSpeaking = false

    /// Local-only edits from tapping a line below — a real build would
    /// write these back through `state`/a service call, but the point
    /// here is the affordance: these rows are not read-only chrome.
    @State private var overrides: [UUID: String] = [:]
    @State private var editingID: UUID?

    private let facts = [
        FoundFact(text: "273 posts · 2,000 followers · 5 highlights", source: "Instagram", isHighlighted: false),
        FoundFact(text: "Suite 204 · Nashville, TN", source: "Google", isHighlighted: false),
        FoundFact(text: "Tue to Sat · 9 to 6", source: "Google", isHighlighted: false),
        FoundFact(text: "11 services with prices and durations", source: "Linktree", isHighlighted: false),
        FoundFact(text: "4.9 stars · 38 reviews", source: "Google", isHighlighted: false),
        FoundFact(text: "Tox, filler, laser: processing times and consent forms pre-built", source: "Cue", isHighlighted: true),
    ]

    var body: some View {
        OnboardingScreen(primaryCTA: .init("Looks right", action: onContinue)) {
            HStack(spacing: 12) {
                Text("We found you, \(state.firstName).")
                    .font(Tokens.Typography.title)
                    .foregroundStyle(Tokens.Color.textPrimary)
                Spacer(minLength: 8)
                if isSpeaking {
                    VoiceOrb(size: 36, level: 0.4, isActive: true)
                        .transition(.opacity)
                }
            }

            brandCard

            VStack(spacing: 18) {
                ForEach(Array(facts.enumerated()), id: \.element.id) { index, fact in
                    factRow(fact)
                        .opacity(index < visibleCount ? 1 : 0)
                        .offset(y: index < visibleCount ? 0 : 6)
                }
            }

            Text("Tap any line to edit it.")
                .font(.dmSans(12.5, weight: .regular))
                .foregroundStyle(Tokens.Color.textTertiary)
        }
        .task {
            isSpeaking = true
            for index in facts.indices {
                withAnimation(.easeOut(duration: 0.3)) {
                    visibleCount = index + 1
                }
                try? await Task.sleep(for: .milliseconds(110))
            }
            withAnimation(.easeOut(duration: 0.3)) {
                isSpeaking = false
            }
        }
    }

    private var brandCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(Tokens.Color.primaryFill)
                    .frame(width: 52, height: 52)
                    .overlay(
                        Text(initials)
                            .font(.dmSans(15, weight: .semibold))
                            .foregroundStyle(Tokens.Color.onPrimaryFill)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(state.firstName) Aesthetics")
                        .font(.dmSans(14, weight: .semibold))
                        .foregroundStyle(Tokens.Color.textPrimary)
                    Text("Medical Spa · Aesthetic Injector")
                        .font(.dmSans(11.5, weight: .regular))
                        .foregroundStyle(Tokens.Color.textSecondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
            }

            VStack(alignment: .leading, spacing: 8) {
                brandDetailRow(icon: "mappin.and.ellipse", text: state.city)
                brandDetailRow(icon: "envelope", text: state.email)
            }
        }
        .cardStyle(padding: 14)
    }

    private func brandDetailRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(Tokens.Color.ochre)
                .frame(width: 16)
            Text(text)
                .font(.dmSans(12, weight: .regular))
                .foregroundStyle(Tokens.Color.textSecondary)
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

    private func factRow(_ fact: FoundFact) -> some View {
        let isEditing = editingID == fact.id

        return HStack(alignment: .center, spacing: 24) {
            if isEditing {
                TextField(
                    "",
                    text: Binding(
                        get: { overrides[fact.id] ?? fact.text },
                        set: { overrides[fact.id] = $0 }
                    )
                )
                .font(.dmSans(13, weight: .regular))
                .foregroundStyle(Tokens.Color.textPrimary)
                .textFieldStyle(.plain)
                .onSubmit { editingID = nil }
            } else {
                Text(overrides[fact.id] ?? fact.text)
                    .font(.dmSans(13, weight: .regular))
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            HStack(spacing: 6) {
                TrackedLabel(text: fact.source, color: fact.isHighlighted ? Tokens.Color.ochre : Tokens.Color.textTertiary)
                Image(systemName: isEditing ? "checkmark" : "pencil")
                    .font(.system(size: 10.5))
                    .foregroundStyle(Tokens.Color.textTertiary)
            }
            .frame(width: 96, alignment: .trailing)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            editingID = isEditing ? nil : fact.id
        }
    }
}

#Preview {
    FoundView(state: OnboardingState(), onContinue: {})
}
