import Foundation
import SwiftUI
import Combine

final class TaskStore: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var boards: [String] = ["Personal", "Work", "Ideas"]

    private let storage = Storage(filename: "tasks.json")
    private var cancellables = Set<AnyCancellable>()

    init() {
        load()
        $tasks
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.save() }
            .store(in: &cancellables)
        $boards
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.save() }
            .store(in: &cancellables)
    }

    private struct AppData: Codable {
        var tasks: [Task]
        var boards: [String]
    }

    // CRUD
    func add(_ task: Task) {
        tasks.insert(task, at: 0)
        if !boards.contains(task.board) { boards.append(task.board) }
    }

    func update(_ task: Task) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx] = task
    }

    func remove(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
    }

    func tasks(for board: String) -> [Task] {
        tasks.filter { $0.board == board }
            .sorted {
                // high priority first, then due date
                if $0.priority != $1.priority { return $0.priority.rawValue > $1.priority.rawValue }
                let d0 = $0.dueDate ?? Date.distantFuture
                let d1 = $1.dueDate ?? Date.distantFuture
                return d0 < d1
            }
    }

    // Remove a board and reassign tasks belonging to it to another existing board (or default)
    func removeBoard(_ name: String) {
        // remove board from list
        boards.removeAll { $0 == name }

        // determine new board to assign tasks to
        let newBoard = boards.first ?? "Personal"

        // reassign tasks that belonged to removed board
        for idx in tasks.indices {
            if tasks[idx].board == name {
                tasks[idx].board = newBoard
            }
        }
    }

    // Persistence
    private func save() {
        do {
            let data = AppData(tasks: tasks, boards: boards)
            try storage.save(data)
        } catch {
            print("Save error:", error)
        }
    }

    private func load() {
        do {
            // first try loading combined app data
            let saved: AppData = try storage.load()
            tasks = saved.tasks
            boards = saved.boards
        } catch {
            // fallback: try older format (tasks only)
            do {
                tasks = try storage.load()
            } catch {
                print("No saved tasks, creating sample.")
                tasks = [
                    Task(title: "Welcome to TaskGrid!", notes: "Tap to expand, try Focus Mode, and add subtasks.", board: "Personal", priority: .high, emoji: "🔥", subtasks: [Subtask(title: "Tap card"), Subtask(title: "Try Focus Mode")]),
                    Task(title: "Plan portfolio site", notes: "Sketch Neo-Brutal design", board: "Work", priority: .medium, emoji: "💻")
                ]
            }
        }
    }
}
