import SwiftUI

/// Replaces the system back button (chevron + previous title) with a plain
/// back-arrow icon, no text — used on every screen pushed via `Router`.
struct BackIconButtonModifier: ViewModifier {
    var onBack: () -> Void

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Tokens.Color.textPrimary)
                    }
                }
            }
    }
}

extension View {
    func backIconButton(onBack: @escaping () -> Void) -> some View {
        modifier(BackIconButtonModifier(onBack: onBack))
    }
}
