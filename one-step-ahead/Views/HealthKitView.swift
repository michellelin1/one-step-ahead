//
//  ContentView.swift
//  one-step-ahead
//
//  Created by Meggie Nguyen on 2/6/24.
//

import SwiftUI
import HealthKit

struct HealthKitView: View {
    @ObservedObject var healthKitViewModel = HealthKitViewModel()
    @StateObject var authHandler: AuthViewModel = AuthViewModel()
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                // TODO: Fetch actual name
                Text("\(authHandler.user?.firstName ?? "User") \(authHandler.user?.lastName ?? "Name")")
                    .font(.system(size: 30)).bold()
                    .padding()
            }
            Text("Sleep Duration: \(healthKitViewModel.formattedSleepDuration())")
                .padding()
            Text("Weight: \(healthKitViewModel.formattedWeight())")
                .padding()
            Text("Height: \(healthKitViewModel.formattedHeight())")
                .padding()
            Text("Biological Sex: \(healthKitViewModel.formattedBiologicalSex())")
                .padding()
            Text("Workouts: \(healthKitViewModel.formattedWorkouts())")
                .padding()
            Text("Calories Burned: \(healthKitViewModel.formattedCalBurned())")
                .padding()
            Button("Authorize Health Data") {
                healthKitViewModel.requestAuthorization()
            }
            .padding()
            .disabled(HKHealthStore.isHealthDataAvailable())
            Spacer()
        }
        .onAppear {
            healthKitViewModel.checkAuthorizationStatus()
        }
        
        
    }
}


#Preview {
    HealthKitView()
}
