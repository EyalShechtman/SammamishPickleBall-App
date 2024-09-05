import SwiftUI
import FirebaseAuth

@MainActor
final class SignUpViewModel : ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var repeatPassword = "" // Add repeat password
    @Published var errorMessage: String?
    @Published var signedUp = false
    @Published var userUID: String? // Store the user's uid after sign-up
    @Published var showLogoutConfirm = false


    func signUp() {
        guard !email.isEmpty, !password.isEmpty, !repeatPassword.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        guard password == repeatPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        Task {
            do {
                let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
                print("Account created successfully")
                userUID = authDataResult.uid
                signedUp = true
            } catch let error as NSError {
                if let authErrorCode = AuthErrorCode.Code(rawValue: error.code) {
                    switch authErrorCode {
                    case .emailAlreadyInUse:
                        errorMessage = "This email is already in use."
                    case .invalidEmail:
                        errorMessage = "Invalid email format."
                    default:
                        errorMessage = "Sign-up failed: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    func logOut() {
        do {
            try AuthenticationManager.shared.signOut() // Assuming you have implemented this in your AuthenticationManager
            signedUp = false // Return to the sign-up page
        } catch {
            errorMessage = "Failed to log out: \(error.localizedDescription)"
        }
    }
}

struct SignUpView: View {
    
    @StateObject private var viewModel = SignUpViewModel()

    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .disableAutocorrection(true)
                .textContentType(.newPassword) // Disables password suggestions
                .autocapitalization(.none)     // Ensures password field doesn't auto-capitalize

            SecureField("Re-enter Password...", text: $viewModel.repeatPassword) // Repeat password field
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .disableAutocorrection(true)
                .textContentType(.newPassword) // Disables password suggestions
                .autocapitalization(.none)     // Ensures password field doesn't auto-capitalize


            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.top, 5)
            }

            Button {
                viewModel.signUp()
            } label: {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0)))
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $viewModel.signedUp) {
            OnboardingView(uid: viewModel.userUID ?? "")
                .navigationBarBackButtonHidden(true) // Hide back button after sign-up
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Log Out") {
                            viewModel.showLogoutConfirm = true
                        }
                    }
                }
            // Confirmation dialog for logout
                .confirmationDialog("Are you sure you want to log out?", isPresented: $viewModel.showLogoutConfirm, titleVisibility: .visible) {
                    Button("Log Out", role: .destructive) {
                        viewModel.logOut() // Call the log-out function
                    }
                    Button("Cancel", role: .cancel) {}
                }
        }
    }
}

#Preview {
    SignUpView()
}
