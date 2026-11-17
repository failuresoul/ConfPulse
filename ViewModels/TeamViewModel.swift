import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class TeamViewModel: ObservableObject {
    @Published private(set) var teams: [Team] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var userId = ""

    // Reference to the top-level teams collection
    private var teamsRef: CollectionReference {
        db.collection(AppConfig.teamsCollection)
    }

    // Loads every team the user is a member of, newest first
    func loadTeams(for uid: String) async {
        guard !uid.isEmpty else { return }
        userId = uid
        isLoading = true
        defer { isLoading = false }
        do {
            let snapshot = try await teamsRef.whereField("memberIds", arrayContains: uid).getDocuments()
            teams = snapshot.documents
                .compactMap { try? $0.data(as: Team.self) }
                .sorted { $0.createdAt > $1.createdAt }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Creates a team with the given user as leader and first member
    func createTeam(name: String, leader: AppUser) async -> Bool {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else {
            errorMessage = "Please enter a team name."
            return false
        }
        let team = Team(id: nil, name: cleanName, leaderId: leader.id,
                        memberIds: [leader.id], memberNames: [leader.id: leader.username],
                        createdAt: .now)
        do {
            let data = try Firestore.Encoder().encode(team)
            _ = try await teamsRef.addDocument(data: data)
            await loadTeams(for: leader.id)
            return true
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
            await loadTeams(for: userId)
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
            await loadTeams(for: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
