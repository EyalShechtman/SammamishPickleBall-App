//
//  SPBApp.swift
//  SPB
//
//  Created by Nadya Shechtman on 7/10/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct SPBApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("configured FireBase")

        return true
    }
}
