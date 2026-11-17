import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var auth: AuthViewModel

    var body: some View {
        Group {
            if auth.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .animation(.default, value: auth.isLoggedIn)
    }
}
