import SwiftUI

/// The checkout popup — a slide-up sheet (not a full-screen push) with an X
/// close button, reachable from the appointment card's "..." menu or by
/// asking Cue to check a client out. No payment design exists yet, so the
/// "Charge" action is a placeholder.
struct CheckoutSheet: View {
    var appointment: Appointment
    var onClose: () -> Void

    @State private var placeholderMessage: String?

    private var priceText: String {
        appointment.price.formatted(.currency(code: "USD"))
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
                        lineItem(label: appointment.service, value: priceText)
                        lineItem(label: "Total", value: priceText, emphasized: true)
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
                        Text("Charge \(priceText)")
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
}

#Preview {
    CheckoutSheet(appointment: HomeMockData.todaysAppointments[0], onClose: {})
}
