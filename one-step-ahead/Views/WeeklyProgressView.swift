//
//  WeeklyProgressView.swift
//  one-step-ahead
//
//  Created by michelle on 3/9/24.
//

import SwiftUI

struct WeeklyProgressView: View {
    @EnvironmentObject var recViewModel: RecommendationViewModel
    @EnvironmentObject var hkViewModel: HealthKitViewModel
    let days = ["S", "M", "T", "W", "T", "F", "S"]
    var body: some View {
        HStack {
            ForEach(0...6, id: \.self) { index in
                VStack {
                    Text(days[index])
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if (Calendar.current.component(.weekday, from: Date()) - 1 == index) {
                        threeRings(
                            exercisePercentage: Float((hkViewModel.caloriesBurned ?? 0)/recViewModel.currExerciseGoal.goal),
                            sleepPercentage: Float((hkViewModel.sleepDuration + (recViewModel.currSleepDuration.napTime ?? 0))/recViewModel.currSleepDuration.goal),
                            waterPercentage: Float(recViewModel.currWaterGoal.amountDrank/recViewModel.currWaterGoal.goal)
                        )
                    } else {
                        threeRings(
                            exercisePercentage: Float(recViewModel.weekOfExercise[index].caloriesBurned/recViewModel.weekOfExercise[index].goal),
                            sleepPercentage: Float((recViewModel.weekOfSleep[index].sleepDuration + (recViewModel.weekOfSleep[index].napTime ?? 0))/recViewModel.weekOfSleep[index].goal),
                            waterPercentage: Float(recViewModel.weekOfWater[index].amountDrank/recViewModel.weekOfWater[index].goal))
                    }
                }
            }
        }
    }
}

struct threeRings: View {
    var exercisePercentage: Float
    var sleepPercentage: Float
    var waterPercentage: Float

    
    var body: some View {
        ZStack {
            ProgressCircle(progress: exercisePercentage, color: .green, size: 39, hideProgress: true)
            ProgressCircle(progress: sleepPercentage, color: .purple, size: 30, hideProgress: true)
            ProgressCircle(progress: waterPercentage, color: .blue, size: 24, hideProgress: true)
        }
    }
}

struct WeeklyProgressView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyProgressView()
    }
}
