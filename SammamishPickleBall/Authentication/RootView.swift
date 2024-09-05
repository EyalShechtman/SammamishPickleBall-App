import SwiftUI
import FirebaseAuth

struct RootView: View {

    @State private var showSignInView: Bool = false  // Tracks if sign-in view should be shown
    @State private var isLoading: Bool = true        // Tracks loading state during auth check

    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Checking authentication...")  // Loading spinner while checking auth state
            } else if showSignInView {
                AuthenticationView()  // Show sign-in view if the user is not authenticated
            } else {
                AttendanceVisualView()  // Show the main part of the app if authenticated
            }
        }
        .onAppear {
            checkAuthentication()  // Check if the user is authenticated when the view appears
        }
    }

    private func checkAuthentication() {
        // Check if there is an authenticated user
        if let _ = Auth.auth().currentUser {
            // User is authenticated, skip sign-in
            self.showSignInView = false
        } else {
            // No user is authenticated, show sign-in view
            self.showSignInView = true
        }
        // Stop the loading spinner
        self.isLoading = false
    }
}

#Preview {
    RootView()
}
