import SwiftUI

struct LinkListView: View {
    let team: Team
    private let myUid: String
    @StateObject private var viewModel: LinkViewModel
    @Environment(\.openURL) private var openURL
    @State private var showAdd = false

    // Builds the view model for this team and remembers who is looking
    init(team: Team, myUid: String) {
        self.team = team
        self.myUid = myUid
        _viewModel = StateObject(wrappedValue: LinkViewModel(teamId: team.id ?? ""))
    }

    var body: some View {
        List {
            if let message = viewModel.errorMessage {
                Text(message).foregroundStyle(.red)
            }

            ForEach(viewModel.links) { link in
                linkRow(link)
                    .swipeActions {
                        // Only the person who added it, or the leader, may delete
                        if link.addedBy == myUid || team.leaderId == myUid {
                            Button("Delete", role: .destructive) {
                                Task { await viewModel.delete(link) }
                            }
                        }
                    }
            }
        }
        .overlay {
            if viewModel.links.isEmpty && !viewModel.isLoading {
                ContentUnavailableView("No links yet", systemImage: "link",
                                       description: Text("Tap + to share a paper, blog or Overleaf project."))
            }
        }
        .toolbar {
            Button { showAdd = true } label: { Image(systemName: "plus") }
        }
        .sheet(isPresented: $showAdd) {
            AddLinkView(viewModel: viewModel)
        }
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
    }

    // Row with the type icon, title and host name; tapping opens the link
    private func linkRow(_ link: LinkItem) -> some View {
        Button {
            if let url = URL(string: link.url) { openURL(url) }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: link.type.symbol)
                    .font(.title3)
                    .foregroundStyle(Theme.pulse)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(link.title)
                        .font(.headline)
                    Text(URL(string: link.url)?.host() ?? link.url)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
