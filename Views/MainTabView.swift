import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ConferenceListView()
                .tabItem { Label("Conferences", systemImage: "calendar.badge.clock") }
            TeamListView()
                .tabItem { Label("Teams", systemImage: "person.3") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle") }
        }
    }
}
