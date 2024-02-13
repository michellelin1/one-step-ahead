//
//  AuthHandler.swift
//  one-step-ahead
//
//  Created by michelle on 2/7/24.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var userSession: User?
    @Published var errorMessage = ""
    
    init() {
        fetchUser()
    }
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    func fetchUser() {
        if authStateHandle == nil {
            authStateHandle = Auth.auth().addStateDidChangeListener { auth, user in
                self.userSession = user
            }
        }
    }
    
    
    func signIn(email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            // email = userSession?.email
        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
    
    func createUser(email: String, password: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            // email = userSession?.email
        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
}
