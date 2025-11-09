import SwiftUI

// Design tokens and shared style helpers for a polished, consistent UI
enum Theme {
    static let cornerRadius: CGFloat = 16
    static let cardHeight: CGFloat = 200
    static let shadowColor = Color.black.opacity(0.06)
    static let animationSpring = Animation.interpolatingSpring(stiffness: 170, damping: 20)
}

extension Font {
    static var appTitle: Font { .system(size: 28, weight: .bold) }
    static var appSubtitle: Font { .system(size: 14, weight: .regular) }
    static var cardTitle: Font { .system(size: 17, weight: .semibold) }
}

struct Elevated: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(RoundedRectangle(cornerRadius: Theme.cornerRadius).fill(Color("CardBackground")))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .shadow(color: Theme.shadowColor, radius: 10, x: 0, y: 6)
    }
}

extension View {
    func elevated() -> some View { modifier(Elevated()) }
}
