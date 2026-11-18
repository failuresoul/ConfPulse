import SwiftUI

struct CreateTeamView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var viewModel: TeamViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Team name, e.g. Vision Lab", text: $name)
                if let message = viewModel.errorMessage {
                    Text(message).foregroundStyle(.red)
                }
            }
            .navigationTitle("New Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { Task { await create() } }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
            .onAppear { viewModel.errorMessage = nil }
        }
    }

    // Saves the team with me as leader, then closes the sheet
    private func create() async {
        guard let me = auth.currentUser else { return }
        isSaving = true
        let saved = await viewModel.createTeam(name: name, me: me)
        isSaving = false
        if saved { dismiss() }
    }
}
