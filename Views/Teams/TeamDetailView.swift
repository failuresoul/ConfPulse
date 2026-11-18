import SwiftUI

struct TeamDetailView: View {
    let team: Team
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var viewModel: TeamViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var segment: Segment = .tasks
    @State private var showAddMember = false

    enum Segment: String, CaseIterable {
        case tasks = "Tasks"
        case links = "Links"
        case members = "Members"
    }

    // Live copy of this team from the listener (updates when members change)
    private var current: Team {
        viewModel.teams.first { $0.id == team.id } ?? team
    }

    // True when I lead this team
    private var isLeader: Bool {
        current.leaderId == auth.currentUser?.id
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Section", selection: $segment) {
                ForEach(Segment.allCases, id: \.self) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            switch segment {
            case .tasks: TaskListView(team: current, myUid: auth.currentUser?.id ?? "")
            case .links: LinkListView(team: current)
            case .members: membersList
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(current.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddMember) {
            AddMemberView(team: current)
        }
    }

    // Members sorted by username; crown for the leader, add/remove/leave actions
    private var membersList: some View {
        List {
            // member.key is the uid, member.value is the username
            ForEach(current.memberNames.sorted { $0.value < $1.value }, id: \.key) { member in
                HStack {
                    Text("@\(member.value)")
                    Spacer()
                    if member.key == current.leaderId {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.yellow)
                    }
                }
                .swipeActions {
                    if isLeader && member.key != current.leaderId {
                        Button("Remove", role: .destructive) {
                            Task { await viewModel.removeMember(uid: member.key, from: current) }
                        }
                    }
                }
            }

            if isLeader {
                Button { showAddMember = true } label: {
                    Label("Add member", systemImage: "person.badge.plus")
                }
            } else {
                Button("Leave team", role: .destructive) { Task { await leave() } }
            }

            if let message = viewModel.errorMessage {
                Text(message).foregroundStyle(.red)
            }
        }
    }

    // Removes me from the team and goes back to the list
    private func leave() async {
        guard let uid = auth.currentUser?.id else { return }
        await viewModel.removeMember(uid: uid, from: current)
        dismiss()
    }
}
