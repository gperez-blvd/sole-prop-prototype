import SwiftUI

struct HomeView: View {
    @Environment(Router.self) private var router

    @State private var showMenu = false
    @State private var selectedAppointment: Appointment?
    @State private var placeholderMessage: String?
    @State private var showTooltip = true

    var body: some View {
        ZStack {
            BUITokens.Color.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 32) {
                HomeHeaderBar(
                    businessName: HomeMockData.businessName,
                    onMenuTap: { showMenu = true },
                    onMessagesTap: { router.push(.messages) },
                    onNotificationsTap: { router.push(.notifications) }
                )

                Text("Good morning \(HomeMockData.ownerFirstName).")
                    .font(BUITokens.Typography.greeting)
                    .foregroundStyle(BUITokens.Color.textPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Next appointment")
                        .font(BUITokens.Typography.sectionLabel)
                        .foregroundStyle(BUITokens.Color.textStrong)

                    if let next = HomeMockData.nextAppointment {
                        NextAppointmentCard(
                            appointment: next,
                            onTap: { selectedAppointment = next },
                            onEdit: { placeholderMessage = "Edit — not designed yet." },
                            onClientInfo: { placeholderMessage = "Client info — not designed yet." },
                            onMessage: { placeholderMessage = "Message — not designed yet." }
                        )
                    }

                    DayStripCard(slots: HomeMockData.dayStripSlots) {
                        router.push(.schedule)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 28)
            .padding(.top, 19)

            VStack(spacing: 12) {
                if showTooltip {
                    VoiceOrbTooltip(text: "Tap to pull up conversation")
                }
                Button {
                    showTooltip = false
                    router.push(.voiceConversation)
                } label: {
                    VoiceOrb(size: 100)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 90)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showMenu) {
            MenuSheet { route in
                showMenu = false
                router.push(route)
            }
        }
        .sheet(item: $selectedAppointment) { appointment in
            AppointmentDetailSheet(appointment: appointment) {
                selectedAppointment = nil
            }
        }
        .alert("Not designed yet", isPresented: .constant(placeholderMessage != nil), presenting: placeholderMessage) { _ in
            Button("OK") { placeholderMessage = nil }
        } message: { message in
            Text(message)
        }
    }
}

private struct VoiceOrbTooltip: View {
    var text: String

    var body: some View {
        VStack(spacing: 0) {
            Text(text)
                .font(BUITokens.Typography.tooltip)
                .foregroundStyle(.white)
                .padding(8)
                .background(BUITokens.Color.contrastPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Triangle()
                .fill(BUITokens.Color.contrastPrimary)
                .frame(width: 12, height: 6)
        }
        .shadow(color: .black.opacity(0.22), radius: 24, x: 0, y: 16)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(Router())
}
