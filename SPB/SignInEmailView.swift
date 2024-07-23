//
//  SignInEmailView.swift
//  SPB
//
//  Created by Nadya Shechtman on 7/11/24.
//

import SwiftUI


@MainActor
final class SignInEmailViewModel : ObservableObject{
    @Published var email = ""
    @Published var password = ""
    @Published var isSignedIn = false
    @Published var signedInUserEmail: String?
    @Published var onboarding = false
    @Published var userUID: String?

    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        
        Task{
            do{
                let authDataResult = try await AuthenticationManager.shared.signInUser(email: email, password: password)
                print("success")
                signedInUserEmail = email
                userUID = authDataResult.uid
                let userData = try await AuthenticationManager.shared.getUserData(uid: authDataResult.uid)
                if userData?["name"] == nil {
                    onboarding = true
                }
                isSignedIn = true
                print(authDataResult)
            } catch{
                print("Sign-in failed with error: \(error)")
                do{
                    let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
                    print("Account created successfully")
                    signedInUserEmail = email
                    userUID = authDataResult.uid
                    onboarding = true
                    isSignedIn = true
                    print(authDataResult)
                } catch{
                    print("Account Creation failed with error: \(error)")
                }
            }
        }
//        Task{
//            do{
//                let returnedUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)
//                print("success")
//                signedInUserEmail = email
//                userUID = returnedUserData.uid
//                let userData = try await AuthenticationManager.shared.getUserData(uid: returnedUserData.uid)
//                if userData?["name"] == nil {
//                    onboarding = true
//                }
//                isSignedIn = true
//                print(returnedUserData)
//            }catch{
//                print("Error: \(error)")
//            }
//        }
    }
}

struct SignInEmailView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()
    var body: some View {
        VStack{
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                    
            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            Button{
                viewModel.signIn()
            }label: {
                Text("Sign in")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign in")
        .navigationDestination(isPresented: $viewModel.isSignedIn) {
            if viewModel.onboarding, let uid = viewModel.userUID {
                OnboardingView(uid: uid)
            } else {
                AttendanceView(userEmail: viewModel.signedInUserEmail ?? "")
            }
        }
    }
}

#Preview {
    NavigationStack{
        SignInEmailView()
    }
}
