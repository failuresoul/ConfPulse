import SwiftUI

struct TaskListView: View {
    let team: Team
    @StateObject private var viewModel: TaskViewModel
    @State private var showAdd = false

    // Builds the view model for this team and the signed-in user
    init(team: Team, myUid: String) {
        self.team = team
        _viewModel = StateObject(wrappedValue: TaskViewModel(
            teamId: team.id ?? "", myUid: myUid, isLeader: team.leaderId == myUid))
    }

    var body: some View {
        List {
            if let message = viewModel.errorMessage {
                Text(message).foregroundStyle(.red)
            }

            if viewModel.isLeader {
                // Leader: one section per member
                ForEach(viewModel.assigneeNames, id: \.self) { name in
                    Section("@\(name)") {
                        ForEach(viewModel.tasks(assignedTo: name)) { task in
                            row(task)
                        }
                    }
                }
            } else {
                Section("My tasks") {
                    ForEach(viewModel.tasks) { task in
                        row(task)
                    }
                }
            }
        }
        .overlay {
            if viewModel.tasks.isEmpty && !viewModel.isLoading {
                ContentUnavailableView("No tasks", systemImage: "checklist",
                                       description: Text(viewModel.isLeader ? "Tap + to assign a task."
                                                                            : "Nothing is assigned to you yet."))
            }
        }
        .toolbar {
            if viewModel.isLeader {
                Button { showAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showAdd) {
            AddTaskView(team: team, viewModel: viewModel)
        }
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
    }

    // One task row: leader swipes left to delete, swipe right moves the status forward
    private func row(_ task: TaskItem) -> some View {
        TaskRowView(task: task)
            .swipeActions(edge: .trailing) {
                if viewModel.isLeader {
                    Button("Delete", role: .destructive) {
                        Task { await viewModel.delete(task) }
                    }
                }
            }
            .swipeActions(edge: .leading) {
                if let next = task.status.next {
                    Button(next.title) {
                        Task { await viewModel.updateStatus(task, to: next) }
                    }
                    .tint(next.color)
                }
            }
    }
}
