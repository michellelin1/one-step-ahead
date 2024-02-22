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
