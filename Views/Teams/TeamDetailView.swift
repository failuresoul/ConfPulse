import SwiftUI

struct TeamDetailView: View {
    let team: Team
    @ObservedObject var viewModel: TeamViewModel
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAddMember = false

    // Latest copy of this team from the view model (changes after adding/removing members)
    private var current: Team {
        viewModel.teams.first { $0.id == team.id } ?? team
    }

    // True when the signed-in user leads this team
    private var isLeader: Bool {
        current.leaderId == auth.currentUser?.id
    }

    // Member uids sorted by username
    private var sortedMemberIds: [String] {
        current.memberIds.sorted { username(of: $0) < username(of: $1) }
    }

    var body: some View {
        List {
            Section("Workspace") {
                NavigationLink { TaskListView(team: current) } label: {
                    Label("Tasks", systemImage: "checklist")
                }
                NavigationLink { LinkListView(team: current) } label: {
                    Label("Links", systemImage: "link")
                }
            }

            Section("Members (\(current.memberIds.count))") {
                ForEach(sortedMemberIds, id: \.self) { uid in
                    memberRow(uid)
                }
                if isLeader {
                    Button { showAddMember = true } label: {
                        Label("Add member", systemImage: "person.badge.plus")
                    }
                }
            }

            if let message = viewModel.errorMessage {
                Text(message).foregroundStyle(.red)
            }

            if !isLeader {
                Section {
                    Button("Leave team", role: .destructive) { Task { await leave() } }
                }
            }
        }
        .navigationTitle(current.name)
        .sheet(isPresented: $showAddMember) {
            AddMemberView(team: current, viewModel: viewModel)
        }
    }

    // Username stored in the team for a uid
    private func username(of uid: String) -> String {
        current.memberNames[uid] ?? "unknown"
    }

    // One member line; the leader can swipe to remove other members
    private func memberRow(_ uid: String) -> some View {
        HStack {
            Text("@\(username(of: uid))")
            Spacer()
            if uid == current.leaderId {
                Text("Leader")
                    .font(.caption.bold())
                    .foregroundStyle(Theme.pulse)
            }
        }
        .swipeActions {
            if isLeader && uid != current.leaderId {
                Button("Remove", role: .destructive) {
                    Task { await viewModel.removeMember(uid: uid, from: current) }
                }
            }
        }
    }

    // Removes the signed-in user from the team and goes back to the list
    private func leave() async {
        guard let uid = auth.currentUser?.id else { return }
        await viewModel.removeMember(uid: uid, from: current)
        dismiss()
    }
}
