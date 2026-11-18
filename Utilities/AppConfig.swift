import Foundation

enum AppConfig {
    // Firestore collection names (must match the database layout)
    static let usersCollection = "users"
    static let teamsCollection = "teams"
    static let tasksCollection = "tasks"
    static let linksCollection = "links"

    // Online conference list (raw file in a public GitHub repo)
    static let conferenceFeedURL = URL(string: "https://raw.githubusercontent.com/failuresoul/confpulse-data/main/conferences.json")!

    // Offline copy bundled in the app (Resources/conferences.json)
    static let conferencesFile = "conferences"

    // Deadlines closer than this are red
    static let urgentDays = 7

    // Deadlines closer than this are orange
    static let warningDays = 30
}
