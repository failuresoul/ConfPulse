import SwiftUI
import FirebaseCore

@main
struct ConfPulseApp: App {
    @StateObject private var authViewModel: AuthViewModel

    // Configures Firebase first, then creates the shared AuthViewModel
    init() {
        FirebaseApp.configure()
        _authViewModel = StateObject(wrappedValue: AuthViewModel())
    }

    // Shows ContentView and shares the AuthViewModel with every screen
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .tint(Theme.pulse)
        }
    }
}
