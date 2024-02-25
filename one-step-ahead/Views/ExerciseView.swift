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
            Text("Exercise Recommendation: \(recommendationViewModel.calorieRecommendation)")
            // Text("Exercise history: \(recommendationViewModel.getExerciseHistory().count)")
            Text("Current calories burned: \(healthKitViewModel.formattedCalBurned())")
            Text("Current calories burned rec: \(recommendationViewModel.currExerciseGoal.caloriesBurned)")
//            Text("Exercise history [1]: \(recommendationViewModel.getExerciseHistory()[1].caloriesBurned)")
//            String(format: "%.1f calories", caloriesBurned)
        }.onAppear {
            recommendationViewModel.setUser(authHandler.user ?? User.empty)
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
