import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var store: TaskStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var reminderMinutesBefore: Int = 10
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var board: String
    @State private var dueDate: Date? = nil
    @State private var emoji: String = "📝"
    @State private var priority: Task.Priority = .medium
    @State private var subtasks: [Subtask] = []
    @State private var newSubtask: String = ""

    var onSave: (Task) -> Void

    init(prefillBoard: String = "Personal", onSave: @escaping (Task) -> Void) {
        self._board = State(initialValue: prefillBoard)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Emoji", text: $emoji)
                    TextEditor(text: $notes).frame(minHeight: 80)
                }

                Section("Subtasks") {
                    HStack {
                        TextField("Add subtask", text: $newSubtask, onCommit: addSubtask)
                        Button(action: addSubtask) { Image(systemName: "plus.circle.fill") }
                    }
                    ForEach(subtasks) { s in
                        HStack {
                            Text(s.title)
                            Spacer()
                        }
                    }
                }

                Section("Details") {
                    Picker("Board", selection: $board) {
                        ForEach(store.boards, id: \.self) { Text($0) }
                    }
                    Stepper("Remind me \(reminderMinutesBefore) min before", value: $reminderMinutesBefore, in: 5...120, step: 5)

                    DatePicker("Due date", selection: Binding($dueDate, replacingNilWith: Date()), displayedComponents: [.date, .hourAndMinute])
                    Picker("Priority", selection: $priority) {
                        ForEach(Task.Priority.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                    }
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let new = Task(title: title.isEmpty ? "Untitled" : title,
                                       notes: notes,
                                       board: board,
                                       dueDate: dueDate,
                                       isDone: false,
                                       priority: priority,
                                       emoji: emoji,
                                       subtasks: subtasks)
                        onSave(new)
                        NotificationManager.shared.scheduleNotification(for: new, minutesBefore: reminderMinutesBefore)
                        Haptics.notification(.success)
                        presentationMode.wrappedValue.dismiss()

                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .tint(Color("Orange"))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                        .tint(Color("Teal"))
                        .tint(.secondary)
                }
            }
        }
    }

    private func addSubtask() {
        let t = newSubtask.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        subtasks.append(Subtask(title: t))
        newSubtask = ""
    }
}
