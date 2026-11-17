import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class LinkViewModel: ObservableObject {
    @Published private(set) var links: [LinkItem] = []
    @Published private(set) var isLoading = false
    @Published var typeFilter: LinkType?
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var teamId = ""

    // Reference to teams/{teamId}/links
    private var linksRef: CollectionReference {
        db.collection(AppConfig.teamsCollection).document(teamId).collection(AppConfig.linksCollection)
    }

    // Links of the selected type (all links when typeFilter is nil)
    var visibleLinks: [LinkItem] {
        guard let typeFilter else { return links }
        return links.filter { $0.type == typeFilter }
    }

    // Loads all links of one team, newest first
    func load(teamId: String) async {
        guard !teamId.isEmpty else { return }
        self.teamId = teamId
        isLoading = true
        defer { isLoading = false }
        do {
            let snapshot = try await linksRef.getDocuments()
            links = snapshot.documents
                .compactMap { try? $0.data(as: LinkItem.self) }
                .sorted { $0.createdAt > $1.createdAt }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Validates and saves a new link added by the given user
    func add(title: String, url: String, type: LinkType, by user: AppUser) async -> Bool {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else {
            errorMessage = "Please enter a title."
            return false
        }
        guard let cleanURL = normalized(url) else {
            errorMessage = "That does not look like a valid web address."
            return false
        }
        let link = LinkItem(id: nil, title: cleanTitle, url: cleanURL, type: type,
                            addedBy: user.id, addedByName: user.username, createdAt: .now)
        do {
            let data = try Firestore.Encoder().encode(link)
            _ = try await linksRef.addDocument(data: data)
            await load(teamId: teamId)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // Deletes one link
    func delete(_ link: LinkItem) async {
        guard let id = link.id else { return }
        do {
            try await linksRef.document(id).delete()
            links.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Adds https:// when missing and checks the text is a real web address
    private func normalized(_ text: String) -> String? {
        var value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = value.lowercased()
        if !lower.hasPrefix("http://") && !lower.hasPrefix("https://") {
            value = "https://" + value
        }
        guard let url = URL(string: value), let host = url.host, host.contains(".") else { return nil }
        return value
    }
}
