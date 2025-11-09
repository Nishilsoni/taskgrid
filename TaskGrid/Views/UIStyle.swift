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
                ZStack {
                    RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius, style: .continuous)
                        .fill(Color.white)
                    RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.4)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: UIConstants.cardShadowRadius, x: 0, y: 6)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// Apple-style button with vibrant color and blur background
struct AppButtonStyle: ButtonStyle {
    var color: Color = Color("Primary")
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundColor(.white)
            .fontWeight(.semibold)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)
                }
            )
            .shadow(color: color.opacity(0.28), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.88 : 1.0)
    }
}

