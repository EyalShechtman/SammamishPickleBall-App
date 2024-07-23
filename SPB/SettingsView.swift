//
//  SettingsView.swift
//  SPB
//
//  Created by Nadya Shechtman on 7/11/24.
//

import SwiftUI

@MainActor
final class SettingsViewModel : ObservableObject{
    
    
    func signout() throws{
        try AuthenticationManager.shared.signOut()
    }
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSigninView: Bool
    
    var body: some View {
        List{
            Button("Log Out"){
                Task{
                    do{
                        try viewModel.signout()
                        showSigninView = true
                    } catch{
                        print(error)
                    }
                }
            }
        }

        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack{
        SettingsView(showSigninView: .constant(false))
    }
}
