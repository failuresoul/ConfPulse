import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    // Simple checks done before contacting Firebase
    private var formProblem: String? {
        if !password.isEmpty && password.count < 6 { return "Password needs at least 6 characters." }
        if !confirmPassword.isEmpty && password != confirmPassword { return "Passwords do not match." }
        return nil
    }

    // True when every field is filled in and there is no form problem
    private var canSubmit: Bool {
        !username.isEmpty && !email.isEmpty && !password.isEmpty
            && !confirmPassword.isEmpty && formProblem == nil && !auth.isLoading
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header

                VStack(spacing: 12) {
                    TextField("Username (letters, numbers, _)", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("Password (min. 6 characters)", text: $password)
                        .textContentType(.newPassword)
                    SecureField("Confirm password", text: $confirmPassword)
                        .textContentType(.newPassword)
                }
                .textFieldStyle(.roundedBorder)
                .cardStyle()

                if let message = formProblem ?? auth.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button {
                    Task { await auth.signUp(email: email, password: password, username: username) }
                } label: {
                    Group {
                        if auth.isLoading { ProgressView() } else { Text("Create Account") }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!canSubmit)

                Button("Already have an account? Log in") {
                    auth.errorMessage = nil
                    dismiss()
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden()
        .onAppear { auth.errorMessage = nil }
    }

    // App logo, name and tagline shown at the top
    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 56))
                .foregroundStyle(Theme.pulse)
            Text("ConfPulse")
                .font(.largeTitle.bold())
            Text("Never miss a deadline as a team")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
    }
}
