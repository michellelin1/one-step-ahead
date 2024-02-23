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
    
    var body: some View {
        VStack{
            Text("Exercise Recommendation: \(recommendationViewModel.calorieRecommendation)")
            Text("Exercise history [0]: \(recommendationViewModel.getExerciseHistory().count)")
            Text("Current calories burned: \(recommendationViewModel.getCurrentCaloriesBurned())")
//            Text("Exercise history [1]: \(recommendationViewModel.getExerciseHistory()[1].caloriesBurned)")
        }.onAppear {
            recommendationViewModel.setUser(authHandler.user ?? User.empty)
            recommendationViewModel.getCaloriesRecommendation()
        }
    }
}

struct ExcerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView()
    }
}
