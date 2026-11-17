import Foundation
import Combine

@MainActor
final class ConferenceViewModel: ObservableObject {
    @Published private(set) var conferences: [Conference] = []
    @Published var searchText = ""
    @Published var showPast = false
    @Published private(set) var errorMessage: String?

    // Reads conferences.json from the app bundle once and sorts it by deadline
    func load() {
        guard conferences.isEmpty else { return }
        guard let url = Bundle.main.url(forResource: AppConfig.conferencesFile, withExtension: "json") else {
            errorMessage = "conferences.json is missing from the app bundle."
            return
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let data = try Data(contentsOf: url)
            conferences = try decoder.decode([Conference].self, from: data).sorted { $0.deadline < $1.deadline }
        } catch {
            errorMessage = "Could not read conferences: \(error.localizedDescription)"
        }
    }

    // Upcoming deadlines first (soonest on top), then closed ones when showPast is on
    var filtered: [Conference] {
        let matches = conferences.filter(matchesSearch)
        let upcoming = matches.filter { $0.deadline > .now }
        guard showPast else { return upcoming }
        let closed = matches.filter { $0.deadline <= .now }.reversed()
        return upcoming + closed
    }

    // True when the name, full name or area contains the search text
    private func matchesSearch(_ conference: Conference) -> Bool {
        guard !searchText.isEmpty else { return true }
        return [conference.name, conference.fullName, conference.area]
            .contains { $0.localizedCaseInsensitiveContains(searchText) }
    }
}
