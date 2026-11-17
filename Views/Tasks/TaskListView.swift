import SwiftUI

struct TaskListView: View {
    let team: Team
    @EnvironmentObject private var auth: AuthViewModel
    @StateObject private var viewModel = TaskViewModel()
    @State private var showAdd = false

    // uid of the signed-in user
    private var myId: String { auth.currentUser?.id ?? "" }

    var body: some View {
        List {
            Toggle("Only my tasks", isOn: $viewModel.onlyMine)

            if let message = viewModel.errorMessage {
                Text(message).foregroundStyle(.red)
            }

            ForEach(TaskStatus.allCases, id: \.self) { status in
                let items = viewModel.tasks(with: status, for: myId)
                Section("\(status.title) (\(items.count))") {
                    ForEach(items) { task in
                        TaskRowView(task: task)
                            .contextMenu { statusMenu(for: task) }
                            .swipeActions(edge: .leading) {
                                if canEdit(task), let next = task.status.next {
                                    Button(next.title) {
                                        Task { await viewModel.updateStatus(task, to: next) }
                                    }
                                    .tint(next.color)
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                if team.leaderId == myId {
                                    Button("Delete", role: .destructive) {
                                        Task { await viewModel.delete(task) }
                                    }
                                }
                            }
                    }
                }
            }
        }
        .navigationTitle("Tasks")
        .toolbar {
            Button { showAdd = true } label: { Image(systemName: "plus") }
        }
        .sheet(isPresented: $showAdd) {
            AddTaskView(team: team, viewModel: viewModel)
        }
        .refreshable { await viewModel.load(teamId: team.id ?? "") }
        .task { await viewModel.load(teamId: team.id ?? "") }
    }

    // The assignee and the team leader may change a task's status
    private func canEdit(_ task: TaskItem) -> Bool {
        task.assignedTo == myId || team.leaderId == myId
    }

    // Long-press menu to move a task to any status
    @ViewBuilder
    private func statusMenu(for task: TaskItem) -> some View {
        if canEdit(task) {
            ForEach(TaskStatus.allCases, id: \.self) { status in
                Button(status.title) {
                    Task { await viewModel.updateStatus(task, to: status) }
                }
            }
        }
    }
}
