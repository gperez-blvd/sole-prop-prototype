import SwiftUI

private struct SourceRowInfo {
    let source: ClientSource
    let title: String
    let subtitle: String
    let later: String?
    let count: Int
    let doneLabel: String
}

struct ClientsView: View {
    var state: OnboardingState
    var onContinue: () -> Void

    @State private var importing: Set<ClientSource> = []
    @State private var isRunning = false

    private let rows: [SourceRowInfo] = [
        SourceRowInfo(source: .instagram, title: "Import from Instagram followers", subtitle: "@jazzaesthetics · 2,000 followers", later: nil, count: 2_000, doneLabel: "2,000 imported"),
        SourceRowInfo(source: .contacts, title: "Import from contact list", subtitle: "Phone contacts · 368", later: nil, count: 368, doneLabel: "368 imported"),
        SourceRowInfo(source: .file, title: "Import from file on device", subtitle: "CSV, spreadsheet or export", later: "You can do this later too", count: 212, doneLabel: "212 imported · 9 merged"),
    ]

    private var anySelected: Bool { !state.selectedClientSources.isEmpty }
    private var doneImporting: Bool { state.clientsImportRun }

    var body: some View {
        OnboardingScreen(
            primaryCTA: doneImporting
                ? .init("Continue", action: onContinue)
                : .init(isRunning ? "Importing…" : "Import selected", isDisabled: !anySelected || isRunning, action: runImports),
            secondaryCTA: doneImporting ? nil : .init("Skip for now", style: .ghost, action: onContinue)
        ) {
            Text("Build your client list.")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.textPrimary)

            Text("Pick where your clients live today. Cue imports them in the background and merges duplicates.")
                .font(Tokens.Typography.bodyRegular)
                .foregroundStyle(Tokens.Color.textSecondary)

            VStack(spacing: 10) {
                ForEach(rows, id: \.source) { row in
                    sourceRow(row)
                }
            }
        }
    }

    private func sourceRow(_ row: SourceRowInfo) -> some View {
        let isSelected = state.selectedClientSources.contains(row.source)
        let isImported = state.importedClientSources.contains(row.source)
        let isImportingNow = importing.contains(row.source)

        return Button {
            guard !doneImporting, !isRunning else { return }
            if isSelected {
                state.selectedClientSources.remove(row.source)
            } else {
                state.selectedClientSources.insert(row.source)
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                RoundedRectangle(cornerRadius: 7)
                    .fill(isSelected ? Tokens.Color.primaryFill : Tokens.Color.surface)
                    .frame(width: 22, height: 22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .strokeBorder(isSelected ? Tokens.Color.textPrimary : Tokens.Color.textTertiary.opacity(0.5), lineWidth: 1.5)
                    )
                    .overlay {
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Tokens.Color.onPrimaryFill)
                        }
                    }
                    .padding(.top, 1)

                VStack(alignment: .leading, spacing: 3) {
                    Text(row.title)
                        .font(.dmSans(14, weight: .semibold))
                        .foregroundStyle(Tokens.Color.textPrimary)
                    Text(row.subtitle)
                        .font(.dmSans(13.5, weight: .regular))
                        .foregroundStyle(Tokens.Color.textSecondary)
                    if let later = row.later, !isImported {
                        Text(later)
                            .font(.dmSans(12.5, weight: .regular))
                            .italic()
                            .foregroundStyle(Tokens.Color.textTertiary)
                    }
                    if isImportingNow || isImported {
                        HStack {
                            TrackedLabel(
                                text: isImported ? row.doneLabel : "Importing…",
                                font: Tokens.Typography.labelSmall,
                                color: isImported ? Tokens.Color.ochre : Tokens.Color.textSecondary
                            )
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
        .disabled(doneImporting || isRunning)
        .cardStyle(padding: 12)
    }

    private func runImports() {
        guard anySelected, !isRunning else { return }
        isRunning = true
        Task {
            for row in rows where state.selectedClientSources.contains(row.source) {
                importing.insert(row.source)
                try? await Task.sleep(for: .milliseconds(700))
                state.importedClientSources.insert(row.source)
                importing.remove(row.source)
            }
            isRunning = false
            state.clientsImportRun = true
        }
    }
}

#Preview {
    ClientsView(state: OnboardingState(), onContinue: {})
}
