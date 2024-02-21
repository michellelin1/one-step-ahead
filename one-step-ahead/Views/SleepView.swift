//
//  SleepView.swift
//  one-step-ahead
//
//  Created by michelle on 2/6/24.
//

import SwiftUI

struct SleepView: View {
    @ObservedObject var recommendationViewModel = RecommendationViewModel()
    @EnvironmentObject var authHandler: AuthViewModel
    var body: some View {
        VStack{
            Text("Sleep Recommendation: \(recommendationViewModel.sleepRecommendation)")
        }.onAppear {
            recommendationViewModel.setUser(authHandler.user ?? User.empty)
            recommendationViewModel.getSleepRecommendation()
        }
    }
}

struct SleepView_Previews: PreviewProvider {
    static var previews: some View {
        SleepView()
    }
}
