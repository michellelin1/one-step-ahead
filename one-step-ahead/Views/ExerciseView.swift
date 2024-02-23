//
//  ExcerciseView.swift
//  one-step-ahead
//
//  Created by michelle on 2/6/24.
//

import SwiftUI

struct ExerciseView: View {
    @ObservedObject var recommendationViewModel = RecommendationViewModel()
    @EnvironmentObject var authHandler: AuthViewModel
    @ObservedObject var healthKitViewModel = HealthKitViewModel()
    
    var body: some View {
        VStack{
            Text("Exercise Recommendation: \(recommendationViewModel.calorieRecommendation)")
            Text("Exercise history [0]: \(recommendationViewModel.getExerciseHistory().count)")
            Text("Current calories burned: \(healthKitViewModel.formattedCalBurned())")
//            Text("Exercise history [1]: \(recommendationViewModel.getExerciseHistory()[1].caloriesBurned)")
//            String(format: "%.1f calories", caloriesBurned)
        }.onAppear {
            recommendationViewModel.setUser(authHandler.user ?? User.empty)
            recommendationViewModel.getCaloriesRecommendation()
            healthKitViewModel.fetchCaloriesBurned()
        }
    }
}

struct ExcerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView()
    }
}
