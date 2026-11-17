import Foundation
import FirebaseFirestore

struct Team: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var name: String
    var leaderId: String
    var memberIds: [String]
    var memberNames: [String: String]   // uid : username
    var createdAt: Date
}
