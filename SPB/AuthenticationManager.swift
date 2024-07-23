//
//  AUTHENTICATIONMANAGER.swift
//  SPB
//
//  Created by Nadya Shechtman on 7/11/24.
//

import Foundation
import FirebaseAuth
import Firebase

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    let name: String?

    init(user: User, name: String? = nil) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.name = name
    }
}

final class AuthenticationManager {

    static let shared = AuthenticationManager()
    private init() {}

    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }

    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }

    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }

    func addUserToDatabase(uid: String, name: String) async throws {
        let ref = Database.database().reference().child("users").child(uid)
        try await ref.setValue(["name": name])
    }
    
    func getUserData(uid: String) async throws -> [String: Any]? {
        let ref = Database.database().reference().child("users").child(uid)
        let snapshot = try await ref.getData()
        return snapshot.value as? [String: Any]
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}
