import SwiftUI

struct HomeView: View {
    @Environment(Router.self) private var router
    @Environment(VoiceConversationViewModel.self) private var voiceAssistant

    @State private var showMenu = false
    @State private var selectedAppointment: Appointment?
    @State private var checkoutAppointment: Appointment?
    @State private var checkoutRecommendation: RecommendedItem?
    @State private var placeholderMessage: String?
    @State private var currentMoment = HomeMockData.pendingCue.map { DetailMoment.cue($0) }

    private static let todayDateString: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: Date())
    }()

    var body: some View {
        ZStack {
            BUITokens.Color.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    HomeHeaderBar(
                        businessName: HomeMockData.businessName,
                        onMenuTap: { showMenu = true },
                        onMessagesTap: { router.push(.messages) },
                        onNotificationsTap: { router.push(.notifications) }
                    )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Good morning \(HomeMockData.ownerFirstName).")
                            .font(BUITokens.Typography.greeting)
                            .foregroundStyle(BUITokens.Color.textPrimary)
                        Text(Self.todayDateString)
                            .font(.system(size: 10))
                            .foregroundStyle(BUITokens.Color.textStrong)
                    }

                    if let moment = currentMoment {
                        Group {
                            switch moment {
                            case .cue(let cue):
                                CueCard(cue: cue) {
                                    withAnimation {
                                        currentMoment = HomeMockData.pendingThresholdProposal.map { .proposal($0) }
                                    }
                                }
                                .id("cue")
                            case .proposal(let proposal):
                                ThresholdProposalCard(
                                    proposal: proposal,
                                    onAccept: { _ in withAnimation { currentMoment = nil } },
                                    onDecline: { withAnimation { currentMoment = nil } }
                                )
                                .id("proposal")
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

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
                                onMessage: { placeholderMessage = "Message — not designed yet." },
                                onCheckout: {
                                    checkoutRecommendation = nil
                                    checkoutAppointment = next
                                }
                            )
                        }

                        DayStripCard(slots: HomeMockData.dayStripSlots) {
                            router.push(.schedule)
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 19)
                // Reserves room below the last card for the fixed orb
                // overlay, so scrolled content never sits underneath it.
                .padding(.bottom, 120)
            }

            VoiceOrb(level: voiceAssistant.audioLevel, isActive: voiceAssistant.isListening)
                .contentShape(Circle())
                .onTapGesture {
                    voiceAssistant.toggleListening()
                }
                .onLongPressGesture(minimumDuration: 0.4) {
                    router.push(.voiceConversation)
                }
                .padding(.bottom, 12)
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
        .sheet(item: $checkoutAppointment) { appointment in
            CheckoutSheet(appointment: appointment, recommendation: checkoutRecommendation) {
                checkoutAppointment = nil
                checkoutRecommendation = nil
            }
        }
        .onChange(of: voiceAssistant.pendingCheckout) { _, newValue in
            guard let newValue else { return }
            checkoutRecommendation = voiceAssistant.pendingCheckoutRecommendation
            checkoutAppointment = newValue
            voiceAssistant.pendingCheckout = nil
            voiceAssistant.pendingCheckoutRecommendation = nil
        }
        .alert("Not designed yet", isPresented: .constant(placeholderMessage != nil), presenting: placeholderMessage) { _ in
            Button("OK") { placeholderMessage = nil }
        } message: { message in
            Text(message)
        }
        .alert("Cue", isPresented: .constant(voiceAssistant.errorMessage != nil), presenting: voiceAssistant.errorMessage) { _ in
            Button("OK") { voiceAssistant.errorMessage = nil }
        } message: { message in
            Text(message)
        }
    }
}

/// The sequence of things DETAIL surfaces in one moment: the CUE first,
/// then — because it's still learning — the PROPOSAL that follows from it.
private enum DetailMoment {
    case cue(Cue)
    case proposal(Proposal)
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(Router())
    .environment(VoiceConversationViewModel())
}
