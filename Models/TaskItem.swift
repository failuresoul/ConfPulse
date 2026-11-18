import SwiftUI
import FirebaseFirestore

struct TaskItem: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var title: String
    var details: String
    var assignedTo: String       // uid
    var assignedToName: String   // username
    var status: TaskStatus
    var dueDate: Date
    var createdAt: Date
}

enum TaskStatus: String, Codable, CaseIterable {
    case todo, doing, done

    // Label shown in pickers and rows
    var title: String {
        switch self {
        case .todo: "To Do"
        case .doing: "Doing"
        case .done: "Done"
        }
    }

    // Colour used for the status badge
    var color: Color {
        switch self {
        case .todo: .gray
        case .doing: .orange
        case .done: .green
        }
    }

    // The next status in allCases order; done wraps back to todo
    var cycled: TaskStatus {
        let all = TaskStatus.allCases
        let index = all.firstIndex(of: self) ?? 0
        return all[(index + 1) % all.count]
    }
}
