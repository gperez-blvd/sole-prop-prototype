import SwiftUI

/// Her one real job in week one — a share-ready link to the booking page,
/// pulled forward on Home while there isn't much else on the day yet.
struct BookingLinkCard: View {
    var link: String

    private var shareURL: URL? { URL(string: "https://\(link)") }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Your booking link")
                    .font(Tokens.Typography.label)
                    .foregroundStyle(Tokens.Color.textTertiary)
                    .textCase(.uppercase)
                    .kerning(1.2)
                Text(link)
                    .font(Tokens.Typography.body)
                    .foregroundStyle(Tokens.Color.textPrimary)
            }

            Spacer()

            if let shareURL {
                ShareLink(item: shareURL) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Tokens.Color.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(Tokens.Color.fog)
                        .clipShape(Circle())
                }
            }
        }
        .padding(16)
        .background(Tokens.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.card)
                .strokeBorder(Tokens.Color.hairline)
        )
    }
}

#Preview {
    BookingLinkCard(link: HomeMockData.bookingLink)
        .padding(28)
        .background(Tokens.Color.background)
}
