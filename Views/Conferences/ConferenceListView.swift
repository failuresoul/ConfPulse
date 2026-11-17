import SwiftUI

struct ConferenceListView: View {
    @StateObject private var viewModel = ConferenceViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if let message = viewModel.errorMessage {
                        Label(message, systemImage: "wifi.slash")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }
                    ForEach(viewModel.filtered) { conference in
                        ConferenceRowView(conference: conference)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Conferences")
            .searchable(text: $viewModel.searchText, prompt: "Name or area (ML, CV, NLP…)")
            .toolbar {
                Toggle(isOn: $viewModel.showPast) {
                    Label("Show closed", systemImage: "clock.arrow.circlepath")
                }
                .toggleStyle(.button)
            }
            .overlay {
                if viewModel.isLoading && viewModel.conferences.isEmpty {
                    ProgressView("Loading conferences…")
                } else if viewModel.filtered.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView.search
                }
            }
            .refreshable { await viewModel.load() }
            .task { await viewModel.load() }
        }
    }
}

#Preview {
    ConferenceListView()
}
