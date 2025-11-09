import SwiftUI

struct TaskCardView: View {
    var task: Task
    var namespace: Namespace.ID

    @State private var isPressed = false
    @State private var appeared = false
    @State private var hover = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geo in
            let rect = geo.frame(in: .global)
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(task.emoji).font(.largeTitle)
                        Spacer()
                        ProgressRing(value: task.completedSubtaskRatio, size: 36, lineWidth: 5)
                    }
                    Text(task.title).font(.headline).lineLimit(2)
                    if let notes = task.notes, !notes.isEmpty {
                        Text(notes).font(.subheadline).foregroundColor(.secondary).lineLimit(2)
                    }
                    Spacer()
                    HStack {
                        if let due = task.dueDate {
                            Text(due, style: .date).font(.caption).foregroundColor(.orange)
                        } else {
                            Text("No due").font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Circle().frame(width: 10, height: 10).foregroundColor(task.priority.color)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius, style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius)
                                .stroke(Color(UIColor.separator).opacity(0.9))
                        )
                        .shadow(color: Color.black.opacity(0.12), radius: isPressed ? 3 : 12, x: 0, y: isPressed ? 1 : 10)
                        .matchedGeometryEffect(id: task.id, in: namespace)
                )
                .scaleEffect(isPressed ? 0.98 : (hover ? 1.01 : 1))
                .rotation3DEffect(rotation(for: rect, viewport: geo), axis: (x: rotationAxisX(for: rect), y: rotationAxisY(for: rect), z: 0))
                .onLongPressGesture(minimumDuration: 0.06, pressing: { p in withAnimation(Theme.animationSpring) { isPressed = p } }, perform: {})
                .onHover { h in withAnimation(.easeInOut(duration: 0.18)) { hover = h } }

                if task.priority == .high {
                    Image(systemName: "flame.fill")
                        .padding(10)
                        .foregroundStyle(Color("PriorityHigh"))
                }
            }
        }
    .frame(height: UIConstants.cardHeight)
        .scaleEffect(isPressed ? 0.98 : 1)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { appeared = true }
        }
    }

    // simple tilt: compute angle from center
    private func rotation(for rect: CGRect, viewport: GeometryProxy) -> Angle {
        let midX = rect.midX
        let screenMid = UIScreen.main.bounds.midX
        let diff = Double(midX - screenMid)
        return Angle(degrees: diff / 50)
    }
    private func rotationAxisX(for rect: CGRect) -> CGFloat { 1.0 }
    private func rotationAxisY(for rect: CGRect) -> CGFloat { 0.0 }
}

struct ProgressRing: View {
    var value: Double // 0..1
    var size: CGFloat
    var lineWidth: CGFloat

    var body: some View {
            ZStack {
            Circle().stroke(Color(UIColor.separator), lineWidth: lineWidth)
            Circle().trim(from: 0, to: CGFloat(value))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotation(Angle(degrees: -90))
                .foregroundColor(value >= 1.0 ? .green : .accentColor)
            Text("\(Int(value * 100))%").font(.caption2)
        }
        .frame(width: size, height: size)
    }
}
