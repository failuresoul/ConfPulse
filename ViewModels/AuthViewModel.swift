import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var currentUser: AppUser?
    @Published private(set) var isLoggedIn = false
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    // Restores a saved Firebase session so the user stays logged in after a restart
    init() {
        if let uid = Auth.auth().currentUser?.uid {
            isLoggedIn = true
            Task { await loadProfile(uid: uid) }
        }
    }

    // Creates the account, checks the username is free, then saves users/{uid}
    func signUp(email: String, password: String, username: String) async {
        let name = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard name.range(of: "^[a-z0-9_]{3,20}$", options: .regularExpression) != nil else {
            errorMessage = "Username must be 3–20 characters: letters, numbers or underscore."
            return
        }
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            // The Auth account is created FIRST because the security rules only let
            // signed-in users read the users collection. Before this line we are not
            // signed in, so the username query below would be rejected.
            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let result = try await Auth.auth().createUser(withEmail: cleanEmail, password: password)

            if try await isUsernameTaken(name) {
                try await result.user.delete()   // undo: remove the account we just made
                errorMessage = "Username already taken"
                return
            }

            let user = AppUser(id: result.user.uid, username: name, email: cleanEmail, createdAt: .now)
            try db.collection(AppConfig.usersCollection).document(user.id).setData(from: user)
            currentUser = user
            isLoggedIn = true
        } catch {
            errorMessage = friendlyMessage(for: error)
        }
    }

    // Signs in with email and password, then loads the user's profile
    func signIn(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let result = try await Auth.auth().signIn(withEmail: cleanEmail, password: password)
            isLoggedIn = true
            await loadProfile(uid: result.user.uid)
        } catch {
            errorMessage = friendlyMessage(for: error)
        }
    }

    // Signs out of Firebase and clears the local user
    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            isLoggedIn = false
        } catch {
            errorMessage = friendlyMessage(for: error)
        }
    }

    // Reads users/{uid} into currentUser; signs out if the profile cannot be loaded
    func loadProfile(uid: String) async {
        do {
            let snapshot = try await db.collection(AppConfig.usersCollection).document(uid).getDocument()
            guard snapshot.exists else {
                signOut()
                errorMessage = "No profile found for this account. Please sign up again."
                return
            }
            currentUser = try snapshot.data(as: AppUser.self)
        } catch {
            signOut()
            errorMessage = friendlyMessage(for: error)
        }
    }

    // Returns true when another users document already has this username
    private func isUsernameTaken(_ username: String) async throws -> Bool {
        let snapshot = try await db.collection(AppConfig.usersCollection)
            .whereField("username", isEqualTo: username)
            .limit(to: 1)
            .getDocuments()
        return !snapshot.documents.isEmpty
    }

    // Turns a Firebase Auth error into a short message a user understands
    private func friendlyMessage(for error: Error) -> String {
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain, let code = AuthErrorCode(rawValue: nsError.code) else {
            return error.localizedDescription
        }
        switch code {
        case .wrongPassword, .invalidCredential, .userNotFound:
            return "Wrong email or password."
        case .emailAlreadyInUse:
            return "An account with this email already exists."
        case .weakPassword:
            return "Password is too weak. Use at least 6 characters."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .networkError:
            return "No internet connection. Please try again."
        default:
            return error.localizedDescription
        }
    }
}
