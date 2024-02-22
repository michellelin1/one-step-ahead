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
    @ObservedObject var exerciseRecc = ExerciseReccView()
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
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
//            Button("Authorize Health Data") {
//                healthKitViewModel.requestAuthorization()
//            }
//            .padding()
//            .disabled(HKHealthStore.isHealthDataAvailable())
            Spacer()
            
            Text("Daily Progress!").font(.system(size: 24)).bold()
            let cal_progress = Float(healthKitViewModel.caloriesBurned ?? 0.0) / Float(authHandler.user?.exerciseGoal ?? 350.0)
            
            let sleep_progress = Float(healthKitViewModel.sleepDuration / 3600) / Float(authHandler.user?.sleepGoal ?? 8.0)
            
            // TO DO: MAKE PROGRESS VARS FOR WATER
            
            HStack {
                ProgressCircle(progress: cal_progress, color: Color.green, imageName: "figure.walk")
                ProgressCircle(progress: 0.7, color: Color.blue, imageName: "drop.fill") // Adjust
                ProgressCircle(progress: sleep_progress, color: Color.purple, imageName: "moon.zzz.fill") //
            }
        }
        .padding()
        .onAppear {
            healthKitViewModel.setUserId(authHandler.user ?? User.empty)
            healthKitViewModel.checkAuthorizationStatus()
        }
        
        
    }
}

struct ProgressCircle: View {
    var progress: Float
    var color: Color
    var imageName: String
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(
                        color.opacity(0.5),
                        lineWidth: 10
                    )
                    .frame(width: 80, height: 80)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        color,
                        style: StrokeStyle(
                            lineWidth: 10,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 80, height: 80)
                
                Image(systemName: imageName)
                    .font(.largeTitle)
                    .foregroundColor(color)
            }
            .padding()
            
            // Text below the progress circle
            if progress >= 1.0 {
                Text("Completed!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Progress: \(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
               
        }
        .frame(maxWidth: .infinity)
        .alignmentGuide(.leading) { _ in .zero }
    }
}

struct HealthKitView_Previews: PreviewProvider {
    static var previews: some View {
        HealthKitView()
    }
}
