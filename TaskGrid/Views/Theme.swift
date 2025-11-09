import SwiftUI

// Design tokens and shared style helpers for a polished, consistent UI
enum Theme {
    static let cornerRadius: CGFloat = 16
    static let cardHeight: CGFloat = 200
    static let shadowColor = Color.black.opacity(0.04)
    static let animationSpring = Animation.interpolatingSpring(stiffness: 120, damping: 18)
}

extension Font {
    static var appTitle: Font { .system(size: 28, weight: .bold) }
    static var appSubtitle: Font { .system(size: 13, weight: .regular) }
    static var cardTitle: Font { .system(size: 16, weight: .semibold) }
}

struct Elevated: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(RoundedRectangle(cornerRadius: Theme.cornerRadius).fill(Color.white))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .shadow(color: Theme.shadowColor, radius: 6, x: 0, y: 3)
    }
}

extension View {
    func elevated() -> some View { modifier(Elevated()) }
}
