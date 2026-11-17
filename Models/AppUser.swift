import Foundation

struct AppUser: Codable, Identifiable, Hashable {
    let id: String          // Firebase Auth uid, also the document ID in users/{uid}
    var username: String    // lowercase and unique
    var email: String
    var createdAt: Date
}
