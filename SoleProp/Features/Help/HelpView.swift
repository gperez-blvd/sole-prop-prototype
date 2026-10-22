import SwiftUI

/// Placeholder architecture for Help — a short list of likely questions
/// over one "message us" row, not the same row skeleton as the other
/// lists on purpose: this isn't a feed of items, it's a small set of
/// doors into support. No functionality: every row surfaces the same
/// "not designed yet" placeholder the rest of the app uses.
struct HelpView: View {
    @Environment(Router.self) private var router
    @State private var placeholderMessage: String?

    private let questions = [
        "How do I change what DETAIL handles on its own?",
        "How do payouts work?",
        "Can I undo something DETAIL did?",
        "How do I update my services or pricing?",
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(questions, id: \.self) { question in
                        questionRow(question)
                    }
                }

                messageUsRow
            }
            .padding(.horizontal, Tokens.Spacing.lg)
            .padding(.top, Tokens.Spacing.lg)
        }
        .background(Tokens.Color.background)
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
        .backIconButton { router.pop() }
        .alert("Not designed yet", isPresented: .constant(placeholderMessage != nil), presenting: placeholderMessage) { _ in
            Button("OK") { placeholderMessage = nil }
        } message: { message in
            Text(message)
        }
    }

    private func questionRow(_ question: String) -> some View {
        Button {
            placeholderMessage = "This answer — not designed yet."
        } label: {
            HStack(spacing: 12) {
                Text(question)
                    .font(Tokens.Typography.body)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Tokens.Color.textTertiary)
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            .overlay(alignment: .bottom) {
                Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var messageUsRow: some View {
        Button {
            placeholderMessage = "Messaging support — not designed yet."
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "message")
                    .font(.system(size: 14, weight: .medium))
                Text("Message us")
                    .font(Tokens.Typography.button)
            }
            .foregroundStyle(Tokens.Color.onPrimaryFill)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Tokens.Color.primaryFill, in: RoundedRectangle(cornerRadius: Tokens.Radius.button))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        HelpView()
    }
    .environment(Router())
}
