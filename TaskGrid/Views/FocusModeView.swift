import SwiftUI
import Combine

struct FocusModeView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var store: TaskStore

    @State var task: Task
    var onComplete: ((Task) -> Void)? = nil

    @State private var duration: TimeInterval = 25 * 60
    @State private var remaining: TimeInterval = 25 * 60
    @State private var running = false
    @State private var timerCancellable: AnyCancellable?
    @State private var showConfetti = false
    @State private var quote: String = FocusModeView.randomQuote()
    @State private var markPressed = false
    @Environment(\.colorScheme) private var colorScheme

    init(task: Task, onComplete: ((Task) -> Void)? = nil) {
        self._task = State(initialValue: task)
        self.onComplete = onComplete
        self._remaining = State(initialValue: 25 * 60)
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return (duration - remaining) / duration
    }

    var body: some View {
        ZStack {
            // MARK: - Background Glass Effect
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()
                LinearGradient(
                    colors: [Color("CardBackground"), Color("Primary").opacity(0.06)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                // subtle blur/material overlay for depth
                Rectangle().fill(.ultraThinMaterial).ignoresSafeArea().opacity(0.6)
            }

            VStack(spacing: 28) {
                // MARK: - Header + Meta
                VStack(spacing: 10) {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Focus Mode").font(.subheadline).foregroundColor(.secondary)
                            Text(task.title).font(.title).bold().foregroundColor(.primary).lineLimit(2)
                        }

                        Spacer()

                        // emoji + priority badge
                        VStack(spacing: 8) {
                            Text(task.emoji)
                                .font(.system(size: 34))
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemBackground)))
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 4)

                            Text(task.priority.rawValue.capitalized)
                                .font(.caption2).bold()
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(RoundedRectangle(cornerRadius: 12).fill(task.priority == .high ? Color("PriorityHigh") : (task.priority == .medium ? Color("PriorityMedium") : Color("PriorityLow"))))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 18)

                // MARK: - Circular Timer Ring
                // MARK: - Circular Timer Ring (enhanced)
                ZStack {
                    Circle()
                        .stroke(Color(UIColor.separator).opacity(0.6), lineWidth: 18)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [Color("Primary"), Color("Secondary"), Color.purple]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .shadow(color: Color("Primary").opacity(0.25), radius: 8, x: 0, y: 6)
                        .animation(.easeInOut(duration: 0.4), value: progress)

                    VStack(spacing: 6) {
                        Text(timeString(from: remaining))
                            .font(.system(size: 56, design: .rounded))
                            .monospacedDigit()
                            .bold()
                        Text(running ? "In flow — keep going" : "Ready to focus")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 260, height: 260)
                .padding(.vertical, 6)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.12), radius: 14, x: 0, y: 8)

                // MARK: - Slider (duration)
                VStack(spacing: 8) {
                    HStack {
                        Text("Duration").font(.subheadline).foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(duration/60)) min").font(.subheadline).bold()
                    }

                    // Use system Slider (liquid glass background) per request
                    Slider(value: Binding(
                        get: { duration / 60 },
                        set: { duration = $0 * 60; remaining = duration; Haptics.selection() }
                    ), in: 5...60, step: 1)
                    .tint(Color("Primary"))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 6)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 22)
                }

                // MARK: - Buttons
                HStack(spacing: 14) {
                    Button(action: toggle) {
                        HStack {
                            Image(systemName: running ? "pause.fill" : "play.fill")
                            Text(running ? "Pause" : "Start")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color("Primary")))
                        .foregroundColor(.white)
                        .shadow(color: Color("Primary").opacity(0.25), radius: 8, x: 0, y: 6)
                    }

                    Button(action: reset) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color(UIColor.systemBackground)))
                            .foregroundColor(.primary)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(UIColor.separator)))
                    }
                }
                .padding(.horizontal)

                Spacer()

                // MARK: - Motivational Quote
                Text("“\(quote)”")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .transition(.opacity.combined(with: .scale))

                // MARK: - Done Button
                // MARK: - Premium Mark Done Button
                Button(action: {
                    Haptics.notification(.success)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { markPressed = true }
                    finish()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                        Text("Mark as Done")
                            .font(.headline).fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.green, Color("Primary")]), startPoint: .leading, endPoint: .trailing)
                            .cornerRadius(16)
                            .shadow(color: Color.green.opacity(0.28), radius: 12, x: 0, y: 8)
                    )
                    .scaleEffect(markPressed ? 0.96 : 1.0)
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 40)
            }

            // MARK: - Confetti Overlay
            if showConfetti {
                ConfettiView()
                    .transition(.scale)
            }
        }
        .onDisappear {
            timerCancellable?.cancel()
        }
    }

    // MARK: - Timer Logic
    private func toggle() {
        if running {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        running = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if remaining > 0 {
                    remaining -= 1
                } else {
                    timerCancellable?.cancel()
                    running = false
                    showCelebration()
                }
            }
    }

    private func pauseTimer() {
        running = false
        timerCancellable?.cancel()
    }

    private func reset() {
        pauseTimer()
        remaining = duration
        Haptics.selection()
    }

    private func finish() {
        var updated = task
        updated.isDone = true
        onComplete?(updated)
        showCelebration()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func showCelebration() {
        showConfetti = true
        withAnimation(.spring()) {
            quote = FocusModeView.randomQuote()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showConfetti = false
        }
    }

    private func timeString(from seconds: TimeInterval) -> String {
        let s = Int(max(0, seconds))
        let m = s / 60
        let sec = s % 60
        return String(format: "%02d:%02d", m, sec)
    }

    // MARK: - Random Motivational Quotes
    static func randomQuote() -> String {
        let quotes = [
            "Stay consistent. Small steps build empires.",
            "Discipline beats motivation.",
            "Every minute you focus adds up.",
            "Deep work creates deep results.",
            "One task at a time. Master your flow."
        ]
        return quotes.randomElement() ?? "Stay focused!"
    }
}

// Note: use shared Haptics helper in Utils/Haptics.swift
