import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var auth: AuthViewModel

    var body: some View {
        Group {
            if !auth.isLoggedIn {
                LoginView()
            } else if auth.currentUser == nil {
                ProgressView("Loading profile…")
            } else {
                MainTabView()
            }
        }
        .animation(.default, value: auth.isLoggedIn)
    }
}
