//
//  RecommendationView.swift
//  one-step-ahead
//
//  Created by Mia Schroeder on 2/20/24.
//

import SwiftUI

struct RecommendationView: View {
    @ObservedObject var recommendationViewModel = RecommendationViewModel()
    @EnvironmentObject var authHandler: AuthViewModel
    
    var body: some View {
        VStack{
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//            Text("Sleep Recommendation: \(recommendationViewModel.calculateGradientSleepDeficit())")
//            Text("Exercise Recommendation: \(recommendationViewModel.calculateGradientCaloricSurplus())")
        }.onAppear{
            recommendationViewModel.setUser(authHandler.user ?? User.empty)
        }
        
    }
}

//#Preview {
//    RecommendationView()
//}

