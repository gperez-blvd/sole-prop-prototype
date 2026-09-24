import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: Tokens.Spacing.md) {
            Text("Sole Prop Prototype")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.textPrimary)

            Text("Screens will land here as reference material comes in.")
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
