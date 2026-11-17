import SwiftUI

struct AddTaskView: View {
    let team: Team
    @ObservedObject var viewModel: TaskViewModel
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var details = ""
    @State private var assignee = ""
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $title)
                    TextField("Details", text: $details, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("Assignment") {
                    Picker("Assign to", selection: $assignee) {
                        ForEach(team.memberIds, id: \.self) { uid in
                            Text("@\(team.memberNames[uid] ?? "unknown")").tag(uid)
                        }
                    }
                    DatePicker("Due", selection: $dueDate, in: Date.now..., displayedComponents: [.date, .hourAndMinute])
                }
                if let message = viewModel.errorMessage {
                    Text(message).foregroundStyle(.red)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { Task { await save() } }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
            .onAppear {
                viewModel.errorMessage = nil
                if assignee.isEmpty { assignee = auth.currentUser?.id ?? team.leaderId }
            }
        }
    }

    // Saves the task and closes the sheet on success
    private func save() async {
        isSaving = true
        let saved = await viewModel.add(title: title, details: details, assignedTo: assignee,
                                        assignedToName: team.memberNames[assignee] ?? "",
                                        dueDate: dueDate)
        isSaving = false
        if saved { dismiss() }
    }
}
