//
//  AuthenticationView.swift
//  SPB
//
//  Created by Nadya Shechtman on 7/11/24.
//

import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        VStack{
            
            NavigationLink {
                SignInEmailView()
            } label: {
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
    }
}

#Preview {
    NavigationStack{
        AuthenticationView()
    }
}
