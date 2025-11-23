# Implementation Plan

Here is the implementation plan for revamping the UI and adding 2-factor authentication.
### 1. Overview & Goal
The primary goal is to modernize the `SammamishPickleBall` application's user interface and enhance security. This will be achieved by implementing a "glassmorphism" UI style for a more modern feel and integrating Firebase's two-factor authentication (2FA). A key focus will be improving the user experience, especially during the onboarding and authentication flows.
### 2. Step-by-Step Tasks
**Phase 1: UI/UX Modernization**
1.  **Create a Reusable Glass View:**
    *   Develop a custom SwiftUI `ViewModifier` or a container view that applies a background blur (material), rounded corners, and a subtle border. This will be the foundational component for the new UI style.
2.  **Revamp Authentication & Onboarding UI:**
    *   Refactor `AuthenticationView`, `SignInEmailView`, and `SignUpView` to use the new glass component for backgrounds and input fields.
    *   Improve the layout, typography, and spacing to create a cleaner, more intuitive user interface.
    *   Overhaul the `OnboardingView` to be more engaging. Break the form into distinct, visually appealing steps (e.g., Step 1: Enter Name, Step 2: Select Skill Level) to improve the user experience.
3.  **Update Main App UI:**
    *   Apply the glassmorphism style to the main dashboard components in `AttendanceVisualView`, including the chart container and the list items.
    *   Ensure text and data remain legible and accessible against the new blurred backgrounds, testing in both light and dark modes.
**Phase 2: Implement Firebase 2-Factor Authentication (2FA)**
1.  **Extend Authentication Manager:**
    *   Modify the `AuthenticationManager` singleton to include new functions for handling 2FA logic. This will involve integrating with the Firebase Auth SDK for multi-factor authentication.
2.  **Develop 2FA Enrollment Flow:**
    *   Create a new section within the `SettingsView` (or a similar appropriate location) where users can enable and set up 2FA. This flow will guide the user through verifying their identity before enrolling a second factor.
3.  **Modify Sign-In Logic:**
    *   Update the `SignInEmailViewModel` and associated logic. After a user successfully enters their password, the app must check if 2FA is enabled for their account.
    *   If 2FA is active, navigate the user to a new "Verification" view to enter the code sent to their second factor.
4.  **Create Verification View:**
    *   Build a new SwiftUI view that provides a field for the user to input their 2FA code and a button to submit it for verification.
**Phase 3: Testing**
1.  **UI/UX Testing:**
    *   Rigorously test the new UI on various device sizes and orientations.
    *   Verify that all components are visually correct and functional in both light and dark modes.
2.  **2FA Functional Testing:**
    *   Test the complete authentication lifecycle: sign-up, enroll in 2FA, sign out, and sign back in using both factors.
    *   Test the sign-in flow for users who do not have 2FA enabled to ensure it remains unaffected.
### 3. Files to Modify/Create
**Files to Create:**
*   `SammamishPickleBall/Common/GlassViewModifier.swift`: For the reusable glassmorphism effect.
*   `SammamishPickleBall/Authentication/TwoFactorVerificationView.swift`: The new view for entering the 2FA code.
**Files to Modify:**
*   `SammamishPickleBall/Authentication/AuthenticationView.swift`: Update UI to use glass components.
*   `SammamishPickleBall/Authentication/SignInEmailView.swift`: Update UI and view model to handle the 2FA check.
*   `SammamishPickleBall/Authentication/SignUpView.swift`: Update UI.
*   `SammamishPickleBall/Authentication/onboardingView.swift`: Major UI/UX overhaul.
*   `SammamishPickleBall/Authentication/SettingsView.swift`: Add UI for 2FA enrollment.
*   `SammamishPickleBall/Authentication/AuthenticationManager.swift`: Add new methods for 2FA logic.
*   `SammamishPickleBall/Attendance/AttendanceVisualView.swift`: Update UI elements to use glass components.
### 4. Implementation Notes
*   **Glassmorphism Effect:** The glass effect can be efficiently achieved in SwiftUI using the `.background(.ultraThinMaterial)` modifier, combined with `.cornerRadius()` and an optional `.overlay()` for a border. This avoids the need for more complex `UIViewRepresentable` wrappers.
*   **Firebase 2FA:** The ticket assumes Firebase is configured. The implementation will focus on the client-side logic using the official Firebase iOS SDK. We will consult the Firebase documentation for the specific methods related to multi-factor authentication.
*   **UX Focus:** Throughout the UI revamp, the priority is to reduce clutter and guide the user. The new onboarding flow is a key opportunity to make a positive first impression.
