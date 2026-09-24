import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: Tokens.Spacing.md) {
            Text("You're live.")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.textPrimary)

            Text("Month 1 screens land here next.")
                .font(Tokens.Typography.body)
                .foregroundStyle(Tokens.Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Tokens.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Tokens.Color.background)
        .navigationTitle("Home")
    }
}

#Preview {
    HomeView()
}
