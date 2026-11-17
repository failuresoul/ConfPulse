import Foundation

struct Conference: Codable, Identifiable, Hashable {
    let id: String          // short key, e.g. "cvpr2027"
    let name: String        // acronym, e.g. "CVPR"
    let fullName: String
    let area: String        // e.g. "Computer Vision"
    let location: String
    let deadline: Date      // paper submission deadline
    let startDate: Date
    let website: String
}
