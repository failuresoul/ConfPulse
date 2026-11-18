import SwiftUI

struct ConferenceListView: View {
    @StateObject private var viewModel = ConferenceViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    filters

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
            .searchable(text: $viewModel.searchText, prompt: "Search by name")
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

    // Area picker (All + each area) and the "Hide closed" switch
    private var filters: some View {
        VStack(spacing: 8) {
            Picker("Area", selection: $viewModel.selectedArea) {
                Text("All").tag(String?.none)
                ForEach(viewModel.areas, id: \.self) { area in
                    Text(area).tag(String?.some(area))
                }
            }
            .pickerStyle(.segmented)

            Toggle("Hide closed", isOn: $viewModel.hideClosed)
                .font(.subheadline)
        }
    }
}

#Preview {
    ConferenceListView()
}
