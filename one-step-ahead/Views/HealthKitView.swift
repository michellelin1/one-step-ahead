//
//  ContentView.swift
//  one-step-ahead
//
//  Created by Meggie Nguyen on 2/6/24.
//

import SwiftUI
import HealthKit

struct HealthKitView: View {
    @EnvironmentObject var healthKitViewModel: HealthKitViewModel
    @StateObject var waterViewModel = WaterViewModel()
    @EnvironmentObject var sleepViewModel: SleepViewModel
    
    @EnvironmentObject var authHandler: AuthViewModel
    @ObservedObject var exerciseRecc = ExerciseReccView()
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    Text("\(authHandler.user?.firstName ?? "User") \(authHandler.user?.lastName ?? "Name")")
                        .font(.system(size: 30)).bold()
                        .padding()
                }
                Group {
                    GroupBoxContentView(title: "Sleep Duration", imageName: "bed.double.fill", content: "\(healthKitViewModel.formattedSleepDuration())", color: .purple)
                    if sleepViewModel.napLength > 0 {
                        GroupBoxContentView(title: "Nap Duration", imageName: "bed.double.fill", content: "\(sleepViewModel.formattedNapDuration())", color: .purple)
                    }
                    GroupBoxContentView(title: "Calories Burned", imageName: "flame.fill", content: "\(healthKitViewModel.formattedCalBurned())", color: .red)
                    GroupBoxContentView(title: "Water Drank", imageName: "drop.fill", content: "\(waterViewModel.currWater.amountDrank) oz", color: .cyan)
                    GroupBoxContentView(title: "Weight", imageName: "figure.stand", content: "\(healthKitViewModel.formattedWeight())", color: .mint)
                    GroupBoxContentView(title: "Height", imageName: "figure.stand", content: "\(healthKitViewModel.formattedHeight())", color: .mint)
                    GroupBoxContentView(title: "Biological Sex", imageName: "figure.stand", content: "\(healthKitViewModel.formattedBiologicalSex())", color: .mint)
                }
                Button("Sign Out") {
                    authHandler.signOut()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.red)
                .cornerRadius(10)
                .padding()
                Spacer()
                
                Text("Daily Progress!").font(.system(size: 24)).bold()
                let cal_progress = Float(healthKitViewModel.caloriesBurned ?? 0.0) / Float(authHandler.user?.exerciseGoal ?? 350.0)
                
                //may need to update 3 oz
                let water_progress = Float(waterViewModel.currWater.amountDrank) / Float(authHandler.user?.waterGoal ?? 3)
                
                let sleep_progress = Float((healthKitViewModel.sleepDuration +  sleepViewModel.napLength) / 3600) / Float(authHandler.user?.sleepGoal ?? 8.0)
                
                HStack {
                    ProgressCircle(progress: cal_progress, color: Color.green, imageName: "figure.walk")
                    ProgressCircle(progress: water_progress, color: Color.blue, imageName: "drop.fill")
                    ProgressCircle(progress: sleep_progress, color: Color.purple, imageName: "moon.zzz.fill") //
                }
            }
            .padding()
            .onAppear {
//                healthKitViewModel.setUserId(authHandler.user ?? User.empty)
//                healthKitViewModel.checkAuthorizationStatus()
                waterViewModel.fetchCurrWater()
            }
        }
    }
}

struct GroupBoxContentView: View {
    let title: String
    let imageName: String
    let content: String
    let color: Color
    
    var body: some View {
        GroupBox (
            label: Label(title, systemImage: imageName)
                .foregroundColor(color)
        ) {
            Text(content)
        }
    }
}

private func formatTimeInterval(_ interval: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
    formatter.unitsStyle = .abbreviated
    return formatter.string(from: interval) ?? "0"
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
