import Foundation
import Combine

@MainActor
final class ConferenceViewModel: ObservableObject {
    @Published private(set) var conferences: [Conference] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedArea: String?   // nil means "All"
    @Published var hideClosed = true

    // Downloads the online feed; falls back to the bundled copy when that fails
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            // Skip the phone's cache so an edit on GitHub shows up on refresh
            let request = URLRequest(url: AppConfig.conferenceFeedURL, cachePolicy: .reloadIgnoringLocalCacheData)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            conferences = try decode(data)
            errorMessage = nil
        } catch {
            loadBundledCopy()
        }
    }

    // Reads Resources/conferences.json from inside the app
    private func loadBundledCopy() {
        guard let url = Bundle.main.url(forResource: AppConfig.conferencesFile, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let saved = try? decode(data) else {
            errorMessage = "Could not load conferences."
            return
        }
        conferences = saved
        errorMessage = "Offline – showing saved list"
    }

    // Turns JSON into conferences (ISO 8601 dates) sorted by deadline
    private func decode(_ data: Data) throws -> [Conference] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Conference].self, from: data).sorted { $0.deadline < $1.deadline }
    }

    // Every area in the feed once, alphabetically, for the segmented picker
    var areas: [String] {
        Array(Set(conferences.map(\.area))).sorted()
    }

    // Open deadlines first (soonest on top), then closed ones unless hideClosed is on
    var filtered: [Conference] {
        let matches = conferences.filter { matchesSearch($0) && (selectedArea == nil || $0.area == selectedArea) }
        let open = matches.filter { $0.deadline > .now }
        guard !hideClosed else { return open }
        let closed = matches.filter { $0.deadline <= .now }.reversed()
        return open + closed
    }

    // True when the short or full name contains the search text
    private func matchesSearch(_ conference: Conference) -> Bool {
        guard !searchText.isEmpty else { return true }
        return conference.name.localizedCaseInsensitiveContains(searchText)
            || conference.fullName.localizedCaseInsensitiveContains(searchText)
    }
}
