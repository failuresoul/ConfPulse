import Foundation

enum AppConfig {
    // Firestore collection names (must match the database layout)
    static let usersCollection = "users"
    static let teamsCollection = "teams"
    static let tasksCollection = "tasks"
    static let linksCollection = "links"

    // Name of the bundled conference list (Resources/conferences.json)
    static let conferencesFile = "conferences"

    // A full PulseRing means the deadline is this many days away or more
    static let countdownWindowDays = 90.0

    // Deadlines closer than this are shown in red and the ring pulses
    static let urgentDays = 7
}
