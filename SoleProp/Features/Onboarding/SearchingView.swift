import SwiftUI

private struct SearchSource: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
}

struct SearchingView: View {
    var state: OnboardingState
    var onContinue: () -> Void

    @State private var activeIndex = -1
    @State private var doneIndices: Set<Int> = []

    private let sources = [
        SearchSource(name: "Instagram", detail: "@jazzaesthetics"),
        SearchSource(name: "Google Business", detail: "Address, hours, reviews"),
        SearchSource(name: "Linktree booking page", detail: "Services, prices, durations"),
        SearchSource(name: "Cue knowledge", detail: "Processing times, consent forms"),
    ]

    private let stepDuration: Duration = .milliseconds(900)

    var body: some View {
        OnboardingScreen(primaryCTA: .init("Finding your business…", isDisabled: true, action: {})) {
            Text("Looking for \(state.firstName) Aesthetics…")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.textPrimary)

            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(sources.enumerated()), id: \.element.id) { index, source in
                    sourceRow(source, index: index)
                }
            }
        }
        .task {
            await runSearch()
        }
    }

    private func sourceRow(_ source: SearchSource, index: Int) -> some View {
        let isOn = index == activeIndex
        let isDone = doneIndices.contains(index)

        return HStack(spacing: 12) {
            Circle()
                .fill(isDone ? Tokens.Color.ochre : (isOn ? Tokens.Color.primaryFill : Color.clear))
                .overlay(Circle().stroke(Tokens.Color.textTertiary, lineWidth: 1))
                .frame(width: 8, height: 8)
                .scaleEffect(isOn ? 1.4 : 1)
                .animation(isOn ? .easeInOut(duration: 0.9).repeatForever(autoreverses: true) : .default, value: isOn)

            VStack(alignment: .leading, spacing: 2) {
                Text(source.name)
                    .font(.dmSans(13.5, weight: .semibold))
                Text(source.detail)
                    .font(.dmSans(13.5, weight: .regular))
            }
            .foregroundStyle(isOn || isDone ? Tokens.Color.textPrimary : Tokens.Color.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func runSearch() async {
        for index in sources.indices {
            activeIndex = index
            try? await Task.sleep(for: stepDuration)
            doneIndices.insert(index)
        }
        activeIndex = -1
        try? await Task.sleep(for: .milliseconds(400))
        onContinue()
    }
}

#Preview {
    SearchingView(state: OnboardingState(), onContinue: {})
}
