//
//  AuthHandler.swift
//  one-step-ahead
//
//  Created by michelle on 2/7/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var user: User?
    @Published var errorMessage = ""
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var db = Firestore.firestore()
    
    init() {
        fetchUser()
    }
    
    func fetchUser() {
        if authStateHandle == nil {
            authStateHandle = Auth.auth().addStateDidChangeListener { auth, user in
                self.userSession = user
                if user != nil {
                    self.fetchUserData()
                }
                
            }
        }
    }
    
    func fetchUserData() {
        Task {
            do {
                let path = "users/" + (self.userSession?.uid ?? "")
                self.user = try await db.document(path).getDocument(as: User.self)
                print(user?.firstName ?? "no first name")
            } catch {
                print(error)
            }
        }
    }
    
    func setUserData(first: String, last: String, water: Double, sleep: Double, exercise: Double) -> Bool {
        do {
            self.user = User(firstName: first, lastName: last, waterGoal: water, sleepGoal: sleep, exerciseGoal: exercise)
            let path = "users/" + (userSession?.uid ?? "")
            try db.document(path).setData(from: user)
            return true
            
        } catch {
            print(error)
            return false
        }
        
    }
    
    
    func signIn(email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            // email = userSession?.email
            self.fetchUserData()
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
