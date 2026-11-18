import SwiftUI

struct AddMemberView: View {
    let team: Team
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var viewModel: TeamViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var foundUser: AppUser?
    @State private var isBusy = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    TextField("Username", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.search)
                        .onSubmit { Task { await search() } }
                    Button("Search") { Task { await search() } }
                        .buttonStyle(.bordered)
                        .disabled(searchText.trimmingCharacters(in: .whitespaces).isEmpty || isBusy)
                }

                if isBusy {
                    ProgressView()
                }

                if let message = viewModel.errorMessage {
                    Label(message, systemImage: "exclamationmark.circle")
                        .foregroundStyle(.orange)
                }

                if let user = foundUser {
                    resultCard(user)
                }

                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            // Keep the search text lowercase and forget an old result while typing
            .onChange(of: searchText) { _, newValue in
                searchText = newValue.lowercased()
                foundUser = nil
            }
            .onAppear { viewModel.errorMessage = nil }
        }
    }

    // Card for the user that was found, with an Add button
    private func resultCard(_ user: AppUser) -> some View {
        HStack(spacing: 12) {
            Text(user.username.prefix(1).uppercased())
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Theme.pulse, in: Circle())
            Text("@\(user.username)")
                .font(.headline)
            Spacer()
            Button("Add") { Task { await add(user) } }
                .buttonStyle(.borderedProminent)
                .disabled(isBusy)
        }
        .cardStyle()
    }

    // Runs the username search and keeps the result (or nil with a message)
    private func search() async {
        isBusy = true
        foundUser = await viewModel.searchUser(username: searchText, for: team,
                                               myId: auth.currentUser?.id ?? "")
        isBusy = false
    }

    // Adds the found user to the team and closes the sheet on success
    private func add(_ user: AppUser) async {
        isBusy = true
        let added = await viewModel.addMember(user, to: team)
        isBusy = false
        if added { dismiss() }
    }
}
