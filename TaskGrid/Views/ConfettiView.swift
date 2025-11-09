import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = (0..<25).map { _ in ConfettiParticle.random() }

    var body: some View {
        ZStack {
            ForEach(particles.indices, id: \.self) { index in
                let particle = particles[index]
                Text(particle.emoji)
                    .font(.system(size: CGFloat(particle.size)))
                    .position(particle.position)
                    .rotationEffect(.degrees(particle.rotation))
                    .opacity(particle.opacity)
                    .onAppear {
                        withAnimation(.easeOut(duration: particle.duration)) {
                            particles[index].position.y += CGFloat(350 + Int.random(in: 0...250))
                            particles[index].opacity = 0
                            particles[index].rotation += Double.random(in: -360...360)
                        }
                    }
            }
        }
        .ignoresSafeArea()
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var emoji: String
    var size: Int
    var position: CGPoint
    var rotation: Double
    var opacity: Double
    var duration: Double

    static func random() -> ConfettiParticle {
        let emojis = ["🎉","✨","🎊","🌟","💫","🔥","⭐️"]
        return ConfettiParticle(
            emoji: emojis.randomElement() ?? "🎉",
            size: Int.random(in: 20...40),
            position: CGPoint(x: CGFloat.random(in: 30...UIScreen.main.bounds.width - 30),
                              y: CGFloat.random(in: 60...180)),
            rotation: Double.random(in: -45...45),
            opacity: 1,
            duration: Double.random(in: 1.2...2.4)
        )
    }
}
