import SwiftUI

// Centralized UI constants and modifiers for consistent look & feel
enum UIConstants {
    static let cardCornerRadius: CGFloat = 12
    static let cardHeight: CGFloat = 200
    static let cardShadowRadius: CGFloat = 4
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius, style: .continuous)
                            .stroke(Color(UIColor.separator).opacity(0.6), lineWidth: 0.6)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius, style: .continuous))
            .shadow(color: Theme.shadowColor, radius: UIConstants.cardShadowRadius, x: 0, y: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// Professional button style: solid, subtle shadow, minimal overlay
struct AppButtonStyle: ButtonStyle {
    var color: Color = Color("Primary")
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundColor(.white)
            .fontWeight(.semibold)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(UIColor.separator).opacity(0.12), lineWidth: 0.5)
            )
            .shadow(color: color.opacity(0.12), radius: 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.88 : 1.0)
    }
}

