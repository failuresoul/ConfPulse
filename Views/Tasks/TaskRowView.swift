import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    var onStatusTap: () -> Void = {}

    // True when the task is not done and its due date has passed
    private var isOverdue: Bool {
        task.status != .done && task.dueDate < .now
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.status == .done)
                Label(task.dueDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(isOverdue ? Color.red : Color.secondary)
            }
            Spacer()
            // Tap the chip to cycle the status
            Button(action: onStatusTap) {
                Text(task.status.title)
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundStyle(task.status.color)
                    .background(task.status.color.opacity(0.15), in: Capsule())
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    List {
        TaskRowView(task: TaskItem(
            id: nil, title: "Write related work", details: "",
            assignedTo: "u1", assignedToName: "alice", status: .doing,
            dueDate: .now.addingTimeInterval(3 * 86_400), createdAt: .now))
        TaskRowView(task: TaskItem(
            id: nil, title: "Run baselines", details: "",
            assignedTo: "u2", assignedToName: "bob", status: .todo,
            dueDate: .now.addingTimeInterval(-86_400), createdAt: .now))
    }
}
