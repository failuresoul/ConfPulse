import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    // Simple checks done before contacting Firebase
    private var formProblem: String? {
        if password.count < 6 && !password.isEmpty { return "Password needs at least 6 characters." }
        if !confirmPassword.isEmpty && password != confirmPassword { return "Passwords do not match." }
        return nil
    }

    // True when every field is filled in and formProblem is nil
    private var canSubmit: Bool {
        !username.isEmpty && !email.isEmpty && !password.isEmpty
            && !confirmPassword.isEmpty && formProblem == nil && !auth.isLoading
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    TextField("Username (a–z, 0–9, _)", text: $username)
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
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Create Account")
        .onAppear { auth.errorMessage = nil }
    }
}
