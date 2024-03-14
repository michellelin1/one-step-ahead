//
//  ContentView.swift
//  one-step-ahead
//
//  Created by Meggie Nguyen on 2/6/24.
//

import SwiftUI
import HealthKit
import CoreLocation
import CoreLocationUI

struct HealthKitView: View {

    @StateObject var waterViewModel = WaterViewModel()

    @EnvironmentObject var healthKitViewModel: HealthKitViewModel
    @EnvironmentObject var sleepViewModel: SleepViewModel
    @EnvironmentObject var recViewModel: RecommendationViewModel
    @EnvironmentObject var authHandler: AuthViewModel

    @State private var isEditingGoals = false
    
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
                        GroupBoxContentView(title: "Nap Duration", imageName: "bed.double.fill", content: "\(sleepViewModel.formattedNapDuration(TimeInterval(((recViewModel.currSleepDuration.napTime) ?? 0) * 3600)))", color: .purple)
                    }
                    GroupBoxContentView(title: "Calories Burned", imageName: "flame.fill", content: "\(healthKitViewModel.formattedCalBurned())", color: .red)
                    GroupBoxContentView(title: "Water Drank", imageName: "drop.fill", content: "\(recViewModel.currWaterGoal.amountDrank) oz", color: .cyan)
                    GroupBoxContentView(title: "Weight", imageName: "figure.stand", content: "\(healthKitViewModel.formattedWeight())", color: .mint)
                    GroupBoxContentView(title: "Height", imageName: "figure.stand", content: "\(healthKitViewModel.formattedHeight())", color: .mint)
                    GroupBoxContentView(title: "Biological Sex", imageName: "figure.stand", content: "\(healthKitViewModel.formattedBiologicalSex())", color: .mint)
                }


                Button("Edit Goals") {
                    self.isEditingGoals.toggle()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.accentColor)
                .cornerRadius(10)
                .padding()
                
                .sheet(isPresented: $isEditingGoals) {
                    EditGoalsView(isPresented: self.$isEditingGoals)
                }
                

                
                Text("Daily Progress!").font(.system(size: 24)).bold()
                let cal_progress = Float(healthKitViewModel.caloriesBurned ?? 0.0) / Float(recViewModel.calorieRecommendation)
                
                //may need to update 3 oz
                let water_progress = Float(recViewModel.currWaterGoal.amountDrank) / Float(recViewModel.waterRecommendation)
                
                // figure out why the progress ring isnt working properly 
                let sleep_progress = Float(recViewModel.currSleepDuration.sleepDuration + (((recViewModel.currSleepDuration.napTime ?? 0)*3600) / 3600)) / Float(recViewModel.sleepHistory[0].goal)
                
                HStack {
                    ProgressCircle(progress: cal_progress, color: Color.green, imageName: "figure.walk")
                    ProgressCircle(progress: water_progress, color: Color.blue, imageName: "drop.fill")
                    ProgressCircle(progress: sleep_progress, color: Color.purple, imageName: "moon.zzz.fill") //
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
    var imageName: String = ""
    var imageSize: CGFloat = 40
    var size: CGFloat = 80
    var hideProgress = false
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(
                        color.opacity(0.5),
                        lineWidth: size/8
                    )
                    .frame(width: size, height: size)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        color,
                        style: StrokeStyle(
                            lineWidth: size/8,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: size, height: size)
                
                if imageName != "" {
                    Image(systemName: imageName )
                        .font(.system(size: imageSize))
                        .foregroundColor(color)
                }
            }
            .padding([.top, .bottom], size/8)
            
            // Text below the progress circle
            if !hideProgress {
                if progress >= 1.0 {
                    Text("Completed!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
//                    Text("Progress: \(Int(progress * 100))%")
                        Text("Progress: \((progress * 100))%")
                    
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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
