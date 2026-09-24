import SwiftUI

/// Home is a DAY detail page, force-ranked. Every section below renders
/// from the same components regardless of how thin or full the day is —
/// what changes is which sections exist and where they land, both derived
/// from real counts (`appointmentWeight` and friends), never from
/// `HomeMockData.currentStage` directly. A near-empty day surfaces the
/// pending decision, the booking link and DETAIL's honest capability
/// limitation near the top on their own, simply because there isn't much
/// of a caseload to outrank them yet.
struct HomeView: View {
    @Environment(Router.self) private var router
    @Environment(VoiceConversationViewModel.self) private var voiceAssistant

    @State private var showMenu = false
    @State private var selectedAppointment: Appointment?
    @State private var checkoutAppointment: Appointment?
    @State private var checkoutRecommendation: RecommendedItem?
    @State private var showQuarterlyBrief = false
    @State private var placeholderMessage: String?
    @State private var currentMoment = HomeMockData.pendingCue.map { DetailMoment.cue($0) }
    /// Shown once per app launch before any of Home's own content — see
    /// `homeContent`/`DailyBriefView`.
    @State private var showDailyBrief = true

    private static let todayDateString: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: Date())
    }()

    var body: some View {
        ZStack {
            Tokens.Color.background.ignoresSafeArea()

            homeContent
                .opacity(showDailyBrief ? 0 : 1)
                .scaleEffect(showDailyBrief ? 0.96 : 1)
                .allowsHitTesting(!showDailyBrief)

            if showDailyBrief {
                DailyBriefView(brief: HomeMockData.dailyBrief) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showDailyBrief = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .onAppear {
            if showDailyBrief {
                voiceAssistant.announceDailyBrief(HomeMockData.dailyBrief)
            }
        }
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private var homeContent: some View {
        ZStack {
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
                            .font(Tokens.Typography.largeTitle)
                            .foregroundStyle(Tokens.Color.textPrimary)
                        Text(Self.todayDateString)
                            .font(Tokens.Typography.labelSmall)
                            .foregroundStyle(Tokens.Color.textTertiary)
                            .textCase(.uppercase)
                            .kerning(1.2)
                    }

                    ForEach(rankedSections) { section in
                        sectionView(section)
                            .transition(.opacity)
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
        .sheet(isPresented: $showQuarterlyBrief) {
            QuarterlyBriefSheet(
                brief: HomeMockData.quarterlyBrief,
                onSelectIdea: { idea in voiceAssistant.elaborate(on: idea) },
                onClose: { showQuarterlyBrief = false }
            )
        }
        .onChange(of: voiceAssistant.pendingQuarterlyBrief) { _, newValue in
            guard newValue else { return }
            showQuarterlyBrief = true
            voiceAssistant.pendingQuarterlyBrief = false
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

    // MARK: - Ranking

    /// The sections that have something to show, in force-ranked order.
    /// `appointments` is weighted by how many appointments actually exist
    /// today — the one real density signal here — and everything else is a
    /// fixed tier relative to that. On a thin day (few appointments) the
    /// pending decision, the booking link and the capability note outrank
    /// appointments on their own; on a full day appointments retake the
    /// lead and the quieter, lower-tier sections (openings, handled) round
    /// out the bottom. No section is ever chosen or ordered by stage.
    private var rankedSections: [HomeSection] {
        var weights: [(HomeSection, Int)] = []

        let appointmentCount = HomeMockData.todaysAppointments.count
        if appointmentCount > 0 {
            weights.append((.appointments, appointmentCount * 10))
        }
        if currentMoment != nil {
            weights.append((.decision, 35))
        }
        // Her one real job in week one is getting bookings, so the link
        // only earns a seat while the day itself hasn't filled in — the
        // same density signal `.appointments` is weighted by, not a stage.
        let isThinDay = appointmentCount < 4
        if isThinDay {
            weights.append((.bookingLink, 32))
        }
        if HomeMockData.capabilityLimitationNote != nil {
            weights.append((.capabilityNote, 31))
        }
        if !HomeMockData.openings.isEmpty {
            weights.append((.openings, 15))
        }
        if HomeMockData.handledCount > 0 {
            weights.append((.handled, 5))
        }

        return weights
            .sorted { $0.1 > $1.1 }
            .map(\.0)
    }

    @ViewBuilder
    private func sectionView(_ section: HomeSection) -> some View {
        switch section {
        case .appointments:
            appointmentsSection
        case .decision:
            decisionSection
        case .bookingLink:
            BookingLinkCard(link: HomeMockData.bookingLink)
        case .capabilityNote:
            if let note = HomeMockData.capabilityLimitationNote {
                CapabilityNoteCard(note: note)
            }
        case .openings:
            OpeningsCard(openings: HomeMockData.openings) { _ in
                placeholderMessage = "Fill — not designed yet."
            }
        case .handled:
            HandledSummaryCard(count: HomeMockData.handledCount, examples: HomeMockData.handledExamples)
        }
    }

    @ViewBuilder
    private var appointmentsSection: some View {
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
                    onMessage: { placeholderMessage = "Message — not designed yet." },
                    onCheckout: {
                        checkoutRecommendation = nil
                        checkoutAppointment = next
                    }
                )
            }

            let remaining = HomeMockData.remainingAppointments
            if !remaining.isEmpty {
                RemainingAppointmentsCard(appointments: remaining) {
                    router.push(.schedule)
                }
            }
        }
    }

    @ViewBuilder
    private var decisionSection: some View {
        if let moment = currentMoment {
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
    }
}

/// The force-ranked sections a DAY can surface on Home. See `rankedSections`
/// for how their order and presence are decided.
private enum HomeSection: Identifiable {
    case appointments
    case decision
    case bookingLink
    case capabilityNote
    case openings
    case handled

    var id: Self { self }
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
