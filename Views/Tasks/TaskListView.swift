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
            if !viewModel.tasks.isEmpty {
                pulseHeader
            }

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
                Section("My Tasks") {
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

    // "Team Pulse" ring with how many tasks are done
    private var pulseHeader: some View {
        HStack(spacing: 16) {
            PulseRing(progress: viewModel.progress)
            VStack(alignment: .leading, spacing: 4) {
                Text("Team Pulse")
                    .font(.headline)
                Text("\(viewModel.doneCount) of \(viewModel.tasks.count) tasks done")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }

    // One task row: tap the chip to cycle, swipe right to Start/Done, leader swipes left to delete
    private func row(_ task: TaskItem) -> some View {
        TaskRowView(task: task) {
            Task { await viewModel.cycleStatus(task) }
        }
        .swipeActions(edge: .leading) {
            if task.status == .todo {
                Button("Start") {
                    Task { await viewModel.updateStatus(task, to: .doing) }
                }
                .tint(TaskStatus.doing.color)
            }
            if task.status != .done {
                Button("Done") {
                    Task { await viewModel.updateStatus(task, to: .done) }
                }
                .tint(TaskStatus.done.color)
            }
        }
        .swipeActions(edge: .trailing) {
            if viewModel.isLeader {
                Button("Delete", role: .destructive) {
                    Task { await viewModel.delete(task) }
                }
            }
        }
    }
}
