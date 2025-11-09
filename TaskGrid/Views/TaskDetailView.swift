import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject var store: TaskStore
    @Environment(\.presentationMode) var presentationMode
    @State var task: Task
    var namespace: Namespace.ID?

    @State private var showDeleteConfirm = false
    @State private var newSubtaskTitle: String = ""
    @State private var contentAppeared = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text(task.emoji).font(.system(size: 48))
                    VStack(alignment: .leading) {
                        TextField("Title", text: $task.title).font(.title2).bold()
                        TextField("Board", text: $task.board).font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    ProgressRing(value: task.completedSubtaskRatio, size: 44, lineWidth: 6)
                }
                .padding()
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius, style: .continuous)
                            .fill(Color.white)
                        // subtle material overlay to add depth and polish
                        RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius, style: .continuous)
                            .fill(.thinMaterial)
                            .opacity(0.25)
                    }
                    .overlay(RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius).stroke(Color(UIColor.separator).opacity(0.9)))
                    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
                    .matchedGeometryEffect(id: task.id, in: namespace ?? Namespace().wrappedValue)
                )

        VStack(alignment: .leading, spacing: 12) {
                    Text("Notes").font(.headline)
                    TextEditor(text: Binding($task.notes, replacingNilWith: ""))
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.8)))
            .opacity(contentAppeared ? 1 : 0)
            .offset(y: contentAppeared ? 0 : 6)
                }.padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Subtasks").font(.headline)
                        Spacer()
                        TextField("Add", text: $newSubtaskTitle, onCommit: addSubtask)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 160)
                    }
                    ForEach($task.subtasks) { $sub in
                        HStack {
                            Button(action: { sub.isDone.toggle() }) {
                                Image(systemName: sub.isDone ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(sub.isDone ? .green : .secondary)
                            }
                            TextField("Subtask", text: $sub.title)
                            Spacer()
                            Button(role: .destructive) {
                                task.subtasks.removeAll { $0.id == sub.id }
                            } label: { Image(systemName: "trash") }
                        }
                        .padding(.vertical, 6)
                    }
                }
                .padding()

                // Custom white sections to better integrate with card detail and avoid Form's grey background
                VStack(spacing: 12) {
                    // Details card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details").font(.headline)

                        HStack {
                            Text("Priority").foregroundColor(.secondary)
                            Spacer()
                            Picker("Priority", selection: $task.priority) {
                                ForEach(Task.Priority.allCases, id: \.self) { p in Text(p.rawValue.capitalized).tag(p) }
                            }
                            .pickerStyle(.menu)
                        }

                        DatePicker("Due date", selection: Binding($task.dueDate, replacingNilWith: Date()), displayedComponents: [.date, .hourAndMinute])
                    }
                    .padding()
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius)
                                .fill(Color.white.opacity(0.85))
                            RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius)
                                .fill(.ultraThinMaterial)
                                .opacity(0.3)
                        }
                    )
                    .overlay(RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius).stroke(Color(UIColor.separator)))

                    // Toggle & actions card
                    VStack(spacing: 12) {
                            Toggle("Done", isOn: $task.isDone)
                                .onChange(of: task.isDone) { newValue in
                                    Haptics.notification(newValue ? .success : .warning)
                                }

                        HStack {
                            Button(action: saveAndDismiss) {
                                Text("Save").frame(maxWidth: .infinity)
                            }
                            .buttonStyle(AppButtonStyle(color: Color("Orange")))

                            Button(action: { showDeleteConfirm = true }) {
                                Text("Delete").frame(maxWidth: .infinity)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12).fill(Color("Red"))
                                    RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial).opacity(0.3)
                                }
                            )
                            .shadow(color: Color("Red").opacity(0.28), radius: 6, x: 0, y: 3)
                        }
                    }
                    .padding()
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius)
                                .fill(Color.white.opacity(0.85))
                            RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius)
                                .fill(.ultraThinMaterial)
                                .opacity(0.3)
                        }
                    )
                    .overlay(RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius).stroke(Color(UIColor.separator)))
                }
            }
            .padding()
            .onAppear {
                // delay content appearance slightly after the matchedGeometry expansion
                withAnimation(Theme.animationSpring.delay(0.12)) {
                    contentAppeared = true
                }
            }
        }
        .navigationTitle("Task")
            .confirmationDialog("Delete this task?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                Haptics.notification(.error)
                store.remove(task)
                presentationMode.wrappedValue.dismiss()
            }
            Button("Cancel", role: .cancel) { }
        }
        .onDisappear { store.update(task) }
    }

    private func addSubtask() {
        let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        task.subtasks.append(Subtask(title: trimmed))
        newSubtaskTitle = ""
    }

    private func saveAndDismiss() {
        store.update(task)
        NotificationManager.shared.cancelNotification(for: task)
        NotificationManager.shared.scheduleNotification(for: task, minutesBefore: 10)
        Haptics.notification(.success)
        presentationMode.wrappedValue.dismiss()
    }
}
