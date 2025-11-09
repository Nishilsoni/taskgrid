import SwiftUI

struct BoardView: View {
    @EnvironmentObject var store: TaskStore
    var boardName: String

    @Namespace private var cardNamespace
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var selectedTaskID: UUID? = nil
    @State private var showingFocus: Bool = false
    @State private var focusedTask: Task? = nil
    @State private var appeared = false

    private var boardTasks: [Task] {
        store.tasks(for: boardName)
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(boardTasks) { task in
                    TaskCardView(task: task, namespace: cardNamespace)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring()) { selectedTaskID = task.id }
                            Haptics.selection()
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                store.remove(task)
                                Haptics.notification(.error)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                toggleDone(task)
                                Haptics.notification(.success)
                            } label: {
                                Label(task.isDone ? "Undo" : "Done", systemImage: "checkmark")
                            }
                            .tint(.green)
                        }
                        .contextMenu {
                            Button {
                                focusedTask = task
                                showingFocus = true
                            } label: {
                                Label("Focus Mode", systemImage: "timer")
                            }
                        }
                        .modifier(AppearStaggerModifier(appeared: appeared, index: indexOfTask(task)))
                }
            }
            .padding()
        }
        .onAppear {
            // trigger staggered appearance
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                appeared = true
            }
        }
        .sheet(item: $focusedTask) { t in
            FocusModeView(task: t) { updated in
                store.update(updated)
            }
            .environmentObject(store)
        }
        .background(navigationLinkOverlay())
    }

    private func toggleDone(_ t: Task) {
        var copy = t; copy.isDone.toggle()
        store.update(copy)
        Haptics.notification(.success)
    }

    private func indexOfTask(_ task: Task) -> Int {
        // Safe because Task is Identifiable by id
        boardTasks.firstIndex(where: { $0.id == task.id }) ?? 0
    }

    @ViewBuilder
    private func navigationLinkOverlay() -> some View {
        if let id = selectedTaskID,
           let task = store.tasks.first(where: { $0.id == id }) {
            NavigationLink(
                destination: TaskDetailView(task: task, namespace: cardNamespace).environmentObject(store),
                isActive: Binding(
                    get: { selectedTaskID != nil },
                    set: { if !$0 { selectedTaskID = nil } }
                )
            ) {
                EmptyView()
            }
        } else {
            EmptyView()
        }
    }
}

private struct AppearStaggerModifier: ViewModifier {
    let appeared: Bool
    let index: Int

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 8)
            .animation(
                Animation.spring(response: 0.5, dampingFraction: 0.75)
                    .delay(Double(index) * 0.04),
                value: appeared
            )
    }
}
