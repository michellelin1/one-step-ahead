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
            
            let cal_progress = Float(healthKitViewModel.caloriesBurned ?? 0.0) / Float(authHandler.user?.exerciseGoal ?? 350.0)
            
            // TO DO: MAKE PROGRESS VARS FOR WATER AND SLEEP
            
            HStack {
                ProgressCircle(progress: cal_progress, color: Color.green, imageName: "figure.walk")
                ProgressCircle(progress: 0.7, color: Color.blue, imageName: "drop.fill") // Adjust
                ProgressCircle(progress: 0.5, color: Color.purple, imageName: "moon.zzz.fill") //
            }
        }
        .padding()
        .onAppear {
            healthKitViewModel.checkAuthorizationStatus()
        }
        
        
    }
}

struct ProgressCircle: View {
    var progress: Float
    var color: Color
    var imageName: String
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    color.opacity(0.5),
                    lineWidth: 10 // Adjust the stroke width to make the circle smaller
                )
                .frame(width: 80, height: 80) // Adjust the frame size to make the circle smaller
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: 10, // Adjust the stroke width to make the circle smaller
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 80, height: 80) // Adjust the frame size to make the circle smaller
            Image(systemName: imageName)
                .font(.largeTitle)
                .foregroundColor(color)
        }
        .padding()
    }
}

#Preview {
    HealthKitView()
}
