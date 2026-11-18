import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class TeamViewModel: ObservableObject {
    @Published private(set) var teams: [Team] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // Reference to the top-level teams collection
    private var teamsRef: CollectionReference {
        db.collection(AppConfig.teamsCollection)
    }

    // Listens live to every team whose memberIds contains uid
    func start(uid: String) {
        stop()
        isLoading = true
        listener = teamsRef
            .whereField("memberIds", arrayContains: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                let teams = snapshot?.documents.compactMap { try? $0.data(as: Team.self) } ?? []
                let message = error?.localizedDescription
                Task { @MainActor in
                    self?.apply(teams: teams, error: message)
                }
            }
    }

    // Removes the listener and clears the list (called on log out)
    func stop() {
        listener?.remove()
        listener = nil
        teams = []
    }

    // Stores the newest snapshot from the listener, newest team first
    private func apply(teams: [Team], error: String?) {
        isLoading = false
        if let error {
            errorMessage = error
            return
        }
        self.teams = teams.sorted { $0.createdAt > $1.createdAt }
    }

    // Saves a new team with me as leader and only member
    func createTeam(name: String, me: AppUser) async -> Bool {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else {
            errorMessage = "Please enter a team name."
            return false
        }
        let team = Team(id: nil, name: cleanName, leaderId: me.id,
                        memberIds: [me.id], memberNames: [me.id: me.username],
                        createdAt: .now)
        do {
            let data = try Firestore.Encoder().encode(team)
            _ = try await teamsRef.addDocument(data: data)
            return true   // the listener adds it to the list
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // Looks up a user by username and adds them to the team
    func addMember(username: String, to team: Team) async -> Bool {
        guard let teamId = team.id else { return false }
        let name = username.trimmingCharacters(in: .whitespaces).lowercased()
        do {
            let snapshot = try await db.collection(AppConfig.usersCollection)
                .whereField("username", isEqualTo: name)
                .limit(to: 1)
                .getDocuments()
            guard let user = try snapshot.documents.first?.data(as: AppUser.self) else {
                errorMessage = "No user with the username \"\(name)\"."
                return false
            }
            guard !team.memberIds.contains(user.id) else {
                errorMessage = "\(name) is already in this team."
                return false
            }
            try await teamsRef.document(teamId).updateData([
                "memberIds": FieldValue.arrayUnion([user.id]),
                "memberNames.\(user.id)": user.username
            ])
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // Removes a member (leader removing someone, or a member leaving); never the leader
    func removeMember(uid: String, from team: Team) async {
        guard let teamId = team.id, uid != team.leaderId else { return }
        do {
            try await teamsRef.document(teamId).updateData([
                "memberIds": FieldValue.arrayRemove([uid]),
                "memberNames.\(uid)": FieldValue.delete()
            ])
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
