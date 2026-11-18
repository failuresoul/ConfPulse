import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @StateObject private var teamViewModel = TeamViewModel()

    var body: some View {
        TabView {
            ConferenceListView()
                .tabItem { Label("Conferences", systemImage: "calendar.badge.clock") }
            TeamListView()
                .tabItem { Label("Teams", systemImage: "person.3") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle") }
        }
        // Shared with every team screen (list, detail, sheets)
        .environmentObject(teamViewModel)
        // Start listening once the profile (and so my uid) is known
        .task(id: auth.currentUser?.id) {
            if let uid = auth.currentUser?.id {
                teamViewModel.start(uid: uid)
            }
        }
        // The tabs only disappear on log out, so stop listening then
        .onDisappear { teamViewModel.stop() }
    }
}
