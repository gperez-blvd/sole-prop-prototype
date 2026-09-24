import SwiftUI

private struct ExtractRow: Identifiable {
    let id = UUID()
    let count: String
    let detail: String
    let flagged: Bool
}

/// The backend job, made visible. Everything Boulevard finds appears as it is
/// found, so the wait reads as progress instead of a spinner.
struct MigrateExtractView: View {
    var state: OnboardingState
    var onDone: () -> Void

    @State private var visibleCount = 0
    @State private var finished = false

    private var providerName: String { state.migrationProvider ?? "your old system" }

    private let items: [ExtractRow] = [
        ExtractRow(count: "Connected", detail: "read-only", flagged: false),
        ExtractRow(count: "1 location", detail: "Nashville", flagged: false),
        ExtractRow(count: "1,284 clients", detail: "412 new", flagged: false),
        ExtractRow(count: "13 services", detail: "11 matched · 2 new", flagged: true),
        ExtractRow(count: "3,912 past appointments", detail: "3 years", flagged: false),
        ExtractRow(count: "131 upcoming appointments", detail: "6 weeks", flagged: false),
        ExtractRow(count: "9 open gift cards", detail: "$1,150", flagged: false),
        ExtractRow(count: "6 active packages", detail: "14 sessions left", flagged: false),
        ExtractRow(count: "3,640 chart notes", detail: "1,284 consents", flagged: false),
        ExtractRow(count: "2,210 photos", detail: "", flagged: false),
        ExtractRow(count: "3 items need your review", detail: "", flagged: true),
    ]

    var body: some View {
        OnboardingScreen(section: "Import") {
            Text("Bringing your history into Boulevard.")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.textPrimary)

            Text("Reading your \(providerName) account. Everything shows up here as we find it.")
                .font(Tokens.Typography.bodyRegular)
                .foregroundStyle(Tokens.Color.textSecondary)

            HStack {
                TrackedLabel(text: finished ? "Extraction complete" : "Reading your \(providerName) account", font: Tokens.Typography.labelSmall)
                Spacer()
                TrackedLabel(text: "\(progressPercent)%", font: Tokens.Typography.labelSmall)
            }
            .padding(.top, Tokens.Spacing.sm)

            GeometryReader { geo in
                Capsule()
                    .fill(Tokens.Color.silt)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(Tokens.Color.ink)
                            .frame(width: geo.size.width * CGFloat(progressPercent) / 100)
                    }
            }
            .frame(height: 3)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    if index < visibleCount {
                        extractRow(item)
                    }
                }
            }

            if finished {
                PillButton(title: "See what came over", action: onDone)
                    .padding(.top, Tokens.Spacing.md)
            }
        }
        .task {
            for index in items.indices {
                try? await Task.sleep(for: .milliseconds(500))
                withAnimation(.easeOut(duration: 0.3)) {
                    visibleCount = index + 1
                }
            }
            state.migrationExtracted = true
            finished = true
        }
    }

    private var progressPercent: Int {
        guard !items.isEmpty else { return 0 }
        return Int((Double(visibleCount) / Double(items.count)) * 100)
    }

    private func extractRow(_ item: ExtractRow) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(item.count)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(item.flagged ? Color(hex: "#8A6F3F") : Tokens.Color.textPrimary)
            Spacer(minLength: 10)
            Text(item.detail)
                .font(.system(size: 12.5))
                .foregroundStyle(Tokens.Color.textSecondary)
        }
        .padding(.vertical, 9)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
        }
    }
}

#Preview {
    let state = OnboardingState()
    state.migrationProvider = "Vagaro"
    return MigrateExtractView(state: state, onDone: {})
}
