//
//  RecommendationView.swift
//  one-step-ahead
//
//  Created by Mia Schroeder on 2/20/24.
//

import SwiftUI

struct RecommendationView: View {
    @ObservedObject var recommendationViewModel = RecommendationViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Text("Sleep Recommendation: \(recommendationViewModel.calculateGradientSleepDeficit())")
    }
}

#Preview {
    RecommendationView()
}

