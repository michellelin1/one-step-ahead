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
    @EnvironmentObject var recViewModel: RecommendationViewModel
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
                    if recViewModel.currSleepDuration.napTime != nil {
                        GroupBoxContentView(title: "Nap Duration", imageName: "bed.double.fill", content: "\(sleepViewModel.formattedNapDuration(recViewModel.currSleepDuration.napTime ?? 0))", color: .purple)
                    }
                    GroupBoxContentView(title: "Calories Burned", imageName: "flame.fill", content: "\(healthKitViewModel.formattedCalBurned())", color: .red)
                    GroupBoxContentView(title: "Water Drank", imageName: "drop.fill", content: "\(recViewModel.currWaterGoal.amountDrank) oz", color: .cyan)
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
                let cal_progress = Float(healthKitViewModel.caloriesBurned ?? 0.0) / Float(recViewModel.calorieRecommendation)
                
                //may need to update 3 oz
                let water_progress = Float(recViewModel.currWaterGoal.amountDrank) / Float(recViewModel.waterRecommendation)
                
                let sleep_progress = Float(recViewModel.currSleepDuration.sleepDuration) / Float(recViewModel.sleepRecommendation)
                
                HStack {
                    ProgressCircle(progress: cal_progress, color: Color.green, imageName: "figure.walk")
                    ProgressCircle(progress: water_progress, color: Color.blue, imageName: "drop.fill")
                    ProgressCircle(progress: sleep_progress, color: Color.purple, imageName: "moon.zzz.fill") //
                }
            }
            .padding()
            .onAppear {
                // recViewModel.initializeAllRec()
                recViewModel.getCurrentWater()
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
    var size: CGFloat = 80
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(
                        color.opacity(0.5),
                        lineWidth: size/10
                    )
                    .frame(width: size, height: size)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        color,
                        style: StrokeStyle(
                            lineWidth: size/10,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: size, height: size)
                
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
