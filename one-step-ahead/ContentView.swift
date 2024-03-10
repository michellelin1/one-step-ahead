//
//  ContentView.swift
//  one-step-ahead
//
//  Created by michelle on 2/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoading = false
    @EnvironmentObject var authHandler: AuthViewModel
    @EnvironmentObject var healthKitViewModel: HealthKitViewModel

    var body: some View {
        Group {
            if authHandler.userSession == nil {
                LoginView()
            }
            else if authHandler.user == nil {
                WelcomeView()
            }
            else {
                MainView()
//                    .onAppear {
//                        startFakeNetworkCall()
//                    }
            }
            
        }
//            .onAppear{startFakeNetworkCall()}
    }
    
    func startFakeNetworkCall() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(2)
                    .padding()
                Text("Loading Content...")
            }
        }
    }
}
