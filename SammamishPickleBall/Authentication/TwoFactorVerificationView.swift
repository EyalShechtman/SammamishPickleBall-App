import SwiftUI
import Firebase
struct TwoFactorVerificationView: View {
    @State private var verificationCode: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @EnvironmentObject var authenticationManager: AuthenticationManager // Assuming this will handle the verification logic
    @Environment(\.dismiss) var dismiss // To dismiss the view after successful verification
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Two-Factor Verification")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text("Please enter the verification code sent to your registered second factor.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            TextField("Verification Code", text: $verificationCode)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .keyboardType(.numberPad)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.horizontal)
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            Button(action: verifyCode) {
                Text(isLoading ? "Verifying..." : "Verify Code")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(verificationCode.isEmpty || isLoading)
            .padding(.horizontal)
            Spacer()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
    private func verifyCode() {
        isLoading = true
        errorMessage = nil
        // TODO: Integrate with AuthenticationManager for actual Firebase 2FA verification
        // For now, simulate success or failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if verificationCode == "123456" { // Example static code for testing
                print("Verification successful!")
                isLoading = false
                dismiss() // Dismiss the view on success
                // You would typically notify the AuthenticationManager of success here
                // authenticationManager.handleTwoFactorSuccess()
            } else {
                errorMessage = "Invalid verification code. Please try again."
                isLoading = false
            }
        }
    }
}
#if DEBUG
struct TwoFactorVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TwoFactorVerificationView()
                .environmentObject(AuthenticationManager()) // Provide a dummy AuthenticationManager for preview
        }
    }
}
#endif