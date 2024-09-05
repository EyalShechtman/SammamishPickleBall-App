import SwiftUI
import FirebaseAuth

@MainActor
final class SignInEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false // New: Loading state to handle UI updates
    @Published var isSignedIn = false

    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }

        // Simple email format validation
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address."
            return
        }

        isLoading = true
        
        Task {
            do {
                _ = try await AuthenticationManager.shared.signInUser(email: email, password: password)
                print("Sign-in successful")
                // Handle successful sign-in (e.g., redirect to app)
                isLoading = false // Set loading state to false
                isSignedIn = true
            } catch let error as NSError {
                isLoading = false // Stop loading animation on error
                if let authErrorCode = AuthErrorCode.Code(rawValue: error.code) {
                    switch authErrorCode {
                    case .wrongPassword:
                        errorMessage = "Incorrect password. Please try again."
                    case .userNotFound:
                        errorMessage = "No user found with this email."
                    default:
                        errorMessage = "Incorrect Email or Password. Try Again"
                    }
                }
            }
        }
    }

    // Helper function to validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct SignInEmailView: View {

    @StateObject private var viewModel = SignInEmailViewModel()

    var body: some View {
        
        VStack {
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .autocapitalization(.none) // Avoid capitalizing email input
                .disableAutocorrection(true)

            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            

            // Display error message if there's any
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.top, 5)
            }

            // Show loading indicator when signing in
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 10)
            }

            Button {
                viewModel.signIn()
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isLoading ? Color.gray : Color(UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0))) // Disable color while loading
                    .cornerRadius(10)
            }
            .disabled(viewModel.isLoading) // Disable the button while signing in
            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $viewModel.isSignedIn) {
            AttendanceVisualView()
        }
    }
}

#Preview {
    SignInEmailView()
}
