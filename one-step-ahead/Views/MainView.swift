//
//  MainView.swift
//  one-step-ahead
//
//  Created by michelle on 2/6/24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
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
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
