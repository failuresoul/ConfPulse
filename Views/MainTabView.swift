import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ConferenceListView()
                .tabItem { Label("Conferences", systemImage: "calendar") }
            TeamListView()
                .tabItem { Label("Teams", systemImage: "person.3") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}
