import SwiftUI

struct TeamListView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var viewModel: TeamViewModel
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
                TeamDetailView(team: team)
            }
            .toolbar {
                Button { showCreate = true } label: { Image(systemName: "plus") }
            }
            .sheet(isPresented: $showCreate) {
                CreateTeamView()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.teams.isEmpty {
                    ContentUnavailableView {
                        Label("No teams yet", systemImage: "person.3")
                    } description: {
                        Text("Create one and invite your lab mates")
                    }
                }
            }
        }
    }

    // Card with the team name, member count and a crown when I lead the team
    private func teamCard(_ team: Team) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(team.name)
                        .font(.headline)
                    if team.leaderId == auth.currentUser?.id {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.yellow)
                    }
                }
                Text(team.memberIds.count == 1 ? "1 member" : "\(team.memberIds.count) members")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .cardStyle()
    }
}
