import SwiftUI

/// Wraps a card so it can be dismissed either by a horizontal swipe or by a
/// button inside the card itself — both take the same slide-off animation,
/// via the `requestDismiss` closure handed to `content`.
struct SwipeToDismissCard<Content: View>: View {
    var onDismiss: () -> Void
    /// When false, dragging still moves the card but it always springs back
    /// on release — a swipe can never dismiss it, only `requestDismiss`
    /// (i.e. a choice made inside the card) can.
    var swipeToDismissEnabled: Bool = true
    @ViewBuilder var content: (_ requestDismiss: @escaping () -> Void) -> Content

    @State private var dragOffset: CGSize = .zero
    @State private var isDismissing = false

    private let dismissThreshold: CGFloat = 90
    private let flyOutDistance: CGFloat = 500

    var body: some View {
        content(requestDismiss)
            .offset(x: dragOffset.width)
            .rotationEffect(.degrees(Double(dragOffset.width / 18)))
            .opacity(isDismissing ? 0 : 1)
            // `.simultaneousGesture`, not `.gesture` — this card sits
            // inside Home's ScrollView, and an exclusive gesture here
            // would claim every drag that starts on the card (including a
            // vertical scroll attempt) before the ScrollView ever sees it.
            // Letting both recognizers see the drag, and only reacting
            // here when the drag is actually horizontal, is what lets a
            // vertical swipe starting on the card still scroll the page.
            .simultaneousGesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        guard !isDismissing, isHorizontalDrag(value) else { return }
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        guard !isDismissing else { return }
                        guard isHorizontalDrag(value) else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { dragOffset = .zero }
                            return
                        }
                        if swipeToDismissEnabled, abs(value.translation.width) > dismissThreshold {
                            animateOff(direction: value.translation.width > 0 ? 1 : -1)
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = .zero
                            }
                        }
                    }
            )
    }

    private func isHorizontalDrag(_ value: DragGesture.Value) -> Bool {
        abs(value.translation.width) > abs(value.translation.height)
    }

    /// What a button inside `content` calls instead of the raw dismiss
    /// callback — so "Got it" / "Not now" / picking an option all read as
    /// the same swipe-away motion a drag would produce.
    private func requestDismiss() {
        guard !isDismissing else { return }
        animateOff(direction: 1)
    }

    private func animateOff(direction: CGFloat) {
        isDismissing = true
        withAnimation(Tokens.Motion.quick) {
            dragOffset.width = direction * flyOutDistance
        }
        Task {
            try? await Task.sleep(nanoseconds: 220_000_000)
            onDismiss()
        }
    }
}
