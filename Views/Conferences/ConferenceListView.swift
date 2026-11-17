import SwiftUI

struct ConferenceListView: View {
    @StateObject private var viewModel = ConferenceViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if let message = viewModel.errorMessage {
                        Text(message).foregroundStyle(.red)
                    }
                    ForEach(viewModel.filtered) { conference in
                        ConferenceRowView(conference: conference)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Conferences")
            .searchable(text: $viewModel.searchText, prompt: "Name or research area")
            .toolbar {
                Toggle(isOn: $viewModel.showPast) {
                    Label("Show closed", systemImage: "clock.arrow.circlepath")
                }
                .toggleStyle(.button)
            }
            .overlay {
                if viewModel.filtered.isEmpty && viewModel.errorMessage == nil {
                    ContentUnavailableView.search
                }
            }
            .onAppear { viewModel.load() }
        }
    }
}

#Preview {
    ConferenceListView()
}
