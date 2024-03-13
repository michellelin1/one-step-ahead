//
//  ExcerciseView.swift
//  one-step-ahead
//
//  Created by michelle on 2/6/24.
//

import SwiftUI

struct ExerciseView: View {
    @EnvironmentObject var recommendationViewModel: RecommendationViewModel
    @EnvironmentObject var authHandler: AuthViewModel
    @EnvironmentObject var healthKitViewModel: HealthKitViewModel
    
    var body: some View {
        VStack{
            VStack(alignment: .leading) {
                Text("Get Moving!")
                    .font(.system(size: 30))
                    .padding()
            }
            
             ProgressCircle(progress: Float(recommendationViewModel.currExerciseGoal.caloriesBurned/recommendationViewModel.calorieRecommendation), color: Color.green, imageName: "figure.walk", imageSize: 80, size: 180)
            .frame(width: 200, height: 200)
            .padding()
            
            Text("Exercise Recommendation: \(recommendationViewModel.formatToTwoDec( recommendationViewModel.calorieRecommendation)) cal")
            // Text("Exercise history: \(recommendationViewModel.getExerciseHistory().count)")
            Text("Current calories burned: \(healthKitViewModel.formattedCalBurned()) cal")
            Text("Current calories burned rec: \(recommendationViewModel.formatToTwoDec(recommendationViewModel.currExerciseGoal.caloriesBurned)) cal")
            Spacer()
//            Text("Exercise history [1]: \(recommendationViewModel.getExerciseHistory()[1].caloriesBurned)")
//            String(format: "%.1f calories", caloriesBurned)
        }.onAppear {
            recommendationViewModel.getCaloriesRecommendation()
            recommendationViewModel.getCurrentCaloriesBurned()
        }
        
    }
}

struct ExcerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView()
    }
}
