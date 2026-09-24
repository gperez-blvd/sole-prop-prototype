import SwiftUI

/// A net-new booking for an imported client. Client, service, day, time: four
/// taps. Everything downstream — confirmation, deposit, intake, reminder — is
/// Boulevard's job, not hers.
struct BookAppointmentView: View {
    var state: OnboardingState
    var onOpenPersona: () -> Void
    var onBack: () -> Void

    @State private var query = ""
    @State private var client: String?
    @State private var service: String?
    @State private var dayIndex = 2
    @State private var slot: String?
    @State private var booked = false

    private let clients = ["Dani R.", "Maya N.", "Priya S.", "Tasha W.", "Lena K.", "Morgan B.", "Ava J.", "Renee C."]
    private var services: [String] {
        var list = ["Neurotoxin", "Lip filler", "HydraFacial", "Laser hair removal", "Chemical peel"]
        if state.microneedlingAdded { list.append("Microneedling") }
        return list
    }
    private let days: [(String, String)] = [("Tue", "24"), ("Wed", "25"), ("Thu", "26"), ("Fri", "27"), ("Sat", "28")]
    private let slots = ["9:00", "9:45", "10:30", "11:15", "1:30", "2:15", "3:00", "3:45"]
    private let taken: [Int: Set<String>] = [0: ["9:00", "1:30"], 1: ["10:30"], 2: ["9:45", "3:45"], 3: ["9:00", "2:15"], 4: ["11:15", "3:00"]]

    private var filteredClients: [String] {
        guard !query.isEmpty else { return clients }
        return clients.filter { $0.lowercased().contains(query.lowercased()) }
    }

    private var isReady: Bool { client != nil && service != nil && slot != nil }

    var body: some View {
        OnboardingScreen(section: "Book") {
            if booked {
                confirmation
            } else {
                Text("Book an appointment.")
                    .font(Tokens.Typography.title)
                    .foregroundStyle(Tokens.Color.textPrimary)

                OnboardingField(label: "Client", text: $query)

                wrapChips(filteredClients, selected: client) { client = $0 }

                TrackedLabel(text: "Service").padding(.top, Tokens.Spacing.sm)
                wrapChips(services, selected: service) { service = $0 }

                TrackedLabel(text: "Day").padding(.top, Tokens.Spacing.sm)
                HStack(spacing: 6) {
                    ForEach(days.indices, id: \.self) { i in
                        dayTile(i)
                    }
                }

                TrackedLabel(text: "Time").padding(.top, Tokens.Spacing.sm)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 6) {
                    ForEach(slots, id: \.self) { time in
                        slotTile(time)
                    }
                }

                PillButton(title: bookButtonTitle, isDisabled: !isReady) {
                    booked = true
                    let label = "\(client ?? "") · \(service ?? "") · \(days[dayIndex].0) at \(slot ?? "")"
                    state.bookedAppointments.append(label)
                }
                .padding(.top, Tokens.Spacing.md)

                PillButton(title: "Back to home", style: .ghost, action: onBack)
            }
        }
    }

    private var confirmation: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            Text("Booked.")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.textPrimary)

            VStack(alignment: .leading, spacing: 6) {
                TrackedLabel(text: "Appointment")
                Text(client ?? "")
                    .font(.system(size: 16, weight: .semibold))
                Text("\(service ?? "") · \(days[dayIndex].0) \(days[dayIndex].1) at \(slot ?? "")")
                    .font(.system(size: 12.5))
                    .foregroundStyle(Tokens.Color.textSecondary)
                Text("Confirmation texted. Deposit link sent. Reminder set for the day before.")
                    .font(.system(size: 12.5))
                    .foregroundStyle(Tokens.Color.textSecondary)
            }
            .padding(16)
            .background(Tokens.Color.silt)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 10) {
                Text("Want to change how I sound?")
                    .font(.system(size: 13.5, weight: .semibold))
                Text("Let's customize your Cues.")
                    .font(.system(size: 12.5))
                    .foregroundStyle(Tokens.Color.textSecondary)
                PillButton(title: "Customize your Cues", action: onOpenPersona)
            }
            .padding(14)
            .background(Tokens.Color.silt)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            PillButton(title: "Book another") {
                booked = false; client = nil; service = nil; slot = nil; query = ""
            }
            PillButton(title: "Back to home", style: .ghost, action: onBack)
        }
    }

    private var bookButtonTitle: String {
        guard isReady else { return "Book" }
        return "Book \(client?.split(separator: " ").first.map(String.init) ?? "") · \(days[dayIndex].0) \(slot ?? "")"
    }

    private func wrapChips(_ items: [String], selected: String?, onPick: @escaping (String) -> Void) -> some View {
        FlowLayout(spacing: 8) {
            ForEach(items, id: \.self) { item in
                ChoiceChip(title: item, isSelected: selected == item) { onPick(item) }
            }
        }
    }

    private func dayTile(_ index: Int) -> some View {
        let isSelected = dayIndex == index
        return Button { dayIndex = index; slot = nil } label: {
            VStack(spacing: 2) {
                TrackedLabel(text: days[index].0, font: Tokens.Typography.labelSmall, color: isSelected ? Tokens.Color.fog.opacity(0.6) : Tokens.Color.textTertiary)
                Text(days[index].1)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isSelected ? Tokens.Color.fog : Tokens.Color.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .background(isSelected ? Tokens.Color.ink : Color.clear)
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.black.opacity(0.25), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func slotTile(_ time: String) -> some View {
        let isTaken = taken[dayIndex]?.contains(time) ?? false
        let isSelected = slot == time
        return Button {
            guard !isTaken else { return }
            slot = time
        } label: {
            Text(time)
                .font(.system(size: 11.5, design: .monospaced))
                .strikethrough(isTaken)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? Tokens.Color.fog : (isTaken ? Tokens.Color.textTertiary : Tokens.Color.textPrimary))
        .background(isSelected ? Tokens.Color.ink : Color.clear)
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.black.opacity(0.25), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .opacity(isTaken ? 0.4 : 1)
        .disabled(isTaken)
    }
}

/// Minimal flow layout for chip rows (SwiftUI has no built-in wrap HStack).
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: width.isFinite ? width : x, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX, y: CGFloat = bounds.minY, lineHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += lineHeight + spacing
                lineHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

#Preview {
    BookAppointmentView(state: OnboardingState(), onOpenPersona: {}, onBack: {})
}
