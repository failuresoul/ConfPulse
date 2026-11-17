import SwiftUI

struct CreateTeamView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TeamViewModel
    @State private var name = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Team name", text: $name)
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

    // Saves the team with the current user as leader, then closes the sheet
    private func create() async {
        guard let user = auth.currentUser else { return }
        isSaving = true
        let saved = await viewModel.createTeam(name: name, leader: user)
        isSaving = false
        if saved { dismiss() }
    }
}
