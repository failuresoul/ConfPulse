import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class LinkViewModel: ObservableObject {
    @Published private(set) var links: [LinkItem] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let teamId: String
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // Remembers which team's links this list shows
    init(teamId: String) {
        self.teamId = teamId
    }

    // Reference to teams/{teamId}/links
    private var linksRef: CollectionReference {
        db.collection(AppConfig.teamsCollection).document(teamId).collection(AppConfig.linksCollection)
    }

    // Listens live to every link of the team
    func start() {
        guard listener == nil, !teamId.isEmpty else { return }
        isLoading = true
        listener = linksRef.addSnapshotListener { [weak self] snapshot, error in
            let links = snapshot?.documents.compactMap { try? $0.data(as: LinkItem.self) } ?? []
            let message = error?.localizedDescription
            Task { @MainActor in
                self?.apply(links: links, error: message)
            }
        }
    }

    // Removes the listener when the list leaves the screen
    func stop() {
        listener?.remove()
        listener = nil
    }

    // Stores the newest snapshot, newest link first
    private func apply(links: [LinkItem], error: String?) {
        isLoading = false
        if let error {
            errorMessage = error
            return
        }
        self.links = links.sorted { $0.createdAt > $1.createdAt }
    }

    // Checks the input and saves a new link added by me
    func addLink(title: String, url: String, type: LinkType, me: AppUser) async -> Bool {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else {
            errorMessage = "Please enter a title."
            return false
        }
        guard let cleanURL = normalized(url) else {
            errorMessage = "That is not a valid web address."
            return false
        }
        let link = LinkItem(id: nil, title: cleanTitle, url: cleanURL, type: type,
                            addedBy: me.id, addedByName: me.username, createdAt: .now)
        do {
            let data = try Firestore.Encoder().encode(link)
            _ = try await linksRef.addDocument(data: data)
            return true   // the listener adds it to the list
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
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Adds "https://" when missing; nil if URL(string:) cannot read it or it has no real host
    private func normalized(_ text: String) -> String? {
        var value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = value.lowercased()
        if !lower.hasPrefix("http://") && !lower.hasPrefix("https://") {
            value = "https://" + value
        }
        guard !value.contains(" "),
              let url = URL(string: value),
              let host = url.host(), host.contains(".") else { return nil }
        return value
    }
}
