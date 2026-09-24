import SwiftUI

/// DETAIL speaking a CUE — one thing it noticed — plus the ACTION it
/// already took in response. Advances on its own after a beat, or
/// immediately if she taps through, into whatever comes next (e.g. a
/// threshold proposal following from this same moment).
struct CueCard: View {
    var cue: Cue
    var onAcknowledge: () -> Void

    @State private var acknowledged = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(cue.spokenText)
                .font(BUITokens.Typography.cardTitle)
                .foregroundStyle(BUITokens.Color.textPrimary)

            if let action = cue.action {
                VStack(alignment: .leading, spacing: 4) {
                    Text("WHAT I DID")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(BUITokens.Color.disabled)
                    Text(action.description)
                        .font(.system(size: 13))
                        .foregroundStyle(BUITokens.Color.textStrong)
                }
            }

            HStack {
                Spacer()
                Button("Got it", action: acknowledge)
                    .font(.system(size: 12))
                    .foregroundStyle(BUITokens.Color.textStrong)
            }
        }
        .padding(16)
        .background(BUITokens.Color.background)
        .clipShape(RoundedRectangle(cornerRadius: BUITokens.Radius.card))
        .shadow(color: BUITokens.Shadow.medium, radius: BUITokens.Shadow.mediumRadius, x: 0, y: BUITokens.Shadow.mediumY)
        .task {
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            acknowledge()
        }
    }

    private func acknowledge() {
        guard !acknowledged else { return }
        acknowledged = true
        onAcknowledge()
    }
}

#Preview {
    CueCard(cue: HomeMockData.pendingCue!, onAcknowledge: {})
        .padding(28)
        .background(BUITokens.Color.background)
}
