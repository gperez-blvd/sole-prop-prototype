import SwiftUI

private struct Follower: Identifiable {
    let id = UUID()
    let initials: String
    let name: String
    let background: Color
    let foreground: Color
}

struct ClientsView: View {
    var state: OnboardingState
    var onContinue: () -> Void

    @State private var visibleAvatars = 0

    private let swatches: [(Color, Color)] = [
        (Color(hex: "#E4E4DE"), Color(hex: "#0A0A0A")),
        (Color(hex: "#C8AB7C"), Color(hex: "#0A0A0A")),
        (Color(hex: "#183E43"), Color(hex: "#F5F4F1")),
        (Color(hex: "#0A0A0A"), Color(hex: "#F5F4F1")),
        (Color(hex: "#D9BE8A"), Color(hex: "#0A0A0A")),
        (Color(hex: "#8A6F3F"), Color(hex: "#F5F4F1")),
        (Color(hex: "#5F5B53"), Color(hex: "#F5F4F1")),
    ]

    private let followerSeeds: [(String, String)] = [
        ("DR", "Dani R."), ("MN", "Maya N."), ("PS", "Priya S."), ("TW", "Tasha W."),
        ("LK", "Lena K."), ("MB", "Morgan B."), ("AJ", "Ava J."), ("RC", "Renee C."),
        ("KM", "Kiara M."), ("JT", "Jess T."), ("NP", "Nina P."), ("SR", "Sofia R."),
        ("BL", "Bree L."), ("CD", "Chloe D."), ("AG", "Alyssa G."), ("TH", "Tori H."),
        ("CF", "Camille F."), ("JO", "Jade O."),
    ]

    private var followers: [Follower] {
        followerSeeds.enumerated().map { index, seed in
            let swatch = swatches[index % swatches.count]
            return Follower(initials: seed.0, name: seed.1, background: swatch.0, foreground: swatch.1)
        }
    }

    var body: some View {
        OnboardingScreen(section: "Clients") {
            Text("Your clients")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.textPrimary)

            Text("Your Instagram followers have been imported as your starting client list! Have more to add?")
                .font(Tokens.Typography.bodyRegular)
                .foregroundStyle(Tokens.Color.textSecondary)

            instagramCard

            dropZone

            Text("Optional from here. You can be live without it.")
                .font(.system(size: 12))
                .foregroundStyle(Tokens.Color.textTertiary)

            Group {
                if state.clientsImported {
                    PillButton(title: "Continue", action: onContinue)
                } else {
                    PillButton(title: "Skip for now", style: .ghost, action: onContinue)
                }
            }
            .padding(.top, Tokens.Spacing.sm)
        }
        .task {
            for index in followers.indices {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    visibleAvatars = index + 1
                }
                try? await Task.sleep(for: .milliseconds(55))
            }
        }
    }

    private var instagramCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TrackedLabel(text: "\(state.instagram) · followers")
                Spacer()
                TrackedLabel(text: "2,140 imported")
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                ForEach(Array(followers.enumerated()), id: \.element.id) { index, follower in
                    avatar(follower)
                        .opacity(index < visibleAvatars ? 1 : 0)
                        .scaleEffect(index < visibleAvatars ? 1 : 0.6)
                }
            }

            HStack(spacing: 10) {
                HStack(spacing: -8) {
                    ForEach(followers.prefix(3)) { follower in
                        avatar(follower, size: 26)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
                Text("Dani, Maya, Priya and 2,137 others are in your client list.")
                    .font(.system(size: 12))
                    .foregroundStyle(Tokens.Color.textSecondary)
            }
        }
        .padding(12)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Tokens.Color.hairline, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func avatar(_ follower: Follower, size: CGFloat? = nil) -> some View {
        Circle()
            .fill(follower.background)
            .overlay(
                Text(follower.initials)
                    .font(.system(size: size != nil ? 9 : 11, weight: .semibold))
                    .foregroundStyle(follower.foreground)
            )
            .aspectRatio(1, contentMode: .fit)
            .frame(width: size, height: size)
    }

    private var dropZone: some View {
        Button {
            guard !state.clientsImported else { return }
            withAnimation(.easeOut(duration: 0.25)) {
                state.clientsImported = true
            }
        } label: {
            VStack(spacing: 8) {
                if state.clientsImported {
                    Text("Jazz_clients.csv")
                        .font(.system(size: 13.5, weight: .semibold))
                    Text("212 clients imported · 9 duplicates merged")
                        .font(.system(size: 13.5))
                } else {
                    Text("Upload a file from your device")
                        .font(.system(size: 13.5, weight: .semibold))
                    Text("CSV, spreadsheet, export, screenshots. We sort it out.")
                        .font(.system(size: 13.5))
                }
            }
            .foregroundStyle(Tokens.Color.textSecondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    Color.black.opacity(0.35),
                    style: StrokeStyle(lineWidth: 1, dash: state.clientsImported ? [] : [5, 4])
                )
        )
    }
}

#Preview {
    ClientsView(state: OnboardingState(), onContinue: {})
}
