import SwiftUI

/// The Clients list — answers "who is this, and when did I last see her?"
/// A name and her last visit per row, nothing to study: no tags, no spend,
/// no count of how many are on file. Most recently seen first, because the
/// person she's looking for is usually from this week; search finds anyone
/// else. Everything she might want beyond that is one tap in, on her page.
struct ClientListView: View {
    @Environment(Router.self) private var router
    @State private var query = ""

    private var clients: [ClientMemory] {
        let all = HomeMockData.clientDirectory
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return all }
        return all.filter { $0.fullName.localizedCaseInsensitiveContains(trimmed) }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(clients) { client in
                    Button {
                        router.push(.client(client))
                    } label: {
                        row(client)
                    }
                    .buttonStyle(.plain)
                }
                if clients.isEmpty {
                    Text("No one by that name.")
                        .font(Tokens.Typography.bodyRegular)
                        .foregroundStyle(Tokens.Color.textTertiary)
                        .padding(.vertical, 16)
                }
            }
            .padding(.horizontal, 24)
        }
        .background(Tokens.Color.background)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Name")
        .navigationTitle("Clients")
        .navigationBarTitleDisplayMode(.inline)
        .backIconButton { router.pop() }
    }

    private func row(_ client: ClientMemory) -> some View {
        HStack(spacing: 12) {
            InitialsAvatar(name: client.fullName, size: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(client.fullName)
                    .font(Tokens.Typography.body)
                    .foregroundStyle(Tokens.Color.textPrimary)
                Text(lastSeen(client))
                    .font(Tokens.Typography.caption)
                    .foregroundStyle(Tokens.Color.textTertiary)
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
        }
    }

    private func lastSeen(_ client: ClientMemory) -> String {
        guard let last = client.visits.first else { return "No visits yet" }
        let sameYear = Calendar.current.isDate(last.date, equalTo: Date(), toGranularity: .year)
        let date = sameYear
            ? last.date.formatted(.dateTime.month(.abbreviated).day())
            : last.date.formatted(.dateTime.month(.abbreviated).day().year())
        return "\(last.service) · \(date)"
    }
}

#Preview {
    NavigationStack {
        ClientListView()
    }
    .environment(Router())
}
