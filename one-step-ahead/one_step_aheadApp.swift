//
//  one_step_aheadApp.swift
//  one-step-ahead
//
//  Created by michelle on 2/2/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct one_step_aheadApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authHandler = AuthViewModel()
    @StateObject var sleepViewModel = SleepViewModel()
    @StateObject var hkViewModel = HealthKitViewModel()
    @StateObject var recViewModel = RecommendationViewModel()
    @StateObject var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authHandler)
                .environmentObject(sleepViewModel)
                .environmentObject(hkViewModel)
                .environmentObject(recViewModel)
                .environmentObject(locationManager)
                        
        }
    }
}
