import SwiftUI
import FirebaseDatabase
import Firebase

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var feedbackText = "" // Store feedback text
    
    // Sign out function
    func signout() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    // Function to send feedback to Firebase
    func submitFeedback() {
        let dbRef = Database.database().reference().child("Feedback")
        
        let feedbackData = [
            "feedback": feedbackText,
            "timestamp": Date().timeIntervalSince1970
        ] as [String : Any]
        
        dbRef.childByAutoId().setValue(feedbackData) { error, _ in
            if let error = error {
                print("Error saving feedback: \(error.localizedDescription)")
            } else {
                print("Feedback submitted successfully")
            }
        }
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSigninView: Bool
    @State private var showSignOutConfirmation = false
    @State private var showFeedbackSubmittedAlert = false // Show alert when feedback is submitted

    var body: some View {
        List {
            Section(header: Text("Anonymous Feedback").font(.headline)) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("We appreciate your feedback! Let us know how we can improve.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    TextEditor(text: $viewModel.feedbackText)
                        .frame(height: 75) // Larger input box
                        .padding(10)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                    
                    Button(action: {
                        viewModel.submitFeedback()
                        viewModel.feedbackText = "" // Clear the input after submission
                        showFeedbackSubmittedAlert = true // Trigger the alert
                    }) {
                        Text("Submit Feedback")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(alignment: .center)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showFeedbackSubmittedAlert) {
                        Alert(
                            title: Text("Feedback Submitted"),
                            message: Text("Thank you for your feedback!"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                .padding(.vertical, 10)
            }
            
            Section {
                Button(action: {
                    showSignOutConfirmation = true
                }) {
                    Text("Log Out")
                        .foregroundColor(.blue)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .alert(isPresented: $showSignOutConfirmation) {
            Alert(
                title: Text("Are you sure you want to log out?"),
                message: Text("You will need to log in again."),
                primaryButton: .destructive(Text("Log Out")) {
                    Task {
                        do {
                            try viewModel.signout()
                            showSigninView = true
                        } catch {
                            print(error)
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .navigationTitle("Settings")
        .listStyle(GroupedListStyle())
        .background(Color(.systemGray6))
    }
}

#Preview {
    NavigationStack{
        SettingsView(showSigninView: .constant(false))
    }
}
