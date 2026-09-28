import SwiftUI

/// CLIENT detail — answers "what do I know about her?" so she doesn't keep
/// it in her head or a notes doc. Opened only on her initiative, from the
/// appointment.
///
/// The one line DETAIL would say about her (`ClientMemory.sentence`) lives
/// on the appointment and in voice, not here — this page is the level below
/// it: the few facts, her visits, and, only if she taps the rebooking row,
/// how DETAIL knows. The chart is a link, not inlined: clinical detail sits
/// behind its own door. A first visit is a nearly empty page, and that's
/// the calm case, not an unfinished one.
struct ClientDetailView: View {
    @State var memory: ClientMemory

    @State private var showingHowIKnow = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(memory.fullName)
                        .font(Tokens.Typography.largeTitle)
                        .foregroundStyle(Tokens.Color.textPrimary)
                    Text(memory.visits.isEmpty ? "First visit today" : "Client since \(memory.clientSince.formatted(.dateTime.month(.wide).year()))")
                        .font(Tokens.Typography.caption)
                        .foregroundStyle(Tokens.Color.textTertiary)
                }

                facts

                NavigationLink {
                    ClientChartView(firstName: memory.firstName, chart: memory.chart)
                } label: {
                    HStack {
                        Text("Chart")
                            .font(Tokens.Typography.body)
                            .foregroundStyle(Tokens.Color.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Tokens.Color.textTertiary)
                    }
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                    .overlay(alignment: .top) { hairline }
                    .overlay(alignment: .bottom) { hairline }
                }
                .buttonStyle(.plain)

                if !memory.visits.isEmpty {
                    visitHistory
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .background(Tokens.Color.background)
        .navigationTitle(memory.firstName)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var facts: some View {
        let lastOfEach = memory.lastOfEach
        let products = memory.productsBought
        if memory.cadenceDays != nil || !lastOfEach.isEmpty || !products.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                if let days = memory.cadenceDays {
                    cadenceRow(days: days)
                }
                ForEach(lastOfEach, id: \.service) { last in
                    factRow(label: "Last \(last.service)", value: last.date.formatted(.dateTime.month(.wide).day()))
                }
                ForEach(products, id: \.name) { product in
                    factRow(
                        label: "Buys",
                        value: product.name,
                        detail: "\(product.dates.count == 1 ? "Once" : "\(product.dates.count) times") · last in \(product.dates[0].formatted(.dateTime.month(.wide)))"
                    )
                }
            }
        }
    }

    /// The one belief on the page, so the one row with a "why". Everything
    /// else here is a record, not an inference.
    private func cadenceRow(days: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeOut(duration: 0.2)) { showingHowIKnow.toggle() }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    factRow(label: "Rebooks", value: "About every \(ClientMemory.weeksPhrase(days))")
                    Spacer()
                    Image(systemName: showingHowIKnow ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Tokens.Color.textTertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if showingHowIKnow, let belief = memory.cadenceBelief {
                VStack(alignment: .leading, spacing: 10) {
                    Text("From the \(memory.gapsObserved) gaps between her visits since \(memory.clientSince.formatted(.dateTime.month(.wide))). I noticed it in \(belief.noticedOn.formatted(.dateTime.month(.wide)))\(belief.confirmedByHer ? " and you confirmed it" : "").")
                        .font(Tokens.Typography.bodyRegular)
                        .foregroundStyle(Tokens.Color.textSecondary)
                    Button("That's not right") {
                        withAnimation(.easeOut(duration: 0.2)) {
                            memory.cadenceBelief = nil
                            showingHowIKnow = false
                        }
                    }
                    .font(Tokens.Typography.caption)
                    .foregroundStyle(Tokens.Color.textPrimary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Tokens.Color.silt.opacity(0.5), in: RoundedRectangle(cornerRadius: Tokens.Radius.md))
            }
        }
    }

    private var visitHistory: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Visits")
                .font(Tokens.Typography.labelSmall)
                .foregroundStyle(Tokens.Color.textTertiary)
                .textCase(.uppercase)
                .kerning(1.2)
                .padding(.bottom, 6)
            ForEach(memory.visits) { visit in
                HStack {
                    Text(visit.service)
                        .font(Tokens.Typography.bodyRegular)
                        .foregroundStyle(Tokens.Color.textPrimary)
                    Spacer()
                    Text(Calendar.current.isDate(visit.date, equalTo: Date(), toGranularity: .year)
                        ? visit.date.formatted(.dateTime.month(.abbreviated).day())
                        : visit.date.formatted(.dateTime.month(.abbreviated).day().year()))
                        .font(Tokens.Typography.caption)
                        .foregroundStyle(Tokens.Color.textTertiary)
                }
                .padding(.vertical, 10)
                .overlay(alignment: .bottom) { hairline }
            }
        }
    }

    private func factRow(label: String, value: String, detail: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(Tokens.Typography.labelSmall)
                .foregroundStyle(Tokens.Color.textTertiary)
                .textCase(.uppercase)
                .kerning(1.2)
            Text(value)
                .font(Tokens.Typography.body)
                .foregroundStyle(Tokens.Color.textPrimary)
            if let detail {
                Text(detail)
                    .font(Tokens.Typography.caption)
                    .foregroundStyle(Tokens.Color.textTertiary)
            }
        }
    }

    private var hairline: some View {
        Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
    }
}

/// CHART — the clinical record, reached only from the client page. On
/// screen, never spoken: DETAIL reads none of this aloud.
struct ClientChartView: View {
    var firstName: String
    var chart: ClientChart

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let skinType = chart.skinType {
                    row(label: "Skin", value: skinType)
                }
                row(label: "Allergies", value: chart.allergies)
                row(label: "Medications", value: chart.medications)
                row(label: "Contraindications", value: chart.contraindications)
                if let note = chart.lastNote {
                    row(
                        label: "Last note · \(note.service) · \(note.date.formatted(.dateTime.month(.wide).day()))",
                        value: note.text
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .background(Tokens.Color.background)
        .navigationTitle("\(firstName)'s chart")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(Tokens.Typography.labelSmall)
                .foregroundStyle(Tokens.Color.textTertiary)
                .textCase(.uppercase)
                .kerning(1.2)
            Text(value)
                .font(Tokens.Typography.body)
                .foregroundStyle(Tokens.Color.textPrimary)
        }
    }
}

#Preview("Tasha") {
    NavigationStack {
        ClientDetailView(memory: HomeMockData.clientMemory(
            for: Appointment(clientName: "Tasha W.", service: "HydraFacial", startTime: .now, durationMinutes: 50, isFirstTime: false, note: nil, price: 199)
        )!)
    }
}

#Preview("First visit") {
    NavigationStack {
        ClientDetailView(memory: HomeMockData.clientMemory(
            for: Appointment(clientName: "Maya N.", service: "Neurotoxin", startTime: .now, durationMinutes: 30, isFirstTime: true, note: nil, price: 325)
        )!)
    }
}
