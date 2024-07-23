//
//  RootView.swift
//  SPB
//
//  Created by Nadya Shechtman on 7/11/24.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack{
            NavigationStack{
                SettingsView(showSigninView: $showSignInView)
            }
        }
        .onAppear {
            let authuser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authuser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack{
                AuthenticationView()
            }
        }
        NavigationStack{
            AuthenticationView()
        }
    }
}

#Preview {
    RootView()
}
