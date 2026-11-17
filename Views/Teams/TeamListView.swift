import SwiftUI

struct TeamListView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @StateObject private var viewModel = TeamViewModel()
    @State private var showCreate = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if let message = viewModel.errorMessage {
                        Text(message).foregroundStyle(.red)
                    }
                    ForEach(viewModel.teams) { team in
                        NavigationLink(value: team) {
                            teamCard(team)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Teams")
            .navigationDestination(for: Team.self) { team in
                TeamDetailView(team: team, viewModel: viewModel)
            }
            .toolbar {
                Button { showCreate = true } label: { Image(systemName: "plus") }
            }
            .sheet(isPresented: $showCreate) {
                CreateTeamView(viewModel: viewModel)
            }
            .overlay {
                if viewModel.teams.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView("No teams yet", systemImage: "person.3",
                                           description: Text("Tap + to create a team, or ask a leader to add you."))
                }
            }
            .refreshable { await reload() }
            .task { await reload() }
        }
    }

    // Fetches the teams of the signed-in user
    private func reload() async {
        await viewModel.loadTeams(for: auth.currentUser?.id ?? "")
    }

    // Card with the team name, member count and a Leader badge
    private func teamCard(_ team: Team) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.headline)
                Text(team.memberIds.count == 1 ? "1 member" : "\(team.memberIds.count) members")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if team.leaderId == auth.currentUser?.id {
                Text("Leader")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundStyle(Theme.pulse)
                    .background(Theme.pulse.opacity(0.15), in: Capsule())
            }
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .cardStyle()
    }
}
