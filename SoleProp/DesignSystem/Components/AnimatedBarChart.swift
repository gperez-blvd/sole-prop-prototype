import SwiftUI

/// A minimal vertical bar chart whose bars transition between series in
/// two explicit phases, not one simultaneous jump — used by `LogsView`'s
/// revenue chart when switching Week/Month/Year:
///
/// 1. **Width first.** The column *count* changes to match the new
///    range (4 bars → 7, say), so every bar's width reflows to the new
///    equal share of the row. Existing bars keep their *old* height
///    through this phase — only the reflow is visible.
/// 2. **Height second**, once the reflow has settled. Every bar
///    (including ones that just appeared in phase 1) animates to its
///    real value, and the real labels swap in.
///
/// Doing this as two sequential `withAnimation` blocks — driven by this
/// view's own `@State`, not by an ambient `.animation(value:)` modifier
/// on the caller — is what makes it "fill in and appear nicely, evenly,
/// and structured" instead of bars popping in and out: a single
/// animated pass can't express "reflow, then resize" as two readable
/// beats, only as one blurred-together change.
struct AnimatedBarChart: View {
    var points: [RevenuePoint]
    var height: CGFloat = 170

    @State private var visibleCount = 0
    @State private var displayedAmounts: [Decimal] = []
    @State private var displayedLabels: [String] = []
    @State private var displayedMax: Decimal = 1

    // A deceleration curve rather than symmetric `easeInOut` — same
    // reasoning as the Cue wordmark's own draw-on animation (see
    // ENGINEERING_LESSONS.md): a reflow/resize that eases out gently
    // reads as considered, where a symmetric ease at this speed reads
    // as mechanical. Slightly slower than the first pass too, so two
    // sequential beats have room to actually register as two beats
    // rather than one quick blur.
    private let widthPhase = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.28)
    private let heightPhase = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.42)
    /// How long phase 1 gets to visibly settle before phase 2 starts —
    /// matched to `widthPhase`'s own duration so the two beats read as
    /// sequential, not overlapping.
    private let phaseGap = 0.28

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(0..<visibleCount, id: \.self) { index in
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Tokens.Color.accentSoft)
                        .frame(height: barHeight(at: index))
                    Text(index < displayedLabels.count ? displayedLabels[index] : "")
                        .font(Tokens.Typography.caption)
                        .foregroundStyle(Tokens.Color.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: height, alignment: .bottom)
        .onAppear(perform: setUpInitialState)
        .onChange(of: points) { _, newPoints in
            animateTransition(to: newPoints)
        }
    }

    private func barHeight(at index: Int) -> CGFloat {
        guard index < displayedAmounts.count, displayedMax > 0 else { return 4 }
        let ratio = Double(truncating: (displayedAmounts[index] / displayedMax) as NSNumber)
        let available = height - 30 // room for the label + its gap
        return max(CGFloat(ratio) * available, 4)
    }

    private func setUpInitialState() {
        guard displayedAmounts.isEmpty else { return }
        visibleCount = points.count
        displayedAmounts = points.map(\.amount)
        displayedLabels = points.map(\.label)
        displayedMax = points.map(\.amount).max() ?? 1
    }

    private func animateTransition(to newPoints: [RevenuePoint]) {
        let newCount = newPoints.count

        // Phase 1 — width: move the column count to its new target.
        // Existing slots keep their current amount (so their height
        // doesn't move yet); new slots start at 0 so they appear flat
        // and grow in phase 2, rather than snapping straight to their
        // final height during what should read as a pure reflow.
        withAnimation(widthPhase) {
            if displayedAmounts.count < newCount {
                displayedAmounts += Array(repeating: Decimal(0), count: newCount - displayedAmounts.count)
                displayedLabels += Array(repeating: "", count: newCount - displayedLabels.count)
            } else if displayedAmounts.count > newCount {
                displayedAmounts = Array(displayedAmounts.prefix(newCount))
                displayedLabels = Array(displayedLabels.prefix(newCount))
            }
            visibleCount = newCount
        }

        // Phase 2 — height: once the reflow has had room to settle,
        // animate every bar to its real value and swap in real labels.
        DispatchQueue.main.asyncAfter(deadline: .now() + phaseGap) {
            withAnimation(heightPhase) {
                displayedMax = newPoints.map(\.amount).max() ?? 1
                displayedAmounts = newPoints.map(\.amount)
                displayedLabels = newPoints.map(\.label)
            }
        }
    }
}
