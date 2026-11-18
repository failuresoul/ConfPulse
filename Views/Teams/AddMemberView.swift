import SwiftUI

struct AddMemberView: View {
    let team: Team
    @EnvironmentObject private var viewModel: TeamViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } footer: {
                    Text("Ask your lab mate for the username they chose at sign-up.")
                }
                if let message = viewModel.errorMessage {
                    Text(message).foregroundStyle(.red)
                }
            }
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { Task { await add() } }
                        .disabled(username.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
            .onAppear { viewModel.errorMessage = nil }
        }
    }

    // Adds the user to the team and closes the sheet on success
    private func add() async {
        isSaving = true
        let added = await viewModel.addMember(username: username, to: team)
        isSaving = false
        if added { dismiss() }
    }
}
