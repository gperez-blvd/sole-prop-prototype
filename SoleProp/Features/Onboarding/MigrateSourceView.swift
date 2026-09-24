import SwiftUI

private struct Provider: Identifiable {
    let id: String
    let name: String
    let data: String
}

/// Same four beats as Boulevard's self-serve migration flow, sized for one
/// operator on a phone: Source, Connect, Extract, Done. One tap on the system
/// moves her straight to sign-in.
struct MigrateSourceView: View {
    var state: OnboardingState
    var onPicked: () -> Void
    var onBack: () -> Void

    private let providers: [Provider] = [
        Provider(id: "Zenoti", name: "Zenoti", data: "Clients, appointments, memberships, gift cards"),
        Provider(id: "Vagaro", name: "Vagaro", data: "Clients, appointments, gift cards, memberships"),
        Provider(id: "Mindbody", name: "Mindbody", data: "Clients, appointments, memberships"),
        Provider(id: "Booker", name: "Booker", data: "Clients, appointments, memberships"),
        Provider(id: "Booksy", name: "Booksy", data: "Clients, appointments, reviews"),
        Provider(id: "DaySmart Salon", name: "DaySmart Salon", data: "Clients, appointments, gift cards"),
        Provider(id: "Aesthetic Record", name: "Aesthetic Record", data: "Clients, charts, consents, photos"),
        Provider(id: "AestheticsPro", name: "AestheticsPro", data: "Clients, charts, consents, photos"),
    ]

    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        OnboardingScreen(section: "Bring data") {
            Text("Where does your history live?")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.textPrimary)

            Text("Pick the system you use now. Boulevard brings your clients, appointments and history over while your booking link stays live.")
                .font(Tokens.Typography.bodyRegular)
                .foregroundStyle(Tokens.Color.textSecondary)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(providers) { provider in
                    tile(provider)
                }
            }

            PillButton(title: "Back to home", style: .ghost, action: onBack)
                .padding(.top, Tokens.Spacing.md)
        }
    }

    private func tile(_ provider: Provider) -> some View {
        let isSelected = state.migrationProvider == provider.id
        return Button {
            state.migrationProvider = provider.id
            Task {
                try? await Task.sleep(for: .milliseconds(260))
                onPicked()
            }
        } label: {
            VStack(alignment: .leading, spacing: 7) {
                Text(provider.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Tokens.Color.textPrimary)
                Text(provider.data)
                    .font(.system(size: 10.5))
                    .foregroundStyle(Tokens.Color.textSecondary)
                HStack(spacing: 6) {
                    Circle().fill(Color(hex: "#8A6F3F")).frame(width: 6, height: 6)
                    TrackedLabel(text: "Instant import", font: Tokens.Typography.labelSmall, color: Color(hex: "#8A6F3F"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
        .buttonStyle(.plain)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isSelected ? Tokens.Color.ink : Tokens.Color.hairline, lineWidth: isSelected ? 1.5 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    MigrateSourceView(state: OnboardingState(), onPicked: {}, onBack: {})
}
