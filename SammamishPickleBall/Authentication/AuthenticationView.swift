import SwiftUI

struct AuthenticationView: View {

    @State private var isSignUp: Bool = false // Toggle between Sign In and Sign Up

    var body: some View {
        VStack {
            Picker("Sign In / Sign Up", selection: $isSignUp) {
                Text("Sign In").tag(false)
                Text("Sign Up").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if isSignUp {
                SignUpView()
            } else {
                SignInEmailView()
            }
        }
        .navigationTitle(isSignUp ? "Sign Up" : "Sign In")
        
        Text("OPEN FOR ANY INTERNSHIPS for Fall/Spring/Summer!! ")
            .bold() // Apply bold to this part
            .font(.system(size: 20.0))
        + Text("Interestd in WebDev, ML, Data Science, or anything I can create. To the ESP Community Have Fun and  don't take the sun for granted :)")
            .font(.system(size: 20.0)) // Apply regular styling to the rest
        Text("NOTE: THIS APP IS A BETA")
            .bold()
        Link(destination: URL(string: "https://www.linkedin.com/in/eyal-shechtman")!) {
            Image("LinkedIn") // The image you added to Assets.xcassets
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50) // Adjust size as needed
        }
        .buttonStyle(PlainButtonStyle()) // Optional: Disable default button style
        
        .padding()
    }
}

#Preview {
    AuthenticationView()
}
