import SwiftUI

struct TaskRowView: View {
    let task: TaskItem

    // True when the task is not done and its due date has passed
    private var isOverdue: Bool {
        task.status != .done && task.dueDate < .now
    }

    // Due date plus time left, e.g. "Mar 3, 2027 · 4d 2h"
    private var dueText: String {
        let date = task.dueDate.formatted(date: .abbreviated, time: .omitted)
        if task.status == .done { return date }
        return isOverdue ? "\(date) · Overdue" : "\(date) · \(Countdown(to: task.dueDate).shortText)"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(task.status.color)
                .frame(width: 10, height: 10)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.status == .done)
                if !task.details.isEmpty {
                    Text(task.details)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                HStack {
                    Label("@\(task.assignedToName)", systemImage: "person")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Label(dueText, systemImage: "calendar")
                        .foregroundStyle(isOverdue ? Color.red : Color.secondary)
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        TaskRowView(task: TaskItem(
            id: nil, title: "Write related work", details: "Cover the last three years of papers.",
            assignedTo: "u1", assignedToName: "alice", status: .doing,
            dueDate: .now.addingTimeInterval(3 * 86_400), createdAt: .now))
    }
}
