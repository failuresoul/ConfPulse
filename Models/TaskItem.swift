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

    // The following status (todo → doing → done), nil when already done
    var next: TaskStatus? {
        switch self {
        case .todo: .doing
        case .doing: .done
        case .done: nil
        }
    }
}
