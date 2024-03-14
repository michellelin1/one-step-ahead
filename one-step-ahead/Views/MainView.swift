//
//  MainView.swift
//  one-step-ahead
//
//  Created by michelle on 2/6/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var hkViewModel: HealthKitViewModel
    @EnvironmentObject var authHandler: AuthViewModel
    @EnvironmentObject var recViewModel: RecommendationViewModel
//    @StateObject var exerciseRecc = ExerciseReccView()
    var body: some View {
        Group {
            if (recViewModel.sleepRecommendation != -1 &&
                recViewModel.waterRecommendation != -1 &&
                recViewModel.calorieRecommendation != -1 &&
                recViewModel.weekOfSleep.count > 0 &&
                recViewModel.weekOfExercise.count > 0 &&
                recViewModel.weekOfWater.count > 0
            ){
                TabView {
                    DashboardView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("dashboard")
                        }
                    ExerciseView()
                        .tabItem {
                            Image(systemName: "figure.walk")
                            Text("exercise")
                        }
                    WaterView()
                        .tabItem {
                            Image(systemName: "drop.fill")
                            Text("water")
                        }
                    SleepView()
                        .tabItem {
                            Image(systemName: "moon.zzz.fill")
                            Text("sleep")
                        }
                    HealthKitView()
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("profile")
                        }
                }.onAppear {
                    recViewModel.generateExerciseRecommendations()
                }
            } else {
                LoadingView()
            }
        }
        .onAppear {
            hkViewModel.setUserId(authHandler.user ?? User.empty)
            hkViewModel.checkAuthorizationStatus()
            recViewModel.setUser(authHandler.user ?? User.empty)
            recViewModel.initializeAllRec()
//            exerciseRecc.generateRecommendations(for: authHandler.user, healthKitViewModel: hkViewModel)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
