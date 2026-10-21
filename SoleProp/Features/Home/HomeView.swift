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
    @State private var clientPage: ClientMemory?
    @State private var checkoutAppointment: Appointment?
    @State private var checkoutRecommendation: RecommendedItem?
    @State private var showQuarterlyBrief = false
    @State private var placeholderMessage: String?
    @State private var captionText: String?
    @State private var captionHideTask: Task<Void, Never>?

    @State private var momentQueue: [DetailMoment] = [
        HomeMockData.pendingCue.map(DetailMoment.cue),
        HomeMockData.pendingThresholdProposal.map(DetailMoment.proposal),
    ].compactMap { $0 }
    /// Shown once per app launch before any of Home's own content — see
    /// `homeContent`/`DailyBriefView`.
    @State private var showDailyBrief = true

    var body: some View {
        ZStack {
            Tokens.Color.background.ignoresSafeArea()

            homeContent
                .opacity(showDailyBrief ? 0 : 1)
                .scaleEffect(showDailyBrief ? 0.96 : 1)
                .allowsHitTesting(!showDailyBrief)

            if showDailyBrief {
                DailyBriefView(brief: HomeMockData.dailyBrief) {
                    voiceAssistant.skipDailyBriefAudio()
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
                VStack(alignment: .leading, spacing: 40) {
                    HomeHeaderBar(
                        businessName: HomeMockData.businessName,
                        onMenuTap: { showMenu = true },
                        onMessagesTap: { router.push(.messages) },
                        onNotificationsTap: { router.push(.notifications) }
                    )
                    .staggerAppear(0)

                    Text("Good morning \(HomeMockData.ownerFirstName).")
                        .font(Tokens.Typography.largeTitle)
                        .foregroundStyle(Tokens.Color.textPrimary)
                        .staggerAppear(1)

                    ForEach(Array(rankedSections.enumerated()), id: \.element.id) { index, section in
                        sectionView(section)
                            .transition(.opacity)
                            .staggerAppear(index + 2)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 19)
                // Reserves room below the last card for the fixed orb
                // overlay, so scrolled content never sits underneath it.
                .padding(.bottom, 120)
            }

            // Dims the whole page while Cue is listening or talking —
            // a clear "this is the moment that has your attention" cue,
            // not just the orb itself lighting up.
            Color.black
                .opacity(voiceAssistant.orbIsActive ? 0.25 : 0)
                .allowsHitTesting(false)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.35), value: voiceAssistant.orbIsActive)

            OrbBackdropFade()

            VoiceOrb(level: voiceAssistant.orbLevel, isActive: voiceAssistant.orbIsActive)
                .contentShape(Circle())
                .onTapGesture {
                    voiceAssistant.toggleListening()
                }
                .onLongPressGesture(minimumDuration: 0.4) {
                    router.push(.voiceConversation)
                }
                .padding(.bottom, VoiceOrb.standardBottomInset)
                .frame(maxHeight: .infinity, alignment: .bottom)
                // Deliberately NOT ignoring the safe area here — this
                // needs to land at the same height as the conversation
                // screen's orb (`VoiceConversationView`), which also
                // measures its bottom inset from the safe area, not the
                // literal screen edge. Ignoring it pushes the orb below
                // the home indicator's safe inset, noticeably lower than
                // the conversation screen's.

            // Drawn last (on top of the orb, not behind it) — a long reply
            // sits well clear of the orb's own glow rather than risking an
            // overlap with it.
            if let captionText {
                Text(captionText)
                    .font(Tokens.Typography.bodyRegular)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    // Glanceable, not a transcript — the full reply is
                    // always there in the chat stream itself. Outside of
                    // it (Home), this is a one-line confirmation, not a
                    // reason to reflow a multi-sentence reply.
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Tokens.Color.surface, in: Capsule())
                    .shadow(color: Tokens.Shadow.medium.color, radius: Tokens.Shadow.medium.radius, y: Tokens.Shadow.medium.y)
                    .padding(.horizontal, 28)
                    // Same safe-area-respecting basis as the orb above —
                    // otherwise this gap is being measured from a
                    // different zero point than the orb it's supposed to
                    // clear, and the two inset changes stop lining up.
                    // Now that the orb's glow is properly bounded to a
                    // real layout frame (it was ballooning to ~4x its
                    // nominal size and rendering straight through this
                    // gap regardless of padding), a fixed 48px clearance
                    // from its nominal top edge is actually enough.
                    .padding(.bottom, VoiceOrb.standardBottomInset + VoiceOrb.standardSize + 48)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .transition(.opacity)
            }
        }
        // Cue answers the same way no matter which screen the orb is on —
        // Home doesn't show the full transcript, so without this the
        // reply would be spoken but never visibly confirmed here. Mirrors
        // the transcript rather than replacing it: one line, autohides.
        .onChange(of: voiceAssistant.messages.count) { _, _ in
            guard let last = voiceAssistant.messages.last, last.role != .user else { return }
            captionHideTask?.cancel()
            withAnimation(.easeOut(duration: 0.25)) { captionText = last.text }
            captionHideTask = Task {
                try? await Task.sleep(for: .seconds(5))
                guard !Task.isCancelled else { return }
                withAnimation(.easeOut(duration: 0.25)) { captionText = nil }
            }
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
        .sheet(item: $clientPage) { memory in
            NavigationStack {
                ClientDetailView(memory: memory)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button { clientPage = nil } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Tokens.Color.textPrimary)
                            }
                        }
                    }
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
    /// lead and the quieter, lower-tier sections (openings) round out the
    /// bottom. No section is ever chosen or ordered by stage.
    private var rankedSections: [HomeSection] {
        var weights: [(HomeSection, Int)] = []

        let appointmentCount = HomeMockData.todaysAppointments.count
        if appointmentCount > 0 {
            weights.append((.appointments, appointmentCount * 10))
        }
        if !momentQueue.isEmpty {
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
        }
    }

    @ViewBuilder
    private var appointmentsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Next appointment")
                .font(Tokens.Typography.label)
                .foregroundStyle(Tokens.Color.textTertiary)

            if let next = HomeMockData.nextAppointment {
                NextAppointmentCard(
                    appointment: next,
                    onTap: { selectedAppointment = next },
                    onEdit: { placeholderMessage = "Edit — not designed yet." },
                    onClientInfo: {
                        if let memory = HomeMockData.clientMemory(for: next) {
                            clientPage = memory
                        } else {
                            placeholderMessage = "Client info — not designed yet."
                        }
                    },
                    onMessage: { placeholderMessage = "Message — not designed yet." },
                    onCheckout: {
                        checkoutRecommendation = nil
                        checkoutAppointment = next
                    }
                )
            }

            let today = HomeMockData.todaysAppointments
            if !today.isEmpty {
                RemainingAppointmentsCard(appointments: today) {
                    router.push(.schedule)
                }
            }
        }
    }

    @ViewBuilder
    private var decisionSection: some View {
        if !momentQueue.isEmpty {
            VStack(spacing: 6) {
                DetailMomentStack(moments: momentQueue) {
                    guard !momentQueue.isEmpty else { return }
                    momentQueue.removeFirst()
                }

                // A minimal hint that there's more behind the front card —
                // only shown when swiping actually does something.
                if momentQueue.count > 1 {
                    Image(systemName: "arrow.left.and.right")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Tokens.Color.textTertiary)
                }
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

    var id: Self { self }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(Router())
    .environment(VoiceConversationViewModel())
}
