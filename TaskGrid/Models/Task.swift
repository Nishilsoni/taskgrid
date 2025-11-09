import Foundation
import SwiftUI

struct Subtask: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var isDone: Bool = false
}

struct Task: Identifiable, Codable {
    enum Priority: String, Codable, CaseIterable {
        case low, medium, high

        var colorName: String {
            switch self {
            case .low: return "PriorityLow"
            case .medium: return "PriorityMedium"
            case .high: return "PriorityHigh"
            }
        }

        var color: Color {
            Color(colorName)
        }
    }

    var id: UUID = UUID()
    var title: String
    var notes: String?
    var board: String = "Personal"
    var dueDate: Date?
    var isDone: Bool = false
    var priority: Priority = .medium
    var emoji: String = "📝"
    var createdAt: Date = Date()
    var subtasks: [Subtask] = []

    var completedSubtaskRatio: Double {
        guard !subtasks.isEmpty else { return isDone ? 1.0 : 0.0 }
        let done = subtasks.filter { $0.isDone }.count
        return Double(done) / Double(subtasks.count)
    }
}
