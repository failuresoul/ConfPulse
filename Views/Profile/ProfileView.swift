import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let user = auth.currentUser {
                        VStack(spacing: 8) {
                            Text(user.username.prefix(1).uppercased())
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)
                                .frame(width: 80, height: 80)
                                .background(Theme.pulse, in: Circle())
                            Text("@\(user.username)")
                                .font(.title2.bold())
                            Text(user.email)
                                .foregroundStyle(.secondary)
                            Text("Member since \(user.createdAt.formatted(date: .long, time: .omitted))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .cardStyle()
                    } else {
                        ProgressView("Loading profile…")
                    }

                    Button(role: .destructive) {
                        auth.signOut()
                    } label: {
                        Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .controlSize(.large)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
        }
    }
}
