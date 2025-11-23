# Implementation Plan

# Implementation Plan for COD-31
## 1. Overview/Goal
The goal of this ticket is to create a dedicated "Profile" screen within the Sammamish Pickleball application. This screen will serve as a central place for users to view their account information and perform account-related actions like signing out. This enhances the user experience by providing clear access to account management features.
Based on the existing file structure, this will involve creating a new SwiftUI view and its corresponding view model, and integrating it into the existing navigation flow, likely from the `SettingsView`.
## 2. Step-by-Step Tasks
1.  **Create User Profile View Model:**
    *   Create a new file for `ProfileViewModel.swift`.
    *   Define a class `ProfileViewModel` that conforms to `ObservableObject`.
    *   Add logic to retrieve the current authenticated user's information (e.g., email, user ID) from the `AuthenticationManager`.
    *   Implement a function to call the sign-out method from `AuthenticationManager`.
2.  **Create User Profile View:**
    *   Create a new file for `ProfileView.swift`.
    *   Design and implement the UI using SwiftUI.
    *   The view should display the user's email address and other relevant account details.
    *   Add a "Sign Out" button.
    *   Add a "Delete Account" button (optional, but good practice).
    *   Connect the UI elements to the `ProfileViewModel` to display data and handle actions.
3.  **Integrate Profile View into Navigation:**
    *   Modify `SettingsView.swift`.
    *   Add a `NavigationLink` that directs the user from the `SettingsView` to the newly created `ProfileView`.
    *   Ensure the navigation bar title and appearance are consistent with the rest of the app.
4.  **Implement Account Deletion (Optional but Recommended):**
    *   Add a `deleteAccount` function to `AuthenticationManager`. This will involve calling the appropriate Firebase Auth methods.
    *   Add a corresponding function in `ProfileViewModel` to call the manager's method.
    *   Implement an alert (`.alert()`) in `ProfileView` to confirm the user's intent before proceeding with account deletion.
## 3. Files to Modify/Create
### Files to Create:
*   `SammamishPickleBall/Profile/ProfileView.swift`: The new SwiftUI view for the user profile screen.
*   `SammamishPickleBall/Profile/ProfileViewModel.swift`: The view model to manage the logic and state for the `ProfileView`.
### Files to Modify:
*   `SammamishPickleBall/Authentication/SettingsView.swift`: To add a `NavigationLink` to the `ProfileView`.
*   `SammamishPickleBall/Authentication/AuthenticationManager.swift`: To potentially add an account deletion function if it doesn't already exist.
## 4. Implementation Notes
*   **Architecture:** The implementation should follow the existing MVVM (Model-View-ViewModel) pattern observed in the codebase (e.g., `SignInEmailView` and its logic).
*   **User Data:** The `AuthenticationManager` appears to be the source of truth for user authentication state. The `ProfileViewModel` should rely on it to get user data.
*   **Error Handling:** Implement robust error handling for actions like signing out and deleting an account. Display appropriate alerts to the user if an operation fails.
*   **UI Consistency:** The new profile screen's UI should match the existing style, colors, and fonts of the SammamishPickleBall app.
*   **Dependencies:** The new view model will likely need to import `FirebaseAuth`.
