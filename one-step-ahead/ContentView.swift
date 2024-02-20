//
//  ContentView.swift
//  one-step-ahead
//
//  Created by michelle on 2/10/24.
//

import SwiftUI

struct ContentView: View {
//    @EnvironmentObject var authHandler: AuthViewModel
    @StateObject var authHandler: AuthViewModel = AuthViewModel()
    var body: some View {
//        Button("signout") {
//            authHandler.signOut()
//        }
        Group {
            if authHandler.userSession == nil {
                LoginView()
            }
            else if authHandler.user == nil {
                WelcomeView()
            }
            else {
                MainView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
