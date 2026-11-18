import SwiftUI

struct LinkListView: View {
    let team: Team
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel = LinkViewModel()
    @State private var showAdd = false

    // uid of the signed-in user
    private var myId: String { auth.currentUser?.id ?? "" }

    var body: some View {
        List {
            Picker("Type", selection: $viewModel.typeFilter) {
                Text("All").tag(LinkType?.none)
                ForEach(LinkType.allCases, id: \.self) { type in
                    Image(systemName: type.symbol).tag(LinkType?.some(type))
                }
            }
            .pickerStyle(.segmented)

            if let message = viewModel.errorMessage {
                Text(message).foregroundStyle(.red)
            }

            ForEach(viewModel.visibleLinks) { link in
                linkRow(link)
                    .swipeActions {
                        if link.addedBy == myId || team.leaderId == myId {
                            Button("Delete", role: .destructive) {
                                Task { await viewModel.delete(link) }
                            }
                        }
                    }
            }
        }
        .toolbar {
            Button { showAdd = true } label: { Image(systemName: "plus") }
        }
        .sheet(isPresented: $showAdd) {
            AddLinkView(viewModel: viewModel)
        }
        .overlay {
            if viewModel.visibleLinks.isEmpty && !viewModel.isLoading {
                ContentUnavailableView("No links", systemImage: "link",
                                       description: Text("Tap + to share a paper, blog or Overleaf project."))
            }
        }
        .refreshable { await viewModel.load(teamId: team.id ?? "") }
        .task { await viewModel.load(teamId: team.id ?? "") }
    }

    // One link: icon, title, address and who added it; tapping opens it in Safari
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
                    Text(URL(string: link.url)?.host ?? link.url)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Added by @\(link.addedByName)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
