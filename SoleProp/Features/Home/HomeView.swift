import SwiftUI

struct HomeView: View {
    @Environment(Router.self) private var router

    @State private var showMenu = false
    @State private var selectedAppointment: Appointment?
    @State private var placeholderMessage: String?
    @State private var showTooltip = true
    @State private var pendingProposal = HomeMockData.pendingThresholdProposal

    private static let todayDateString: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: Date())
    }()

    var body: some View {
        ZStack {
            Tokens.Color.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 32) {
                HomeHeaderBar(
                    businessName: HomeMockData.businessName,
                    onMenuTap: { showMenu = true },
                    onMessagesTap: { router.push(.messages) },
                    onNotificationsTap: { router.push(.notifications) }
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Good morning \(HomeMockData.ownerFirstName).")
                        .font(Tokens.Typography.largeTitle)
                        .foregroundStyle(Tokens.Color.textPrimary)
                    Text(Self.todayDateString)
                        .font(Tokens.Typography.labelSmall)
                        .foregroundStyle(Tokens.Color.textTertiary)
                        .textCase(.uppercase)
                        .kerning(1.2)
                }

                if let proposal = pendingProposal {
                    ThresholdProposalCard(
                        proposal: proposal,
                        onAccept: { _ in withAnimation { pendingProposal = nil } },
                        onDecline: { withAnimation { pendingProposal = nil } }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Next appointment")
                        .font(Tokens.Typography.label)
                        .foregroundStyle(Tokens.Color.textTertiary)
                        .textCase(.uppercase)
                        .kerning(1.4)

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
                    VoiceOrb(size: 44)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 28)
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
                .font(Tokens.Typography.bodyRegular)
                .foregroundStyle(Tokens.Color.paper)
                .padding(8)
                .background(Tokens.Color.onyx)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Triangle()
                .fill(Tokens.Color.onyx)
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
