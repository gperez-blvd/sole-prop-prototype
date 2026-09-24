import SwiftUI

/// The checkout popup — a slide-up sheet (not a full-screen push) with an X
/// close button, reachable from the appointment card's "..." menu or by
/// asking Cue to check a client out. No payment design exists yet, so the
/// "Charge" action is a placeholder.
///
/// `recommendation`, when present, is a product Cue proactively added
/// (the "Checkout Tasha" demo scenario) — flagged with a "Suggested by
/// Cue" tag and included in the total by default, but removable.
struct CheckoutSheet: View {
    var appointment: Appointment
    var recommendation: RecommendedItem?
    var onClose: () -> Void

    @State private var placeholderMessage: String?
    @State private var recommendationIncluded = true

    private var total: Decimal {
        appointment.price + (recommendationIncluded ? (recommendation?.price ?? 0) : 0)
    }

    private func currency(_ value: Decimal) -> String {
        value.formatted(.currency(code: "USD"))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appointment.clientName)
                            .font(.system(size: 24, weight: .semibold))
                        Text(appointment.service)
                            .font(.system(size: 14))
                            .foregroundStyle(BUITokens.Color.textStrong)
                    }

                    VStack(spacing: 0) {
                        lineItem(label: appointment.service, value: currency(appointment.price))
                        if let recommendation {
                            recommendationRow(recommendation)
                        }
                        lineItem(label: "Total", value: currency(total), emphasized: true)
                    }
                    .padding(16)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(BUITokens.Color.disabled.opacity(0.4), lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    if let placeholderMessage {
                        Text(placeholderMessage)
                            .font(.system(size: 12))
                            .foregroundStyle(BUITokens.Color.disabled)
                    }

                    Button {
                        placeholderMessage = "Payment processing — not designed yet."
                    } label: {
                        Text("Charge \(currency(total))")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .background(BUITokens.Color.contrastPrimary)
                    .clipShape(Capsule())
                }
                .padding(24)
            }
            .background(BUITokens.Color.background)
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(BUITokens.Color.textPrimary)
                    }
                }
            }
        }
    }

    private func lineItem(label: String, value: String, emphasized: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: emphasized ? .semibold : .regular))
                .foregroundStyle(BUITokens.Color.textPrimary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: emphasized ? .semibold : .regular))
                .foregroundStyle(BUITokens.Color.textPrimary)
        }
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            if !emphasized {
                Rectangle().fill(BUITokens.Color.disabled.opacity(0.3)).frame(height: 1)
            }
        }
    }

    private func recommendationRow(_ recommendation: RecommendedItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(BUITokens.Color.bluegreen)
                        Text("Suggested by Cue")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(BUITokens.Color.bluegreen)
                    }
                    Text(recommendation.name)
                        .font(.system(size: 14, weight: recommendationIncluded ? .regular : .regular))
                        .foregroundStyle(recommendationIncluded ? BUITokens.Color.textPrimary : BUITokens.Color.disabled)
                        .strikethrough(!recommendationIncluded)
                }
                Spacer()
                Text(currency(recommendation.price))
                    .font(.system(size: 14))
                    .foregroundStyle(recommendationIncluded ? BUITokens.Color.textPrimary : BUITokens.Color.disabled)
                    .strikethrough(!recommendationIncluded)
            }

            Button {
                recommendationIncluded.toggle()
            } label: {
                Text(recommendationIncluded ? "Remove" : "Add back")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(recommendationIncluded ? Color.red : BUITokens.Color.bluegreen)
            }
        }
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Rectangle().fill(BUITokens.Color.disabled.opacity(0.3)).frame(height: 1)
        }
    }
}

#Preview {
    CheckoutSheet(
        appointment: HomeMockData.todaysAppointments[2],
        recommendation: RecommendedItem(name: "Vitamin C Serum", price: 68, reason: "Tasha mentioned wanting serum"),
        onClose: {}
    )
}
