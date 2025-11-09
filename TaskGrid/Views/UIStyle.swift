import SwiftUI

// Centralized UI constants and modifiers for consistent look & feel
enum UIConstants {
    static let cardCornerRadius: CGFloat = 16
    static let cardHeight: CGFloat = 200
    static let cardShadowRadius: CGFloat = 8
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius, style: .continuous)
                    .fill(Color("CardBackground"))
            )
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: UIConstants.cardShadowRadius, x: 0, y: 6)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

struct AppButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color("Primary")))
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}
