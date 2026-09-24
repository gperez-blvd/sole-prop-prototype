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
        OnboardingScreen(section: "Clients") {
            Text("Build your client list.")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.textPrimary)

            Text("Pick where your clients live today. Boulevard imports them in the background and merges duplicates.")
                .font(Tokens.Typography.bodyRegular)
                .foregroundStyle(Tokens.Color.textSecondary)

            VStack(spacing: 0) {
                ForEach(rows, id: \.source) { row in
                    sourceRow(row)
                }
            }

            Group {
                if doneImporting {
                    PillButton(title: "Continue", action: onContinue)
                } else {
                    VStack(spacing: 10) {
                        PillButton(
                            title: isRunning ? "Importing…" : "Import selected",
                            isDisabled: !anySelected || isRunning
                        ) {
                            runImports()
                        }
                        PillButton(title: "Skip for now", style: .ghost, action: onContinue)
                    }
                }
            }
            .padding(.top, Tokens.Spacing.sm)
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
                    .fill(isSelected ? Tokens.Color.ink : Color.white)
                    .frame(width: 22, height: 22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .strokeBorder(isSelected ? Tokens.Color.ink : Color.black.opacity(0.35), lineWidth: 1.5)
                    )
                    .overlay {
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Tokens.Color.fog)
                        }
                    }
                    .padding(.top, 1)

                VStack(alignment: .leading, spacing: 3) {
                    Text(row.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Tokens.Color.textPrimary)
                    Text(row.subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Tokens.Color.textSecondary)
                    if let later = row.later, !isImported {
                        Text(later)
                            .font(.system(size: 11))
                            .italic()
                            .foregroundStyle(Tokens.Color.textTertiary)
                    }
                    if isImportingNow || isImported {
                        HStack {
                            TrackedLabel(
                                text: isImported ? row.doneLabel : "Importing…",
                                font: Tokens.Typography.labelSmall,
                                color: isImported ? Color(hex: "#8A6F3F") : Tokens.Color.textSecondary
                            )
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .disabled(doneImporting || isRunning)
        .overlay(alignment: .top) {
            Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            if row.source == rows.last?.source {
                Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
            }
        }
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
