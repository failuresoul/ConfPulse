import Foundation

struct Conference: Codable, Identifiable, Hashable {
    let name: String        // acronym, e.g. "CVPR"
    let fullName: String
    let area: String        // ML, CV, NLP, Robotics or Systems
    let deadline: Date      // paper submission deadline
    let location: String
    let website: String

    // Not stored in the JSON: name + deadline is unique enough for SwiftUI lists
    var id: String { "\(name)-\(deadline.timeIntervalSince1970)" }
}
