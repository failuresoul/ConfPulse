import Foundation
import FirebaseFirestore

struct LinkItem: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var title: String
    var url: String
    var type: LinkType
    var addedBy: String       // uid
    var addedByName: String   // username
    var createdAt: Date
}

enum LinkType: String, Codable, CaseIterable {
    case paper, blog, overleaf, other

    // SF Symbol shown next to the link
    var symbol: String {
        switch self {
        case .paper: "doc.text"
        case .blog: "text.bubble"
        case .overleaf: "leaf"
        case .other: "link"
        }
    }
}
