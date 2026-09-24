import SwiftUI

/// Wraps a card so it can be dismissed either by a horizontal swipe or by a
/// button inside the card itself — both take the same slide-off animation,
/// via the `requestDismiss` closure handed to `content`.
struct SwipeToDismissCard<Content: View>: View {
    var onDismiss: () -> Void
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
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard !isDismissing else { return }
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        guard !isDismissing else { return }
                        if abs(value.translation.width) > dismissThreshold {
                            animateOff(direction: value.translation.width > 0 ? 1 : -1)
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = .zero
                            }
                        }
                    }
            )
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
        withAnimation(.easeOut(duration: 0.22)) {
            dragOffset.width = direction * flyOutDistance
        }
        Task {
            try? await Task.sleep(nanoseconds: 220_000_000)
            onDismiss()
        }
    }
}
